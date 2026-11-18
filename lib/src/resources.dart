// Généré par tool/generate.py depuis la référence de l'API. Ne pas modifier à la main.

import 'client.dart';
import 'errors.dart';
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

  Future<Map<String, dynamic>> _poll(Future<Map<String, dynamic>> Function() read, List<String> finalStatuses, Duration timeout, Duration interval, String what) async {
    final deadline = DateTime.now().add(timeout);
    var delay = interval;
    var current = await read();
    while (!finalStatuses.contains(current['status'])) {
      if (DateTime.now().add(delay).isAfter(deadline)) {
        throw WaitTimeoutException("$what n'a pas atteint de statut final à temps (statut : ${current['status']}).", current);
      }
      await _client.pause(delay);
      final next = (delay.inMilliseconds * 1.5).round();
      delay = Duration(milliseconds: next > 10000 ? 10000 : next);
      current = await read();
    }
    return current;
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
  ///
  /// Paramètres :
  /// - `amount` (int, obligatoire)
  /// - `currency` (String, obligatoire)
  /// - `payment_method` ('mobile_money' | 'card', obligatoire)
  /// - `country` (String)
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
  ///
  /// Paramètres :
  /// - `amount` (int, obligatoire)
  /// - `currency` (String, obligatoire)
  /// - `description` (String)
  /// - `payer_name` (String)
  /// - `payer_email` (String)
  /// - `payer_phone` (String)
  /// - `success_url` (String)
  /// - `cancel_url` (String)
  /// - `payment_method_types` (List)
  /// - `allowed_countries` (List)
  /// - `ui_mode` ('hosted' | 'embedded')
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'checkout_sessions', params, idempotencyKey);

  /// Lister les sessions. GET /api/v1/checkout_sessions
  ///
  /// Paramètres :
  /// - `status` ('created' | 'pending_payment' | 'completed' | 'expired' | 'cancelled')
  /// - `from` (String)
  /// - `to` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('checkout_sessions', params);

  /// Lire une session. GET /api/v1/checkout_sessions/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'checkout_sessions/${Uri.encodeComponent(id)}', params);

  /// Expirer une session. POST /api/v1/checkout_sessions/{id}/expire
  Future<Map<String, dynamic>> expire(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'checkout_sessions/${Uri.encodeComponent(id)}/expire', params, idempotencyKey);

  /// Reads the session until it is completed, expired or cancelled.
  Future<Map<String, dynamic>> waitForCompletion(String id, {Duration timeout = const Duration(minutes: 2), Duration interval = const Duration(seconds: 2)}) =>
      _poll(() => retrieve(id), const ['completed', 'expired', 'cancelled'], timeout, interval, 'La session $id');
}

class PaymentsResource extends _Resource {
  PaymentsResource(super.client);

  /// Encaisser un paiement. POST /api/v1/payments
  ///
  /// Paramètres :
  /// - `amount` (int, obligatoire)
  /// - `currency` (String, obligatoire)
  /// - `payment_method` ('mobile_money' | 'card')
  /// - `country` (String)
  /// - `provider` (String)
  /// - `phone` (String)
  /// - `payer_name` (String)
  /// - `payer_email` (String)
  /// - `description` (String)
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payments', params, idempotencyKey);

  /// Lister les paiements. GET /api/v1/payments
  ///
  /// Paramètres :
  /// - `status` ('pending' | 'processing' | 'succeeded' | 'failed' | 'canceled' | 'expired' | 'refunded' | 'disputed')
  /// - `from` (String)
  /// - `to` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  /// - `expand` (List)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('payments', params);

  /// Lire un paiement. GET /api/v1/payments/{id}
  ///
  /// Paramètres :
  /// - `expand` (List)
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'payments/${Uri.encodeComponent(id)}', params);

  /// Rembourser un paiement. POST /api/v1/payments/{id}/refunds
  ///
  /// Paramètres :
  /// - `amount` (int)
  /// - `reason` (String)
  Future<Map<String, dynamic>> refund(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payments/${Uri.encodeComponent(id)}/refunds', params, idempotencyKey);

  /// Reads the payment until it is final (succeeded, failed, canceled, expired…), for a
  /// script or a test. On a server, prefer the payment.succeeded webhook. Throws
  /// [WaitTimeoutException] with the last state when [timeout] passes first.
  Future<Map<String, dynamic>> waitForFinalStatus(String id, {Duration timeout = const Duration(minutes: 2), Duration interval = const Duration(seconds: 2)}) =>
      _poll(() => retrieve(id), const ['succeeded', 'failed', 'canceled', 'expired', 'refunded', 'disputed'], timeout, interval, 'Le paiement $id');
}

