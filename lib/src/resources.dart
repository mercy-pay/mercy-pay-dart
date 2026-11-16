// Généré par tool/generate.py depuis la référence de l'API. Ne pas modifier à la main.

import 'client.dart';
import 'page.dart';

abstract class _Resource {
  _Resource(this._client);

  final MercyPay _client;

  Future<Map<String, dynamic>> _object(String method, String path, Map<String, Object?> params, [String? idempotencyKey]) async {
    final body = await _client.request(method, path, params: params, idempotencyKey: idempotencyKey);
    final data = body['data'];
    return data is Map ? Map<String, dynamic>.from(data) : body;
  }

  Future<Page> _list(String path, Map<String, Object?> params) async {
    final body = await _client.request('GET', path, params: params);
    return Page(body, (next) => _list(path, next), params);
  }
}

class AccountResource extends _Resource {
  AccountResource(super.client);

  /// Lire le compte. GET /api/v1/account
  Future<Map<String, dynamic>> retrieve([Map<String, Object?> params = const {}]) => _object('GET', 'account', params);
}

class FeesResource extends _Resource {
  FeesResource(super.client);

  /// Calculer les frais d'un paiement. POST /api/v1/fees/quote
  Future<Map<String, dynamic>> quote({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'fees/quote', params, idempotencyKey);
}

class ProviderStatusResource extends _Resource {
  ProviderStatusResource(super.client);

  /// État des opérateurs. GET /api/v1/provider_status
  Future<Map<String, dynamic>> retrieve([Map<String, Object?> params = const {}]) => _object('GET', 'provider_status', params);
}

class CheckoutSessionsResource extends _Resource {
  CheckoutSessionsResource(super.client);

  /// Créer une session. POST /api/v1/checkout_sessions
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'checkout_sessions', params, idempotencyKey);

  /// Lister les sessions. GET /api/v1/checkout_sessions
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('checkout_sessions', params);

  /// Lire une session. GET /api/v1/checkout_sessions/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'checkout_sessions/${Uri.encodeComponent(id)}', params);

  /// Expirer une session. POST /api/v1/checkout_sessions/{id}/expire
  Future<Map<String, dynamic>> expire(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'checkout_sessions/${Uri.encodeComponent(id)}/expire', params, idempotencyKey);
}

class PaymentsResource extends _Resource {
  PaymentsResource(super.client);

  /// Encaisser un paiement. POST /api/v1/payments
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payments', params, idempotencyKey);

  /// Lister les paiements. GET /api/v1/payments
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('payments', params);

  /// Lire un paiement. GET /api/v1/payments/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'payments/${Uri.encodeComponent(id)}', params);

  /// Rembourser un paiement. POST /api/v1/payments/{id}/refunds
  Future<Map<String, dynamic>> refund(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payments/${Uri.encodeComponent(id)}/refunds', params, idempotencyKey);
}

class RefundsResource extends _Resource {
  RefundsResource(super.client);

  /// Lister les remboursements. GET /api/v1/refunds
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('refunds', params);

  /// Lire un remboursement. GET /api/v1/refunds/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'refunds/${Uri.encodeComponent(id)}', params);

  /// Annuler un remboursement retardé. POST /api/v1/refunds/{id}/cancel
  Future<Map<String, dynamic>> cancel(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'refunds/${Uri.encodeComponent(id)}/cancel', params, idempotencyKey);
}

class WalletsResource extends _Resource {
  WalletsResource(super.client);

  /// Lire les soldes. GET /api/v1/wallets
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('wallets', params);
}

class WalletTransfersResource extends _Resource {
  WalletTransfersResource(super.client);

  /// Lister les virements entre soldes. GET /api/v1/wallet_transfers
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('wallet_transfers', params);

  /// Virer entre deux soldes. POST /api/v1/wallet_transfers
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'wallet_transfers', params, idempotencyKey);
}

class PayoutsResource extends _Resource {
  PayoutsResource(super.client);

  /// Demander un retrait. POST /api/v1/payouts
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payouts', params, idempotencyKey);

  /// Lister les retraits. GET /api/v1/payouts
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('payouts', params);

  /// Lire un retrait. GET /api/v1/payouts/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'payouts/${Uri.encodeComponent(id)}', params);
}

class PaymentLinksResource extends _Resource {
  PaymentLinksResource(super.client);

  /// Créer un lien. POST /api/v1/payment_links
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payment_links', params, idempotencyKey);

