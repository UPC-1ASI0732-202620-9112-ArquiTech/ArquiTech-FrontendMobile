import 'package:arquitech/features/auth/data/models/auth_response_model.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses canonical sign-in response', () {
    final response = AuthResponseModel.fromJson({
      'id': 7,
      'fullName': 'Ana Torres',
      'email': 'ana@arquitech.pe',
      'role': 'SUPERVISOR',
      'token': 'jwt-token',
    });

    expect(response.token, 'jwt-token');
    expect(response.user.id, 7);
    expect(response.user.role, UserRole.supervisor);
  });
}