class RefundsResource extends _Resource {
  RefundsResource(super.client);

  /// Lister les remboursements. GET /api/v1/refunds
  ///
  /// Paramètres :
  /// - `payment` (String)
  /// - `status` ('pending' | 'processing' | 'succeeded' | 'failed' | 'canceled')
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('refunds', params);

  /// Lire un remboursement. GET /api/v1/refunds/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'refunds/${Uri.encodeComponent(id)}', params);

  /// Annuler un remboursement retardé. POST /api/v1/refunds/{id}/cancel
  Future<Map<String, dynamic>> cancel(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'refunds/${Uri.encodeComponent(id)}/cancel', params, idempotencyKey);
}

class WalletsResource extends _Resource {
  WalletsResource(super.client);

  /// Lire les soldes. GET /api/v1/wallets
  ///
  /// Paramètres :
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('wallets', params);
}

class WalletTransfersResource extends _Resource {
  WalletTransfersResource(super.client);

  /// Lister les virements entre soldes. GET /api/v1/wallet_transfers
  ///
  /// Paramètres :
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('wallet_transfers', params);

  /// Virer entre deux soldes. POST /api/v1/wallet_transfers
  ///
  /// Paramètres :
  /// - `from_wallet` (String, obligatoire)
  /// - `to_wallet` (String, obligatoire)
  /// - `amount` (int, obligatoire)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'wallet_transfers', params, idempotencyKey);
}

class PayoutsResource extends _Resource {
  PayoutsResource(super.client);

  /// Demander un retrait. POST /api/v1/payouts
  ///
  /// Paramètres :
  /// - `amount` (int, obligatoire)
  /// - `currency` (String, obligatoire)
  /// - `destination_id` (String)
  /// - `destination` (Map)
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payouts', params, idempotencyKey);

  /// Lister les retraits. GET /api/v1/payouts
  ///
  /// Paramètres :
  /// - `status` ('requested' | 'approved' | 'processing' | 'paid' | 'failed' | 'rejected' | 'canceled')
  /// - `currency` (String)
  /// - `from` (String)
  /// - `to` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('payouts', params);

  /// Lire un retrait. GET /api/v1/payouts/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'payouts/${Uri.encodeComponent(id)}', params);
}

class PaymentLinksResource extends _Resource {
  PaymentLinksResource(super.client);

  /// Créer un lien. POST /api/v1/payment_links
  ///
  /// Paramètres :
  /// - `title` (String, obligatoire)
  /// - `description` (String)
  /// - `pricing_mode` ('fixed' | 'flexible' | 'options' | 'cart')
  /// - `amount` (int)
  /// - `minimum_amount` (int)
  /// - `price_options` (List)
  /// - `items` (List)
  /// - `custom_fields_schema` (List)
  /// - `collect_phone` (bool)
  /// - `collect_address` (bool)
  /// - `after_payment_message` (String)
  /// - `max_uses` (int)
  /// - `expires_at` (String)
  /// - `success_url` (String)
  /// - `cancel_url` (String)
  /// - `active` (bool)
  /// - `metadata` (Map)
  /// - `type` ('one_time' | 'recurring')
  /// - `currency` (String)
  /// - `plan` (String)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payment_links', params, idempotencyKey);

  /// Lister les liens. GET /api/v1/payment_links
  ///
  /// Paramètres :
  /// - `active` (bool)
  /// - `type` ('one_time' | 'recurring')
  /// - `archived` (bool)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('payment_links', params);

  /// Lire un lien. GET /api/v1/payment_links/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'payment_links/${Uri.encodeComponent(id)}', params);

  /// Modifier un lien. PATCH /api/v1/payment_links/{id}
  ///
  /// Paramètres :
  /// - `title` (String)
  /// - `description` (String)
  /// - `pricing_mode` ('fixed' | 'flexible' | 'options' | 'cart')
  /// - `amount` (int)
  /// - `minimum_amount` (int)
  /// - `price_options` (List)
  /// - `items` (List)
  /// - `custom_fields_schema` (List)
  /// - `collect_phone` (bool)
  /// - `collect_address` (bool)
  /// - `after_payment_message` (String)
  /// - `max_uses` (int)
  /// - `expires_at` (String)
  /// - `success_url` (String)
  /// - `cancel_url` (String)
  /// - `active` (bool)
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'payment_links/${Uri.encodeComponent(id)}', params);

  /// Supprimer un lien. DELETE /api/v1/payment_links/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'payment_links/${Uri.encodeComponent(id)}', params);

  /// Archiver un lien. POST /api/v1/payment_links/{id}/archive
  Future<Map<String, dynamic>> archive(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'payment_links/${Uri.encodeComponent(id)}/archive', params, idempotencyKey);

  /// Paiements d'un lien. GET /api/v1/payment_links/{id}/payments
  ///
  /// Paramètres :
  /// - `status` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> payments(String id, [Map<String, Object?> params = const {}]) => _list('payment_links/${Uri.encodeComponent(id)}/payments', params);
}

