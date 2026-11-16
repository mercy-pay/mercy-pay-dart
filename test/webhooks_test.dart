import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mercy_pay/mercy_pay.dart';
import 'package:test/test.dart';

// The same vector as the Mercy Pay servers and every other official library.
const secret = 'whsec_test';
const payload = '{"id":"evt_test","object":"event"}';
const timestamp = 1791022800;
const signature = '52dafa4217ab4708f69eaeecb1f77e14f6405da36a477620c75328c30567e13b';

void main() {
  test('gives the event when the signature is right', () {
    expect(constructEvent(payload, 't=$timestamp,v1=$signature', secret, now: timestamp + 60)['id'], 'evt_test');
    expect(constructEvent(payload, 't=$timestamp,v1=deadbeef,v1=$signature', secret, now: timestamp)['object'], 'event');
  });

  final other = Hmac(sha256, utf8.encode('whsec_other')).convert(utf8.encode('$timestamp.$payload')).toString();
  final refused = <String, (String, String?, int)>{
    'changed body': ('$payload ', 't=$timestamp,v1=$signature', timestamp),
    'too old': (payload, 't=$timestamp,v1=$signature', timestamp + 301),
    'missing header': (payload, null, timestamp),
    'no v1': (payload, 't=$timestamp', timestamp),
    'wrong secret': (payload, 't=$timestamp,v1=$other', timestamp),
  };

  refused.forEach((name, input) {
    test('refuses a webhook with a $name', () {
      expect(() => constructEvent(input.$1, input.$2, secret, now: input.$3), throwsA(isA<SignatureVerificationException>()));
    });
  });
}
