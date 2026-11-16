import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'errors.dart';

const defaultToleranceSeconds = 300;

/// Checks the MercyPay-Signature header: an HMAC-SHA256 of "{t}.{raw body}" with the
/// endpoint's secret, and t recent.
void verifySignature(String payload, String? header, String secret, {int tolerance = defaultToleranceSeconds, int? now}) {
  if (header == null || header.isEmpty) {
    throw SignatureVerificationException('En-tête MercyPay-Signature absent.');
  }

  int? timestamp;
  final signatures = <String>[];
  for (final part in header.split(',')) {
    final index = part.indexOf('=');
    if (index <= 0) continue;
    final key = part.substring(0, index).trim();
    final value = part.substring(index + 1).trim();
    if (key == 't' && RegExp(r'^\d+$').hasMatch(value)) {
      timestamp = int.parse(value);
    } else if (key == 'v1' && value.isNotEmpty) {
      signatures.add(value);
    }
  }

  if (timestamp == null || signatures.isEmpty) {
    throw SignatureVerificationException('En-tête MercyPay-Signature mal formé.');
  }

  final current = now ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
  if ((current - timestamp).abs() > tolerance) {
    throw SignatureVerificationException('Signature trop ancienne : le webhook a peut-être été rejoué.');
  }

  final expected = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode('$timestamp.$payload')).toString();
  if (!signatures.any((signature) => _constantTimeEquals(signature, expected))) {
    throw SignatureVerificationException('Signature invalide : vérifiez le secret de votre endpoint.');
  }
}

/// Verifies the signature, then returns the event. Pass the raw body exactly as received.
Map<String, dynamic> constructEvent(String payload, String? header, String secret, {int tolerance = defaultToleranceSeconds, int? now}) {
  verifySignature(payload, header, secret, tolerance: tolerance, now: now);
  final Object? event;
  try {
    event = jsonDecode(payload);
  } on FormatException {
    throw SignatureVerificationException("Le corps du webhook n'est pas du JSON valide.");
  }
  if (event is! Map) {
    throw SignatureVerificationException("Le corps du webhook n'est pas un événement.");
  }
  return Map<String, dynamic>.from(event);
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}
