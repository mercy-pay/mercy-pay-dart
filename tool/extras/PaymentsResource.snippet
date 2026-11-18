  /// Reads the payment until it is final (succeeded, failed, canceled, expired…), for a
  /// script or a test. On a server, prefer the payment.succeeded webhook. Throws
  /// [WaitTimeoutException] with the last state when [timeout] passes first.
  Future<Map<String, dynamic>> waitForFinalStatus(String id, {Duration timeout = const Duration(minutes: 2), Duration interval = const Duration(seconds: 2)}) =>
      _poll(() => retrieve(id), const ['succeeded', 'failed', 'canceled', 'expired', 'refunded', 'disputed'], timeout, interval, 'Le paiement $id');
