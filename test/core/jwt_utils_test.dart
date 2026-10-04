import 'dart:convert';

import 'package:arquitech/core/utils/jwt_utils.dart';
import 'package:flutter_test/flutter_test.dart';

String tokenWithExpiry(int seconds) {
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'exp': seconds})))
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

void main() {
  test('reads JWT expiry and detects a valid token', () {
    final token = tokenWithExpiry(
      DateTime.utc(2030).millisecondsSinceEpoch ~/ 1000,
    );
    expect(JwtUtils.expiry(token), DateTime.utc(2030));
    expect(JwtUtils.isExpired(token, now: DateTime.utc(2029)), isFalse);
  });

  test('treats expired and malformed tokens as expired', () {
    final expired = tokenWithExpiry(
      DateTime.utc(2020).millisecondsSinceEpoch ~/ 1000,
    );
    expect(JwtUtils.isExpired(expired, now: DateTime.utc(2026)), isTrue);
    expect(JwtUtils.isExpired('invalid'), isTrue);
  });
}
