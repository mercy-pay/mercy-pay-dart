/// Everything this library throws.
class MercyPayException implements Exception {
  MercyPayException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// An error answered by the API. Branch on [code] (stable), never on [message].
/// Quote [requestId] to the Mercy Pay support.
class ApiException extends MercyPayException {
  ApiException(this.status, Map<String, dynamic> body, String? requestId)
      : type = body['type'] as String?,
        code = body['code'] as String?,
        param = body['param'] as String?,
        requestId = (body['request_id'] as String?) ?? requestId,
        errors = (body['errors'] as Map?)?.map((key, value) => MapEntry(key.toString(), (value as List).map((item) => item.toString()).toList())) ?? const {},
        raw = body,
        super((body['message'] as String?) ?? 'Mercy Pay a répondu $status.');

  final int status;
  final String? type;
  final String? code;
  final String? param;
  final String? requestId;
  final Map<String, List<String>> errors;
  final Map<String, dynamic> raw;

  static ApiException from(int status, Object? body, String? requestId) {
    final error = body is Map && body['error'] is Map ? Map<String, dynamic>.from(body['error'] as Map) : <String, dynamic>{};
    final type = error['type'];
    if (type == 'authentication_error' || status == 401) return AuthenticationException(status, error, requestId);
    if (type == 'rate_limit_error' || status == 429) return RateLimitException(status, error, requestId);
    if (type == 'idempotency_error') return IdempotencyException(status, error, requestId);
    if (type == 'payment_error') return PaymentException(status, error, requestId);
    if (status >= 500 || type == 'api_error') return ApiServerException(status, error, requestId);
    return InvalidRequestException(status, error, requestId);
  }
}

/// A missing, wrong or revoked key, or live mode before the account is verified.
class AuthenticationException extends ApiException {
  AuthenticationException(super.status, super.body, super.requestId);
}

/// A refused parameter, an object not found, an action not allowed.
class InvalidRequestException extends ApiException {
  InvalidRequestException(super.status, super.body, super.requestId);
}

/// Refused by the operator or the bank, or a balance too low.
class PaymentException extends ApiException {
  PaymentException(super.status, super.body, super.requestId);
}

/// The idempotency key is missing, reused with other content, or still in use.
class IdempotencyException extends ApiException {
  IdempotencyException(super.status, super.body, super.requestId);
}

/// Too many requests: slow down.
class RateLimitException extends ApiException {
  RateLimitException(super.status, super.body, super.requestId);
}

/// A problem on Mercy Pay's side. Retry later with the same idempotency key.
class ApiServerException extends ApiException {
  ApiServerException(super.status, super.body, super.requestId);
}

/// No answer from Mercy Pay. Send the request again with the same idempotency key.
class ConnectionException extends MercyPayException {
  ConnectionException(super.message);
}

/// A webhook whose signature is missing, wrong or too old: answer 400 and ignore it.
class SignatureVerificationException extends MercyPayException {
  SignatureVerificationException(super.message);
}
