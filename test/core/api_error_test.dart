import 'package:arquitech/core/errors/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses backend error contract', () {
    final error = ApiError.fromJson({
      'code': 'INSUFFICIENT_STOCK',
      'message': 'Insufficient stock',
      'timestamp': '2026-10-03T20:00:00Z',
      'path': '/api/v1/materials/3/use',
    }, statusCode: 400);

    expect(error.code, 'INSUFFICIENT_STOCK');
    expect(error.statusCode, 400);
    expect(error.path, endsWith('/use'));
    expect(error.timestamp, isNotNull);
  });
}