class PlansResource extends _Resource {
  PlansResource(super.client);

  /// Créer un plan. POST /api/v1/plans
  ///
  /// Paramètres :
  /// - `name` (String, obligatoire)
  /// - `amount` (int, obligatoire)
  /// - `currency` (String, obligatoire)
  /// - `interval` ('daily' | 'weekly' | 'monthly' | 'yearly', obligatoire)
  /// - `interval_count` (int)
  /// - `trial_period_days` (int)
  /// - `description` (String)
  /// - `portal_switchable` (bool)
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'plans', params, idempotencyKey);

  /// Lister les plans. GET /api/v1/plans
  ///
  /// Paramètres :
  /// - `status` ('active' | 'archived')
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('plans', params);

  /// Lire un plan. GET /api/v1/plans/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'plans/${Uri.encodeComponent(id)}', params);

  /// Modifier un plan. PATCH /api/v1/plans/{id}
  ///
  /// Paramètres :
  /// - `name` (String)
  /// - `description` (String)
  /// - `portal_switchable` (bool)
  /// - `metadata` (Map)
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
  ///
  /// Paramètres :
  /// - `email` (String, obligatoire)
  /// - `name` (String)
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'customers', params, idempotencyKey);

  /// Lister les clients. GET /api/v1/customers
  ///
  /// Paramètres :
  /// - `email` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('customers', params);

  /// Lire un client. GET /api/v1/customers/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'customers/${Uri.encodeComponent(id)}', params);

  /// Modifier un client. PATCH /api/v1/customers/{id}
  ///
  /// Paramètres :
  /// - `email` (String)
  /// - `name` (String)
  /// - `metadata` (Map)
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'customers/${Uri.encodeComponent(id)}', params);

  /// Supprimer un client. DELETE /api/v1/customers/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'customers/${Uri.encodeComponent(id)}', params);

  /// Moyens de paiement d'un client. GET /api/v1/customers/{id}/payment_methods
  ///
  /// Paramètres :
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  Future<Page> paymentMethods(String customerId, [Map<String, Object?> params = const {}]) => _list('customers/${Uri.encodeComponent(customerId)}/payment_methods', params);

  /// Choisir le moyen par défaut. POST /api/v1/customers/{id}/payment_methods/{id}/default
  Future<Map<String, dynamic>> setDefaultPaymentMethod(String customerId, String paymentMethodId, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'customers/${Uri.encodeComponent(customerId)}/payment_methods/${Uri.encodeComponent(paymentMethodId)}/default', params, idempotencyKey);

  /// Retirer un moyen de paiement. DELETE /api/v1/customers/{id}/payment_methods/{id}
  Future<Map<String, dynamic>> removePaymentMethod(String customerId, String paymentMethodId, [Map<String, Object?> params = const {}]) => _object('DELETE', 'customers/${Uri.encodeComponent(customerId)}/payment_methods/${Uri.encodeComponent(paymentMethodId)}', params);
}

class SubscriptionsResource extends _Resource {
  SubscriptionsResource(super.client);

  /// Créer un abonnement. POST /api/v1/subscriptions
  ///
  /// Paramètres :
  /// - `customer_name` (String, obligatoire)
  /// - `customer_email` (String, obligatoire)
  /// - `payment_method` ('card' | 'mobile_money')
  /// - `customer_phone` (String)
  /// - `customer_country` (String)
  /// - `customer_provider` (String)
  /// - `max_cycles` (int)
  /// - `metadata` (Map)
  /// - `plan` (String, obligatoire)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions', params, idempotencyKey);

  /// Lister les abonnements. GET /api/v1/subscriptions
  ///
  /// Paramètres :
  /// - `status` ('incomplete' | 'trialing' | 'active' | 'past_due' | 'unpaid' | 'paused' | 'canceled')
  /// - `customer_email` (String)
  /// - `plan` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  /// - `expand` (List)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('subscriptions', params);

