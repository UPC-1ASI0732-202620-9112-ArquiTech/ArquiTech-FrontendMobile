import '../entities/machinery.dart';
import '../entities/machinery_request.dart';

abstract class MachineryRepository {
  Future<List<Machinery>> list(int projectId);
  Future<Machinery> create(MachineryRequest request);
  Future<Machinery> update(int id, MachineryRequest request);
  Future<void> delete(int id);
}
