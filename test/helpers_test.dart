import 'package:mercy_pay/mercy_pay.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  Object payment(String status) => json(200, {'data': {'id': 'pay_1', 'object': 'payment', 'status': status}});

  test('reads the payment again until its status is final', () async {
    final (client, requests) = fakeClient([payment('pending'), payment('processing'), payment('succeeded')]);

    expect((await client.payments.waitForFinalStatus('pay_1'))['status'], 'succeeded');
    expect(requests, hasLength(3));
  });

  test('gives up after the timeout with the last state', () async {
    final (client, _) = fakeClient([payment('pending'), payment('pending'), payment('pending')]);

    await expectLater(
      client.payments.waitForFinalStatus('pay_1', timeout: const Duration(seconds: 1), interval: const Duration(milliseconds: 600)),
      throwsA(isA<WaitTimeoutException>().having((error) => error.last['status'], 'last status', 'pending')),
    );
  });

  test('picks the sandbox number for an outcome or a failure code', () async {
    final numbers = {
      'object': 'list',
      'has_more': false,
      'data': [
        {'provider': 'ORANGE_CMR', 'phone': '237693456789', 'applies_to': 'payment', 'outcome': 'succeeded', 'failure_code': null},
        {'provider': 'ORANGE_CMR', 'phone': '237693456049', 'applies_to': 'payment', 'outcome': 'failed', 'failure_code': 'insufficient_balance'},
        {'provider': 'ORANGE_CMR', 'phone': '237693456119', 'applies_to': 'payout', 'outcome': 'failed', 'failure_code': null},
      ],
    };
    final (client, requests) = fakeClient([for (var i = 0; i < 4; i++) json(200, numbers)]);

    expect(await client.testHelpers.mobileMoneyNumber(MercyPayCatalog.orangeCmr), '237693456789');
    expect(await client.testHelpers.mobileMoneyNumber('ORANGE_CMR', 'insufficient_balance'), '237693456049');
    expect(await client.testHelpers.mobileMoneyNumber('ORANGE_CMR', 'payout_failed'), '237693456119');
    expect(await client.testHelpers.mobileMoneyNumber('ORANGE_CMR', 'payer_not_found'), isNull);
    expect(requests.first.url.toString(), 'https://api.test/api/v1/test_helpers/mobile_money_numbers?provider=ORANGE_CMR');
  });

  test('the catalog lists countries, operators and event types', () {
    expect(MercyPayCatalog.countries['CMR']!.providers, contains('MTN_MOMO_CMR'));
    expect(MercyPayCatalog.eventTypes, contains('payment.succeeded'));
  });
}