  /// Lister les liens. GET /api/v1/payment_links
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('payment_links', params);

  /// Lire un lien. GET /api/v1/payment_links/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'payment_links/${Uri.encodeComponent(id)}', params);

  /// Modifier un lien. PATCH /api/v1/payment_links/{id}
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'payment_links/${Uri.encodeComponent(id)}', params);

  /// Supprimer un lien. DELETE /api/v1/payment_links/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'payment_links/${Uri.encodeComponent(id)}', params);

  /// Archiver un lien. POST /api/v1/payment_links/{id}/archive
  Future<Map<String, dynamic>> archive(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payment_links/${Uri.encodeComponent(id)}/archive', params, idempotencyKey);

  /// Paiements d'un lien. GET /api/v1/payment_links/{id}/payments
  Future<Page> payments(String id, [Map<String, Object?> params = const {}]) => _list('payment_links/${Uri.encodeComponent(id)}/payments', params);
}

class PlansResource extends _Resource {
  PlansResource(super.client);

  /// Créer un plan. POST /api/v1/plans
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'plans', params, idempotencyKey);

  /// Lister les plans. GET /api/v1/plans
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('plans', params);

  /// Lire un plan. GET /api/v1/plans/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'plans/${Uri.encodeComponent(id)}', params);

  /// Modifier un plan. PATCH /api/v1/plans/{id}
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'plans/${Uri.encodeComponent(id)}', params);

  /// Supprimer un plan. DELETE /api/v1/plans/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'plans/${Uri.encodeComponent(id)}', params);

  /// Archiver un plan. POST /api/v1/plans/{id}/archive
  Future<Map<String, dynamic>> archive(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'plans/${Uri.encodeComponent(id)}/archive', params, idempotencyKey);

  /// Réactiver un plan. POST /api/v1/plans/{id}/restore
  Future<Map<String, dynamic>> restore(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'plans/${Uri.encodeComponent(id)}/restore', params, idempotencyKey);
}

class CustomersResource extends _Resource {
  CustomersResource(super.client);

  /// Créer un client. POST /api/v1/customers
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'customers', params, idempotencyKey);

  /// Lister les clients. GET /api/v1/customers
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('customers', params);

  /// Lire un client. GET /api/v1/customers/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'customers/${Uri.encodeComponent(id)}', params);

  /// Modifier un client. PATCH /api/v1/customers/{id}
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'customers/${Uri.encodeComponent(id)}', params);

  /// Supprimer un client. DELETE /api/v1/customers/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'customers/${Uri.encodeComponent(id)}', params);

  /// Moyens de paiement d'un client. GET /api/v1/customers/{id}/payment_methods
  Future<Page> paymentMethods(String customerId, [Map<String, Object?> params = const {}]) => _list('customers/${Uri.encodeComponent(customerId)}/payment_methods', params);

  /// Choisir le moyen par défaut. POST /api/v1/customers/{id}/payment_methods/{id}/default
  Future<Map<String, dynamic>> setDefaultPaymentMethod(String customerId, String paymentMethodId, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'customers/${Uri.encodeComponent(customerId)}/payment_methods/${Uri.encodeComponent(paymentMethodId)}/default', params, idempotencyKey);

  /// Retirer un moyen de paiement. DELETE /api/v1/customers/{id}/payment_methods/{id}
  Future<Map<String, dynamic>> removePaymentMethod(String customerId, String paymentMethodId, [Map<String, Object?> params = const {}]) => _object('DELETE', 'customers/${Uri.encodeComponent(customerId)}/payment_methods/${Uri.encodeComponent(paymentMethodId)}', params);
}

class SubscriptionsResource extends _Resource {
  SubscriptionsResource(super.client);

  /// Créer un abonnement. POST /api/v1/subscriptions
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions', params, idempotencyKey);

  /// Lister les abonnements. GET /api/v1/subscriptions
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('subscriptions', params);

  /// Lire un abonnement. GET /api/v1/subscriptions/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'subscriptions/${Uri.encodeComponent(id)}', params);

