import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mercy_pay/mercy_pay.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('sends the key and unwraps the object', () async {
    final (client, requests) = fakeClient([json(200, {'data': {'id': 'pay_1', 'status': 'succeeded'}})]);

    final payment = await client.payments.retrieve('pay_1', {'expand': ['checkout_session']});

    expect(payment['status'], 'succeeded');
    expect(requests.single.method, 'GET');
    expect(requests.single.url.toString(), 'https://api.test/api/v1/payments/pay_1?expand%5B%5D=checkout_session');
    expect(requests.single.headers['Authorization'], 'Bearer mp_sandbox_test');
    expect(requests.single.headers['User-Agent'], startsWith('mercy-pay-dart/'));
  });

  test('sends a POST as JSON with an idempotency key', () async {
    final (client, requests) = fakeClient();

    await client.checkoutSessions.create(params: {'amount': 15000, 'currency': 'XAF', 'metadata': {'order': 'é'}}, idempotencyKey: 'order-4821');
    await client.refunds.cancel('re_1');

    expect(jsonDecode(requests[0].body), {'amount': 15000, 'currency': 'XAF', 'metadata': {'order': 'é'}});
    expect(requests[0].headers['Idempotency-Key'], 'order-4821');
    expect(requests[1].body, '{}');
    expect(requests[1].headers['Idempotency-Key'], matches(RegExp(r'^dart_[0-9a-f]{32}$')));
  });

  test('retries with the same idempotency key', () async {
    final (client, requests) = fakeClient([http.ClientException('down'), json(502, {}), json(201, {'data': {'id': 'po_1'}})]);

    final payout = await client.payouts.create(params: {'amount': 4000});

    expect(payout['id'], 'po_1');
    expect(requests, hasLength(3));
    expect(requests.map((request) => request.headers['Idempotency-Key']).toSet(), hasLength(1));
  });

  test('gives up after the retries', () async {
    final (client, requests) = fakeClient([json(500, {}), json(500, {}), json(500, {'error': {'type': 'api_error'}})]);
    await expectLater(client.account.retrieve(), throwsA(isA<ApiServerException>()));
    expect(requests, hasLength(3));

    final (offline, _) = fakeClient([http.ClientException('down'), http.ClientException('down'), http.ClientException('down')]);
    await expectLater(offline.account.retrieve(), throwsA(isA<ConnectionException>()));
  });

  test('throws typed errors with what the API said, without retrying a 4xx', () async {
    final (client, requests) = fakeClient([
      json(422, {'error': {'type': 'invalid_request_error', 'code': 'validation_failed', 'message': 'Montant invalide.', 'param': 'amount', 'request_id': 'req_9', 'errors': {'amount': ['Montant invalide.']}}}),
      json(402, {'error': {'type': 'payment_error', 'code': 'payment_declined'}}),
    ]);

    try {
      await client.payments.create(params: {'amount': -1});
      fail('expected an exception');
    } on InvalidRequestException catch (error) {
      expect((error.status, error.code, error.param, error.requestId), (422, 'validation_failed', 'amount', 'req_9'));
      expect(error.errors, {'amount': ['Montant invalide.']});
    }
    expect(requests, hasLength(1));
    await expectLater(client.payments.create(params: {'amount': 1}), throwsA(isA<PaymentException>()));
  });

  test('goes through every page', () async {
    final (client, requests) = fakeClient([
      json(200, {'object': 'list', 'has_more': true, 'next_cursor': 'pay_2', 'data': [{'id': 'pay_1'}, {'id': 'pay_2'}]}),
      json(200, {'object': 'list', 'has_more': false, 'next_cursor': null, 'data': [{'id': 'pay_3'}]}),
    ]);

    final page = await client.payments.list({'limit': 2, 'created': {'gte': '2026-11-01'}});
    final ids = await page.autoPaging().map((payment) => payment['id']).toList();

    expect(page.data, hasLength(2));
    expect(ids, ['pay_1', 'pay_2', 'pay_3']);
    expect(requests[1].url.toString(), 'https://api.test/api/v1/payments?limit=2&created%5Bgte%5D=2026-11-01&starting_after=pay_2');
  });

  test('escapes ids in the path', () async {
    final (client, requests) = fakeClient();
    await client.customers.retrieve('cus_1/../x');
    expect(requests.single.url.toString(), 'https://api.test/api/v1/customers/cus_1%2F..%2Fx');
  });
}
