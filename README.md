# Mercy Pay pour Dart

La bibliothèque Dart officielle de l'API [Mercy Pay](https://mercy-pay.com), pour vos **serveurs** Dart (Shelf, Dart Frog, Serverpod…).

Pour une app Flutter, prenez [`mercy_pay_flutter`](https://github.com/mercy-pay/mercy-pay-flutter) : une app ne doit jamais contenir votre clé API.

```sh
dart pub add mercy_pay
```

## Encaisser un paiement

```dart
import 'dart:io';
import 'package:mercy_pay/mercy_pay.dart';

final mercyPay = MercyPay(Platform.environment['MERCY_PAY_API_KEY']!);

final session = await mercyPay.checkoutSessions.create(
  params: {
    'amount': 15000,
    'currency': 'XAF',
    'success_url': 'https://boutique.example/merci',
    'metadata': {'order_id': '4821'},
  },
  idempotencyKey: 'order-4821',
);

// Renvoyez session['checkout_url'] à votre app ou à votre site.
```

Les montants sont en unités mineures. Chaque objet est une `Map<String, dynamic>`.

## Recevoir les webhooks

```dart
// Shelf
Future<Response> webhook(Request request) async {
  final payload = await request.readAsString();
  final Map<String, dynamic> event;
  try {
    event = constructEvent(payload, request.headers['mercypay-signature'], Platform.environment['MERCY_PAY_WEBHOOK_SECRET']!);
  } on SignatureVerificationException {
    return Response(400);
  }

  if (event['type'] == 'payment.succeeded') {
    // Marquez la commande comme payée.
  }
  return Response.ok('{"received":true}');
}
```

Passez le corps brut. Un même événement peut arriver deux fois : servez-vous de `event['id']`.

## Listes

```dart
final page = await mercyPay.payments.list({'limit': 100, 'status': 'succeeded'});
await for (final payment in page.autoPaging()) {
  // Toutes les pages, chargées au fur et à mesure.
}
```

## Erreurs

```dart
try {
  await mercyPay.payouts.create(params: params, idempotencyKey: 'payout-$id');
} on InvalidRequestException catch (error) {
  error.code;  // validation_failed, insufficient_balance…
  error.param; // le champ en cause
} on PaymentException {
  // Refusé par l'opérateur ou la banque.
} on ConnectionException {
  // Pas de réponse : relancez avec la même idempotencyKey.
}
```

Toutes les erreurs de l'API héritent de `ApiException` (`status`, `type`, `code`, `param`, `requestId`, `errors`).

## Nouvelles tentatives et idempotence

Une coupure réseau, un `429` ou une erreur `5xx` sont retentés deux fois. Chaque `POST` porte une `Idempotency-Key`, la même à chaque tentative : un paiement ou un retrait n'est jamais créé en double.

## Attendre le résultat

Pour un script ou un test, attendez qu'un paiement ait un statut final :

```dart
final payment = await mercyPay.payments.waitForFinalStatus(id, timeout: const Duration(minutes: 1));
final session = await mercyPay.checkoutSessions.waitForCompletion(sessionId);
```

La lecture se répète, de plus en plus espacée. Passé le délai, `WaitTimeoutException` donne le dernier état dans `last`. Sur un serveur en production, préférez le webhook `payment.succeeded`.

## Sandbox et catalogue

Une clé `mp_sandbox_…` ne touche pas à l'argent réel. Les opérateurs, les pays et les types d'événements sont dans `MercyPayCatalog`, et le numéro de test qui produit un résultat se lit ainsi :

```dart
final phone = await mercyPay.testHelpers.mobileMoneyNumber(MercyPayCatalog.orangeCmr, 'insufficient_balance');
```

Les résultats possibles : `succeeded`, `pending`, `payout_failed`, ou un `failure_code` comme `insufficient_balance`. La documentation de chaque méthode liste les paramètres qu'elle accepte.

## Développement

`test/openapi.json` est une copie de la référence de l'API : `python3 tool/generate.py` régénère les ressources, et un test vérifie que chaque endpoint a sa méthode.
