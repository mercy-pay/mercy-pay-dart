// Généré par tool/generate.py depuis le catalogue Mercy Pay. Ne pas modifier à la main.

/// The open countries, their mobile money operators and the webhook event types. A new
/// operator may appear before this list knows it: any code stays accepted.
abstract final class MercyPayCatalog {
  static const countries = <String, ({String name, String currency, Map<String, String> providers})>{
    'CMR': (name: 'Cameroun', currency: 'XAF', providers: {'MTN_MOMO_CMR': 'MTN Mobile Money', 'ORANGE_CMR': 'Orange Money'}),
    'COG': (name: 'Congo', currency: 'XAF', providers: {'MTN_MOMO_COG': 'MTN Mobile Money', 'AIRTEL_COG': 'Airtel Money'}),
    'GAB': (name: 'Gabon', currency: 'XAF', providers: {'AIRTEL_GAB': 'Airtel Money', 'MOOV_GAB': 'Moov Money'}),
    'BEN': (name: 'Bénin', currency: 'XOF', providers: {'MTN_MOMO_BEN': 'MTN Mobile Money', 'MOOV_BEN': 'Moov Money'}),
    'CIV': (name: 'Côte d\'Ivoire', currency: 'XOF', providers: {'MTN_MOMO_CIV': 'MTN Mobile Money', 'ORANGE_CIV': 'Orange Money', 'MOOV_CIV': 'Moov Money'}),
    'SEN': (name: 'Sénégal', currency: 'XOF', providers: {'FREE_SEN': 'Free Money', 'ORANGE_SEN': 'Orange Money'}),
    'COD': (name: 'RD Congo', currency: 'CDF', providers: {'VODACOM_MPESA_COD': 'M-Pesa', 'AIRTEL_COD': 'Airtel Money', 'ORANGE_COD': 'Orange Money'}),
    'RWA': (name: 'Rwanda', currency: 'RWF', providers: {'AIRTEL_RWA': 'Airtel Money', 'MTN_MOMO_RWA': 'MTN Mobile Money'}),
    'SLE': (name: 'Sierra Leone', currency: 'SLE', providers: {'ORANGE_SLE': 'Orange Money'}),
    'UGA': (name: 'Ouganda', currency: 'UGX', providers: {'AIRTEL_OAPI_UGA': 'Airtel Money', 'MTN_MOMO_UGA': 'MTN Mobile Money'}),
    'ZMB': (name: 'Zambie', currency: 'ZMW', providers: {'MTN_MOMO_ZMB': 'MTN Mobile Money', 'AIRTEL_OAPI_ZMB': 'Airtel Money', 'ZAMTEL_ZMB': 'Zamtel Money'}),
    'KEN': (name: 'Kenya', currency: 'KES', providers: {'MPESA_KEN': 'M-Pesa'}),
    'MOZ': (name: 'Mozambique', currency: 'MZN', providers: {'VODACOM_MOZ': 'M-Pesa'}),
  };

  static const eventTypes = <String>['payment.succeeded', 'payment.failed', 'payment.refunded', 'payment.disputed', 'payment.dispute_closed', 'refund.succeeded', 'refund.failed', 'refund.canceled', 'payout.paid', 'payout.failed', 'payout.canceled', 'subscription.created', 'subscription.updated', 'subscription.past_due', 'subscription.unpaid', 'subscription.paused', 'subscription.resumed', 'subscription.canceled', 'invoice.created', 'invoice.upcoming', 'invoice.paid', 'invoice.canceled', 'invoice.payment_failed', 'checkout_session.completed', 'provider_status.changed', 'account.updated'];

  static const mtnMomoCmr = 'MTN_MOMO_CMR';
  static const orangeCmr = 'ORANGE_CMR';
  static const mtnMomoCog = 'MTN_MOMO_COG';
  static const airtelCog = 'AIRTEL_COG';
  static const airtelGab = 'AIRTEL_GAB';
  static const moovGab = 'MOOV_GAB';
  static const mtnMomoBen = 'MTN_MOMO_BEN';
  static const moovBen = 'MOOV_BEN';
  static const mtnMomoCiv = 'MTN_MOMO_CIV';
  static const orangeCiv = 'ORANGE_CIV';
  static const moovCiv = 'MOOV_CIV';
  static const freeSen = 'FREE_SEN';
  static const orangeSen = 'ORANGE_SEN';
  static const vodacomMpesaCod = 'VODACOM_MPESA_COD';
  static const airtelCod = 'AIRTEL_COD';
  static const orangeCod = 'ORANGE_COD';
  static const airtelRwa = 'AIRTEL_RWA';
  static const mtnMomoRwa = 'MTN_MOMO_RWA';
  static const orangeSle = 'ORANGE_SLE';
  static const airtelOapiUga = 'AIRTEL_OAPI_UGA';
  static const mtnMomoUga = 'MTN_MOMO_UGA';
  static const mtnMomoZmb = 'MTN_MOMO_ZMB';
  static const airtelOapiZmb = 'AIRTEL_OAPI_ZMB';
  static const zamtelZmb = 'ZAMTEL_ZMB';
  static const mpesaKen = 'MPESA_KEN';
  static const vodacomMoz = 'VODACOM_MOZ';
}