  /// Modifier un abonnement. PATCH /api/v1/subscriptions/{id}
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'subscriptions/${Uri.encodeComponent(id)}', params);

  /// Annuler un abonnement. POST /api/v1/subscriptions/{id}/cancel
  Future<Map<String, dynamic>> cancel(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/cancel', params, idempotencyKey);

  /// Retirer une annulation prévue. POST /api/v1/subscriptions/{id}/reactivate
  Future<Map<String, dynamic>> reactivate(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/reactivate', params, idempotencyKey);

  /// Passer à l'échéance (sandbox). POST /api/v1/subscriptions/{id}/advance
  Future<Map<String, dynamic>> advance(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/advance', params, idempotencyKey);

  /// Mettre en pause. POST /api/v1/subscriptions/{id}/pause
  Future<Map<String, dynamic>> pause(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/pause', params, idempotencyKey);

  /// Reprendre. POST /api/v1/subscriptions/{id}/resume
  Future<Map<String, dynamic>> resume(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/resume', params, idempotencyKey);

  /// Factures d'un abonnement. GET /api/v1/subscriptions/{id}/invoices
  Future<Page> invoices(String id, [Map<String, Object?> params = const {}]) => _list('subscriptions/${Uri.encodeComponent(id)}/invoices', params);
}

class InvoicesResource extends _Resource {
  InvoicesResource(super.client);

  /// Lister les factures. GET /api/v1/invoices
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('invoices', params);

  /// Lire une facture. GET /api/v1/invoices/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'invoices/${Uri.encodeComponent(id)}', params);

  /// Encaisser une facture. POST /api/v1/invoices/{id}/pay
  Future<Map<String, dynamic>> pay(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'invoices/${Uri.encodeComponent(id)}/pay', params, idempotencyKey);

  /// Envoyer la facture au client. POST /api/v1/invoices/{id}/send
  Future<Map<String, dynamic>> send(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'invoices/${Uri.encodeComponent(id)}/send', params, idempotencyKey);
}

class BillingPortalResource extends _Resource {
  BillingPortalResource(super.client);

  /// Ouvrir l'espace client. POST /api/v1/billing_portal/sessions
  Future<Map<String, dynamic>> createSession({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'billing_portal/sessions', params, idempotencyKey);
}

class EventsResource extends _Resource {
  EventsResource(super.client);

  /// Lister les événements. GET /api/v1/events
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('events', params);

  /// Lire un événement. GET /api/v1/events/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'events/${Uri.encodeComponent(id)}', params);

  /// Lister les envois d'un événement. GET /api/v1/events/{id}/deliveries
  Future<Page> deliveries(String id, [Map<String, Object?> params = const {}]) => _list('events/${Uri.encodeComponent(id)}/deliveries', params);

  /// Renvoyer un événement. POST /api/v1/events/{id}/resend
  Future<Map<String, dynamic>> resend(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'events/${Uri.encodeComponent(id)}/resend', params, idempotencyKey);
}

class WebhookEndpointsResource extends _Resource {
  WebhookEndpointsResource(super.client);

  /// Créer un endpoint. POST /api/v1/webhook_endpoints
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'webhook_endpoints', params, idempotencyKey);

  /// Lister les endpoints. GET /api/v1/webhook_endpoints
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('webhook_endpoints', params);

  /// Lire un endpoint. GET /api/v1/webhook_endpoints/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'webhook_endpoints/${Uri.encodeComponent(id)}', params);

  /// Modifier un endpoint. PATCH /api/v1/webhook_endpoints/{id}
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'webhook_endpoints/${Uri.encodeComponent(id)}', params);

  /// Supprimer un endpoint. DELETE /api/v1/webhook_endpoints/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'webhook_endpoints/${Uri.encodeComponent(id)}', params);

  /// Changer le secret. POST /api/v1/webhook_endpoints/{id}/rotate_secret
  Future<Map<String, dynamic>> rotateSecret(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'webhook_endpoints/${Uri.encodeComponent(id)}/rotate_secret', params, idempotencyKey);

  /// Envoyer un test. POST /api/v1/webhook_endpoints/{id}/test
  Future<Map<String, dynamic>> test(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'webhook_endpoints/${Uri.encodeComponent(id)}/test', params, idempotencyKey);
}

class RequestLogsResource extends _Resource {
  RequestLogsResource(super.client);

  /// Lister les requêtes. GET /api/v1/request_logs
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('request_logs', params);
}

class TestHelpersResource extends _Resource {
  TestHelpersResource(super.client);

  /// Déclencher un événement de test. POST /api/v1/test_helpers/events
  Future<Map<String, dynamic>> triggerEvent({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'test_helpers/events', params, idempotencyKey);
}
