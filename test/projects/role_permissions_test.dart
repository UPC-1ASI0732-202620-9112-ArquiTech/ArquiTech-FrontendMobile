import 'package:arquitech/core/utils/role_permissions.dart';
import 'package:arquitech/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('project and material role behavior', () {
    test('supervisor has project and material write actions', () {
      expect(RolePermissions.canCreateProject(UserRole.supervisor), isTrue);
      expect(RolePermissions.canWriteMaterials(UserRole.supervisor), isTrue);
    });

    test('contractor is read-only', () {
      expect(RolePermissions.canCreateProject(UserRole.contractor), isFalse);
      expect(RolePermissions.canWriteMaterials(UserRole.contractor), isFalse);
      expect(RolePermissions.canReadMaterials(UserRole.contractor), isTrue);
      expect(RolePermissions.canReadHistory(UserRole.contractor), isTrue);
    });
  });
}
