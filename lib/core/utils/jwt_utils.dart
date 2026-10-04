import 'dart:convert';

abstract final class JwtUtils {
  static DateTime? expiry(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload is Map<String, dynamic> ? payload['exp'] : null;
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } on FormatException {
      return null;
    }
  }

  static bool isExpired(String token, {DateTime? now}) {
    final expiration = expiry(token);
    if (expiration == null) return true;
    return !expiration.isAfter((now ?? DateTime.now()).toUtc());
  }
}
