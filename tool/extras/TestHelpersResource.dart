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
