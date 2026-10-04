abstract final class ApiEndpoints {
  static const signIn = '/authentication/sign-in';
  static const users = '/users';
  static const projects = '/projects';
  static String project(int id) => '/projects/$id';
  static const attendance = '/attendance';
  static String attendanceRecord(int id) => '/attendance/$id';
  static String attendanceList(int projectId, {DateTime? date}) =>
      '/attendance?projectId=$projectId${date == null ? '' : '&date=${date.toIso8601String().split('T').first}'}';
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
  static const workers = '/workers';
  static String worker(int id) => '/workers/$id';
  static String workersList(int projectId) => '/workers?projectId=$projectId';
  static const tasks = '/tasks';
  static String task(int id) => '/tasks/$id';
  static String tasksList(int projectId) => '/tasks?projectId=$projectId';
  static const incidents = '/incidents';
  static String incident(int id) => '/incidents/$id';
  static String incidentsList(int projectId) => '/incidents/project/$projectId';
  static const machinery = '/machinery';
  static String machineryItem(int id) => '/machinery/$id';
  static String machineryList(int projectId) =>
      '/machinery?projectId=$projectId';
}
