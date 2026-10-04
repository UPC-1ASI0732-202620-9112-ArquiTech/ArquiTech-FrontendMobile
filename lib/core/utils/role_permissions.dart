import '../../features/auth/domain/entities/user.dart';

abstract final class RolePermissions {
  static bool canCreateProject(UserRole role) => role == UserRole.supervisor;
  static bool canWriteMaterials(UserRole role) => role == UserRole.supervisor;
  static bool canWritePersonnel(UserRole role) => role == UserRole.supervisor;
  static bool canWriteIncidents(UserRole role) => role == UserRole.supervisor;
  static bool canWriteMachinery(UserRole role) => role == UserRole.supervisor;
  static bool canReadMaterials(UserRole role) => true;
  static bool canReadHistory(UserRole role) => true;
}
