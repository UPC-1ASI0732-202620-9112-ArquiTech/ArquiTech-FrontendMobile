import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses every backend user field', () {
    final user = User.fromJson({
      'id': 8,
      'fullName': 'Luis Vega',
      'email': 'luis@company.pe',
      'role': 'CONTRACTOR',
      'phone': '999111222',
      'createdAt': '2026-10-03T15:00:00Z',
      'profilePicture': 'https://example.test/profile.png',
    });

    expect(user.isContractor, isTrue);
    expect(user.phone, '999111222');
    expect(user.createdAt, DateTime.utc(2026, 10, 3, 15));
    expect(user.profilePicture, endsWith('profile.png'));
  });
}
