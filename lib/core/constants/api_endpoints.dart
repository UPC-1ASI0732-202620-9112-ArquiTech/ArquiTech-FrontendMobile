abstract final class ApiEndpoints {
  static const signIn = '/authentication/sign-in';
  static const users = '/users';
  static const projects = '/projects';
  static String supervisorProjects(int userId) =>
      '/projects/supervisor/$userId';
  static const materials = '/materials';
  static String projectMaterials(int projectId) =>
      '/materials/project/$projectId';
  static String material(int materialId) => '/materials/$materialId';
  static String materialEntry(int materialId) => '/materials/$materialId/entry';
  static String materialUsage(int materialId) => '/materials/$materialId/use';
  static String materialHistory(int projectId) =>
      '/materials/project/$projectId/history';
}