  /// Lire un abonnement. GET /api/v1/subscriptions/{id}
  ///
  /// Paramètres :
  /// - `expand` (List)
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'subscriptions/${Uri.encodeComponent(id)}', params);

  /// Modifier un abonnement. PATCH /api/v1/subscriptions/{id}
  ///
  /// Paramètres :
  /// - `max_cycles` (int)
  /// - `customer_name` (String)
  /// - `customer_phone` (String)
  /// - `customer_country` (String)
  /// - `customer_provider` (String)
  /// - `metadata` (Map)
  /// - `plan` (String)
  Future<Map<String, dynamic>> update(String id, [Map<String, Object?> params = const {}]) => _object('PATCH', 'subscriptions/${Uri.encodeComponent(id)}', params);

  /// Annuler un abonnement. POST /api/v1/subscriptions/{id}/cancel
  ///
  /// Paramètres :
  /// - `at_period_end` (bool)
  Future<Map<String, dynamic>> cancel(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/cancel', params, idempotencyKey);

  /// Retirer une annulation prévue. POST /api/v1/subscriptions/{id}/reactivate
  Future<Map<String, dynamic>> reactivate(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/reactivate', params, idempotencyKey);

  /// Passer à l'échéance (sandbox). POST /api/v1/subscriptions/{id}/advance
  Future<Map<String, dynamic>> advance(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/advance', params, idempotencyKey);

  /// Mettre en pause. POST /api/v1/subscriptions/{id}/pause
  ///
  /// Paramètres :
  /// - `resumes_at` (String)
  Future<Map<String, dynamic>> pause(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/pause', params, idempotencyKey);

  /// Reprendre. POST /api/v1/subscriptions/{id}/resume
  Future<Map<String, dynamic>> resume(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'subscriptions/${Uri.encodeComponent(id)}/resume', params, idempotencyKey);

  /// Factures d'un abonnement. GET /api/v1/subscriptions/{id}/invoices
  ///
  /// Paramètres :
  /// - `status` ('pending' | 'paid' | 'failed' | 'canceled')
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  /// - `expand` (List)
  Future<Page> invoices(String id, [Map<String, Object?> params = const {}]) => _list('subscriptions/${Uri.encodeComponent(id)}/invoices', params);
}

class InvoicesResource extends _Resource {
  InvoicesResource(super.client);

  /// Lister les factures. GET /api/v1/invoices
  ///
  /// Paramètres :
  /// - `status` ('pending' | 'paid' | 'failed' | 'canceled')
  /// - `subscription` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  /// - `created[gte]` (String)
  /// - `created[lte]` (String)
  /// - `expand` (List)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('invoices', params);

  /// Lire une facture. GET /api/v1/invoices/{id}
  ///
  /// Paramètres :
  /// - `expand` (List)
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'invoices/${Uri.encodeComponent(id)}', params);

  /// Encaisser une facture. POST /api/v1/invoices/{id}/pay
  Future<Map<String, dynamic>> pay(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'invoices/${Uri.encodeComponent(id)}/pay', params, idempotencyKey);

  /// Envoyer la facture au client. POST /api/v1/invoices/{id}/send
  Future<Map<String, dynamic>> send(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'invoices/${Uri.encodeComponent(id)}/send', params, idempotencyKey);
}

class BillingPortalResource extends _Resource {
  BillingPortalResource(super.client);

  /// Ouvrir l'espace client. POST /api/v1/billing_portal/sessions
  ///
  /// Paramètres :
  /// - `customer_email` (String, obligatoire)
  /// - `return_url` (String)
  Future<Map<String, dynamic>> createSession({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'billing_portal/sessions', params, idempotencyKey);
}

class EventsResource extends _Resource {
  EventsResource(super.client);

  /// Lister les événements. GET /api/v1/events
  ///
  /// Paramètres :
  /// - `type` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('events', params);

  /// Lire un événement. GET /api/v1/events/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'events/${Uri.encodeComponent(id)}', params);

  /// Lister les envois d'un événement. GET /api/v1/events/{id}/deliveries
  ///
  /// Paramètres :
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  Future<Page> deliveries(String id, [Map<String, Object?> params = const {}]) => _list('events/${Uri.encodeComponent(id)}/deliveries', params);

  /// Renvoyer un événement. POST /api/v1/events/{id}/resend
  ///
  /// Paramètres :
  /// - `webhook_endpoint` (String, obligatoire)
  Future<Map<String, dynamic>> resend(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'events/${Uri.encodeComponent(id)}/resend', params, idempotencyKey);
}

class WebhookEndpointsResource extends _Resource {
  WebhookEndpointsResource(super.client);

  /// Créer un endpoint. POST /api/v1/webhook_endpoints
  ///
  /// Paramètres :
  /// - `url` (String, obligatoire)
  /// - `events` (List, obligatoire)
  /// - `environment` ('sandbox' | 'live')
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'webhook_endpoints', params, idempotencyKey);

  /// Lister les endpoints. GET /api/v1/webhook_endpoints
  ///
  /// Paramètres :
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('webhook_endpoints', params);

  /// Lire un endpoint. GET /api/v1/webhook_endpoints/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'webhook_endpoints/${Uri.encodeComponent(id)}', params);

  /// Modifier un endpoint. PATCH /api/v1/webhook_endpoints/{id}
  ///
  /// Paramètres :
  /// - `url` (String)
  /// - `events` (List)
  /// - `environment` ('sandbox' | 'live')
  /// - `status` ('enabled' | 'disabled')
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
  ///
  /// Paramètres :
  /// - `status` ('success' | 'error')
  /// - `method` ('GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE')
  /// - `path` (String)
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('request_logs', params);
}

class TestHelpersResource extends _Resource {
  TestHelpersResource(super.client);

  /// Déclencher un événement de test. POST /api/v1/test_helpers/events
  ///
  /// Paramètres :
  /// - `type` ('payment.succeeded' | 'payment.failed' | 'payment.refunded' | 'payment.disputed' | 'payment.dispute_closed' | 'refund.succeeded' | 'refund.failed' | 'refund.canceled' | 'payout.paid' | 'payout.failed' | 'payout.canceled' | 'subscription.created' | 'subscription.updated' | 'subscription.past_due' | 'subscription.unpaid' | 'subscription.paused' | 'subscription.resumed' | 'subscription.canceled' | 'invoice.created' | 'invoice.upcoming' | 'invoice.paid' | 'invoice.canceled' | 'invoice.payment_failed' | 'checkout_session.completed' | 'provider_status.changed' | 'account.updated', obligatoire)
  Future<Map<String, dynamic>> triggerEvent({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'test_helpers/events', params, idempotencyKey);

  /// Lister les numéros de test mobile money. GET /api/v1/test_helpers/mobile_money_numbers
  ///
  /// Paramètres :
  /// - `country` (String)
  /// - `provider` (String)
  Future<Page> mobileMoneyNumbers([Map<String, Object?> params = const {}]) => _list('test_helpers/mobile_money_numbers', params);

  /// The sandbox number giving this outcome for this operator, or null when it has none.
  /// [outcome] is succeeded, pending, payout_failed, or a failure_code such as
  /// insufficient_balance.
  Future<String?> mobileMoneyNumber(String provider, [String outcome = 'succeeded']) async {
    final page = await mobileMoneyNumbers({'provider': provider});
    for (final number in page.data) {
      final matches = outcome == 'payout_failed'
          ? number['applies_to'] == 'payout'
          : number['applies_to'] == 'payment' && (number['outcome'] == outcome || number['failure_code'] == outcome);
      if (matches) {
        return number['phone'] as String?;
      }
    }
    return null;
  }
}

class EmbedDomainsResource extends _Resource {
  EmbedDomainsResource(super.client);

  /// Ajouter un site. POST /api/v1/embed_domains
  ///
  /// Paramètres :
  /// - `hostname` (String, obligatoire)
  Future<Map<String, dynamic>> create({Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'embed_domains', params, idempotencyKey);

  /// Lister les sites autorisés. GET /api/v1/embed_domains
  ///
  /// Paramètres :
  /// - `limit` (int)
  /// - `starting_after` (String)
  /// - `ending_before` (String)
  Future<Page> list([Map<String, Object?> params = const {}]) => _list('embed_domains', params);

  /// Lire un site autorisé. GET /api/v1/embed_domains/{id}
  Future<Map<String, dynamic>> retrieve(String id, [Map<String, Object?> params = const {}]) => _object('GET', 'embed_domains/${Uri.encodeComponent(id)}', params);

  /// Retirer un site. DELETE /api/v1/embed_domains/{id}
  Future<Map<String, dynamic>> delete(String id, [Map<String, Object?> params = const {}]) => _object('DELETE', 'embed_domains/${Uri.encodeComponent(id)}', params);

  /// Vérifier un site maintenant. POST /api/v1/embed_domains/{id}/verify
  Future<Map<String, dynamic>> verify(String id, {Map<String, Object?> params = const {}, String? idempotencyKey}) => _object('POST', 'embed_domains/${Uri.encodeComponent(id)}/verify', params, idempotencyKey);
}
