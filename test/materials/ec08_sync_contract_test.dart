import 'package:arquitech/core/network/api_client.dart';
import 'package:arquitech/features/materials/data/datasources/material_remote_datasource.dart';
import 'package:arquitech/features/materials/domain/entities/material_movement.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime.utc(2026, 11, 10, 12, 30);

  test('checks backend capabilities before enabling safe offline uploads',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'idempotentOfflineMovements': true},
      )),
    ));
    final remote = MaterialRemoteDataSource(ApiClient(dio));
    expect(await remote.supportsOfflineSync(), isTrue);
  });

  test('does not enable uploads for unrecognized server capability',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'anotherCapability': true},
      )),
    ));
    final remote = MaterialRemoteDataSource(ApiClient(dio));
    expect(await remote.supportsOfflineSync(), isFalse);
  });

  test('sends a stable offline request id and the original movement data',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'));
    RequestOptions? sent;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        sent = options;
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'id': 91,
            'projectId': 11,
            'materialId': 4,
            'materialName': 'Cemento',
            'unit': 'kg',
            'type': 'USAGE',
            'quantity': 2.5,
            'registeredByUserId': 9,
            'occurredAt': '2026-11-10T12:30:00Z',
            'clientRequestId': '11-123456789',
          },
        ));
      },
    ));
    final remote = MaterialRemoteDataSource(ApiClient(dio));
    final request = OfflineMovementRequest(
      clientRequestId: '11-123456789',
      type: MovementType.usage,
      quantity: 2.5,
      supplier: '',
      occurredAt: date,
      note: 'EC08 offline movement 11-123456789',
    );

    final movement = await remote.registerOfflineMovement(4, request);
    expect(movement.id, 91);
    expect(sent?.path, '/materials/4/offline-movements');
    final payload = sent?.data as Map<String, dynamic>;
    expect(payload['clientRequestId'], '11-123456789');
    expect(payload['type'], 'USAGE');
    expect(payload['quantity'], 2.5);
    expect(payload['supplier'], isNull);
    expect(payload['note'], 'EC08 offline movement 11-123456789');
    expect(payload['occurredAt'], isNotNull);
  });
}
