import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/machinery.dart';
import '../../domain/entities/machinery_request.dart';
import '../models/machinery_model.dart';
import '../models/machinery_request_model.dart';

class MachineryRemoteDataSource {
  MachineryRemoteDataSource(this.client);
  final ApiClient client;
  Future<List<Machinery>> list(int projectId) async =>
      ((await client.get(ApiEndpoints.machineryList(projectId))) as List)
          .map(
            (e) => MachineryModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
  Future<Machinery> create(MachineryRequest request) async =>
      MachineryModel.fromJson(
        Map<String, dynamic>.from(
          await client.post(ApiEndpoints.machinery, data: request.toJson())
              as Map,
        ),
      );
  Future<Machinery> update(int id, MachineryRequest request) async =>
      MachineryModel.fromJson(
        Map<String, dynamic>.from(
          await client.put(
            ApiEndpoints.machineryItem(id),
            data: request.toJson(),
          ) as Map,
        ),
      );
  Future<void> delete(int id) => client.delete(ApiEndpoints.machineryItem(id));
}
