import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:arquitech/core/utils/role_permissions.dart';

void main() {
  test('Missing or unknown roles cannot become supervisor', () {
    expect(() => UserRole.fromApi(''), throwsFormatException);
    expect(() => UserRole.fromApi('ADMIN'), throwsFormatException);
  });
  test('Second half role policy grants writes only to supervisor', () {
    for (final role in UserRole.values) {
      expect(
        RolePermissions.canWritePersonnel(role),
        role == UserRole.supervisor,
      );
      expect(
        RolePermissions.canWriteIncidents(role),
        role == UserRole.supervisor,
      );
      expect(
        RolePermissions.canWriteMachinery(role),
        role == UserRole.supervisor,
      );
    }
  });
}
