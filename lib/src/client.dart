import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'errors.dart';
import 'resources.dart';

const version = '0.2.0';

/// The entry point: one client per API key. For your Dart server only: an app never holds
/// the key (see mercy_pay_flutter).
///
/// ```dart
/// final mercyPay = MercyPay(Platform.environment['MERCY_PAY_API_KEY']!);
/// final session = await mercyPay.checkoutSessions.create(params: {'amount': 15000, 'currency': 'XAF'});
/// ```
///
/// A network error, a 429 or a 5xx is retried; a POST always carries an Idempotency-Key, the
/// same on every attempt, so a retry never creates twice.
class MercyPay {
  MercyPay(
    this._apiKey, {
    String baseUrl = 'https://mercy-pay.com',
    this.timeout = const Duration(seconds: 30),
    int maxRetries = 2,
    http.Client? httpClient,
    Future<void> Function(Duration)? sleep,
  })  : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _maxRetries = max(0, maxRetries),
        _http = httpClient ?? http.Client(),
        _sleep = sleep ?? ((duration) => Future<void>.delayed(duration)) {
    if (_apiKey.isEmpty) {
      throw ArgumentError('Clé API manquante : passez votre clé mp_sandbox_… ou mp_live_….');
    }
  }

  final String _apiKey;
  final String _baseUrl;
  final Duration timeout;
  final int _maxRetries;
  final http.Client _http;
  final Future<void> Function(Duration) _sleep;

  /// Waits between two reads (waitForFinalStatus). Replaced in tests through `sleep`.
  Future<void> pause(Duration duration) => _sleep(duration);

  late final account = AccountResource(this);
  late final billingPortal = BillingPortalResource(this);
  late final checkoutSessions = CheckoutSessionsResource(this);
  late final customers = CustomersResource(this);
  late final embedDomains = EmbedDomainsResource(this);
  late final events = EventsResource(this);
  late final fees = FeesResource(this);
  late final invoices = InvoicesResource(this);
  late final paymentLinks = PaymentLinksResource(this);
  late final payments = PaymentsResource(this);
  late final payouts = PayoutsResource(this);
  late final plans = PlansResource(this);
  late final providerStatus = ProviderStatusResource(this);
  late final refunds = RefundsResource(this);
  late final requestLogs = RequestLogsResource(this);
  late final subscriptions = SubscriptionsResource(this);
  late final testHelpers = TestHelpersResource(this);
  late final wallets = WalletsResource(this);
  late final walletTransfers = WalletTransfersResource(this);
  late final webhookEndpoints = WebhookEndpointsResource(this);

  /// Any call, for an endpoint this version does not know yet. GET and DELETE send [params]
  /// in the query string, the others as JSON.
  Future<Map<String, dynamic>> request(String method, String path, {Map<String, Object?> params = const {}, String? idempotencyKey}) async {
    final verb = method.toUpperCase();
    final clean = path.replaceFirst(RegExp(r'^/+'), '').replaceFirst(RegExp(r'^(api/)?v1/'), '');
    var url = '$_baseUrl/api/v1/$clean';
    final headers = <String, String>{
      'Authorization': 'Bearer $_apiKey',
      'Accept': 'application/json',
      'User-Agent': 'mercy-pay-dart/$version',
    };
    String? body;

    if (verb == 'GET' || verb == 'DELETE') {
      final query = encodeQuery(params);
      if (query.isNotEmpty) url += '?$query';
    } else {
      body = jsonEncode(params);
      headers['Content-Type'] = 'application/json';
    }
    if (verb == 'POST') headers['Idempotency-Key'] = idempotencyKey ?? 'dart_${_randomHex(16)}';

    for (var attempt = 0;; attempt++) {
      final http.Response response;
      try {
        final request = http.Request(verb, Uri.parse(url))..headers.addAll(headers);
        if (body != null) request.body = body;
        response = await http.Response.fromStream(await _http.send(request).timeout(timeout));
      } on Exception catch (error) {
        if (attempt >= _maxRetries) throw ConnectionException("Mercy Pay n'a pas pu être joint : $error");
        await _sleep(_backoff(attempt + 1, null));
        continue;
      }

      if ((response.statusCode == 429 || response.statusCode >= 500) && attempt < _maxRetries) {
        await _sleep(_backoff(attempt + 1, response.headers['retry-after']));
        continue;
      }

      Object? decoded = <String, dynamic>{};
      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(utf8.decode(response.bodyBytes));
        } on FormatException {
          decoded = <String, dynamic>{};
        }
      }
      if (response.statusCode >= 400) throw ApiException.from(response.statusCode, decoded, response.headers['request-id']);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    }
  }

  void close() => _http.close();

  Duration _backoff(int attempt, String? retryAfter) {
    final seconds = int.tryParse(retryAfter ?? '');
    if (seconds != null && seconds >= 0) return Duration(seconds: min(seconds, 60));
    return Duration(milliseconds: 500 * (1 << (attempt - 1)));
  }

  static String _randomHex(int bytes) {
    final random = Random.secure();
    return List.generate(bytes, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Nested parameters the way the API reads them: created[gte]=…, expand[]=…
String encodeQuery(Map<String, Object?> params) {
  final pairs = <String>[];
  void add(String key, Object? value) {
    if (value == null) return;
    if (value is List) {
      for (final item in value) {
        add('$key[]', item);
      }
    } else if (value is Map) {
      value.forEach((child, nested) => add('$key[$child]', nested));
    } else {
      pairs.add('${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value.toString())}');
    }
  }

  params.forEach(add);
  return pairs.join('&');
}
