import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'helpers.dart';

/// Every operation of the API reference (test/openapi.json, a copy of
/// docs.mercy-pay.com/openapi.json) has a method calling the right verb and path.
void main() {
  final spec = jsonDecode(File('test/openapi.json').readAsStringSync()) as Map<String, dynamic>;
  final operations = {
    for (final op in jsonDecode(File('tool/operations.json').readAsStringSync()) as List) (op as Map)['operationId'] as String: op,
  };
  final paths = spec['paths'] as Map<String, dynamic>;
  var count = 0;

  paths.forEach((path, methods) {
    (methods as Map<String, dynamic>).forEach((verb, definition) {
      final operationId = (definition as Map)['operationId'] as String;
      count++;
      test('$operationId calls ${verb.toUpperCase()} $path', () async {
        expect(operations[operationId], isNotNull, reason: 'aucune méthode pour $operationId');
        final operation = operations[operationId]!;
        final (client, requests) = fakeClient();
        final ids = [for (final name in operation['ids'] as List) 'id_$name'];
        final method = operation['method'] == 'all' ? 'list' : operation['method'] as String;

        await _call(client, operation['service'] as String, method, ids);

        final remaining = List.of(ids);
        final expected = path.replaceAllMapped(RegExp(r'\{[^}]+\}'), (_) => remaining.removeAt(0));
        expect(requests.single.method, verb.toUpperCase());
        expect(requests.single.url.path, expected);
      });
    });
  });

  test('lists no operation the reference does not have', () => expect(operations.length, count));
}

/// Calls `client.<resource>.<method>(ids…)` without mirrors: dynamic dispatch is enough.
Future<void> _call(dynamic client, String service, String method, List<String> ids) async {
  final property = switch (service) {
    'Account' => client.account,
    'ProviderStatus' => client.providerStatus,
    'BillingPortal' => client.billingPortal,
    'Fee' => client.fees,
    'CheckoutSession' => client.checkoutSessions,
    'Payment' => client.payments,
    'Refund' => client.refunds,
    'Wallet' => client.wallets,
    'WalletTransfer' => client.walletTransfers,
    'Payout' => client.payouts,
    'PaymentLink' => client.paymentLinks,
    'Plan' => client.plans,
    'Customer' => client.customers,
    'Subscription' => client.subscriptions,
    'Invoice' => client.invoices,
    'Event' => client.events,
    'WebhookEndpoint' => client.webhookEndpoints,
    'RequestLog' => client.requestLogs,
    'TestHelper' => client.testHelpers,
    _ => throw StateError('service inconnu $service'),
  };
  await Function.apply(_method(property, method), ids);
}

Function _method(dynamic resource, String name) {
  // A tear-off by name through noSuchMethod-free switch keeps the test honest about names.
  return switch (name) {
    'list' => resource.list,
    'retrieve' => resource.retrieve,
    'create' => resource.create,
    'update' => resource.update,
    'delete' => resource.delete,
    'quote' => resource.quote,
    'expire' => resource.expire,
    'refund' => resource.refund,
    'cancel' => resource.cancel,
    'archive' => resource.archive,
    'restore' => resource.restore,
    'payments' => resource.payments,
    'paymentMethods' => resource.paymentMethods,
    'setDefaultPaymentMethod' => resource.setDefaultPaymentMethod,
    'removePaymentMethod' => resource.removePaymentMethod,
    'reactivate' => resource.reactivate,
    'advance' => resource.advance,
    'pause' => resource.pause,
    'resume' => resource.resume,
    'invoices' => resource.invoices,
    'pay' => resource.pay,
    'send' => resource.send,
    'createSession' => resource.createSession,
    'deliveries' => resource.deliveries,
    'resend' => resource.resend,
    'rotateSecret' => resource.rotateSecret,
    'test' => resource.test,
    'triggerEvent' => resource.triggerEvent,
    _ => throw StateError('méthode inconnue $name'),
  };
}
