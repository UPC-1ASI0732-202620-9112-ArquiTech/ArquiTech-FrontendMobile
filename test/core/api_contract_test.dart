import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arquitech/core/network/api_client.dart';
import 'package:arquitech/core/network/auth_interceptor.dart';
import 'package:arquitech/core/errors/api_error.dart';
import 'package:arquitech/features/workers/data/datasources/worker_remote_datasource.dart';
import 'package:arquitech/features/workers/domain/entities/worker.dart';
import 'package:arquitech/features/workers/domain/entities/worker_request.dart';
import 'package:arquitech/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:arquitech/features/tasks/domain/entities/task.dart';
import 'package:arquitech/features/tasks/domain/entities/task_request.dart';
import 'package:arquitech/features/incidents/data/datasources/incident_remote_datasource.dart';
import 'package:arquitech/features/incidents/domain/entities/incident.dart';
import 'package:arquitech/features/incidents/domain/entities/incident_request.dart';
import 'package:arquitech/features/machinery/data/datasources/machinery_remote_datasource.dart';
import 'package:arquitech/features/machinery/domain/entities/machinery.dart';
import 'package:arquitech/features/machinery/domain/entities/machinery_request.dart';

import '../support/second_half_fixtures.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  dynamic response;
  int status = 200;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      status == 204 ? '' : jsonEncode(response),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late RecordingAdapter adapter;
  late ApiClient client;
  late Dio dio;
  setUp(() {
    adapter = RecordingAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;
    client = ApiClient(dio);
  });
  tearDown(() => dio.close());
  test('Worker list query and CRUD use canonical contracts', () async {
    final source = WorkerRemoteDataSource(client);
    adapter.response = [workerJson()];
    await source.list(9);
    expect(adapter.requests.last.uri.queryParameters, {'projectId': '9'});
    expect(adapter.requests.last.uri.path, '/api/v1/workers');
    adapter.response = workerJson();
    final create = WorkerRequest(
      projectId: 9,
      fullName: 'Ana',
      role: 'Capataz',
      specialty: '',
      hireDate: DateTime(2026, 9, 1),
      status: WorkerStatus.active,
    );
    await source.create(create);
    expect(adapter.requests.last.method, 'POST');
    expect((adapter.requests.last.data as Map)['projectId'], 9);
    await source.update(
      3,
      WorkerRequest(
        fullName: 'Ana',
        role: 'Capataz',
        specialty: '',
        hireDate: DateTime(2026, 9, 1),
        status: WorkerStatus.onLeave,
      ),
    );
    expect(adapter.requests.last.method, 'PUT');
    expect(adapter.requests.last.path, '/workers/3');
    expect((adapter.requests.last.data as Map).containsKey('projectId'), false);
    adapter.status = 204;
    await source.delete(3);
    expect(adapter.requests.last.method, 'DELETE');
    adapter.status = 409;
    adapter.response = {'code': 'WORKER_HAS_TASKS', 'message': 'conflict'};
    await expectLater(
      source.delete(3),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', 'WORKER_HAS_TASKS'),
      ),
    );
  });
  test(
    'Task list and mutations never issue GET individual or completedAt',
    () async {
      final source = TaskRemoteDataSource(client);
      adapter.response = [taskJson()];
      await source.list(9);
      expect(adapter.requests.last.uri.queryParameters['projectId'], '9');
      adapter.response = taskJson();
      await source.create(
        TaskRequest(
          projectId: 9,
          workerId: 3,
          title: 'Task',
          description: '',
          status: TaskStatus.pending,
          dueDate: DateTime(2026, 10, 4),
        ),
      );
      await source.update(
        4,
        TaskRequest(
          workerId: 3,
          title: 'Task',
          description: '',
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 10, 4),
        ),
      );
      expect(adapter.requests.last.path, '/tasks/4');
      expect(
        (adapter.requests.last.data as Map).containsKey('completedAt'),
        false,
      );
      adapter.status = 204;
      await source.delete(4);
      expect(adapter.requests.map((r) => r.method).toList(), [
        'GET',
        'POST',
        'PUT',
        'DELETE',
      ]);
    },
  );
  test(
    'Incidents use project path, UTC and server-managed omissions',
    () async {
      final source = IncidentRemoteDataSource(client);
      adapter.response = [incidentJson()];
      await source.list(9);
      expect(adapter.requests.last.path, '/incidents/project/9');
      adapter.response = incidentJson();
      final request = IncidentRequest(
        type: 'OTHER',
        description: 'Issue',
        severity: IncidentSeverity.high,
        status: IncidentStatus.resolved,
        reportedAt: DateTime(2026, 10, 4),
      );
      await source.create(
        IncidentRequest(
          projectId: 9,
          type: request.type,
          description: request.description,
          severity: request.severity,
          status: IncidentStatus.open,
          reportedAt: request.reportedAt,
        ),
      );
      await source.update(5, request);
      final body = adapter.requests.last.data as Map;
      expect(body['status'], 'RESOLVED');
      expect(body['reportedAt'].toString().endsWith('Z'), true);
      expect(body.keys.toSet(), {
        'type',
        'description',
        'severity',
        'status',
        'reportedAt',
      });
      adapter.status = 204;
      await source.delete(5);
    },
  );
  test('Machinery CRUD normalizes serial and preserves LocalDate', () async {
    final source = MachineryRemoteDataSource(client);
    adapter.response = [machineryJson()];
    await source.list(9);
    expect(adapter.requests.last.uri.queryParameters, {'projectId': '9'});
    adapter.response = machineryJson();
    final request = MachineryRequest(
      projectId: 9,
      name: 'Excavadora',
      serialNumber: 'abc-123',
      registeredAt: DateTime(2026, 9, 1),
      description: '',
      status: MachineryStatus.operational,
    );
    await source.create(request);
    expect((adapter.requests.last.data as Map)['serialNumber'], 'ABC-123');
    await source.update(
      6,
      MachineryRequest(
        name: request.name,
        serialNumber: request.serialNumber,
        registeredAt: request.registeredAt,
        description: '',
        status: MachineryStatus.maintenance,
      ),
    );
    expect(adapter.requests.last.path, '/machinery/6');
    adapter.status = 204;
    await source.delete(6);
  });
  test(
    '403 preserves session; protected 401 expires; login 401 does not',
    () async {
      int expired = 0;
      dio.interceptors.add(
        AuthInterceptor(
          readToken: () async => 'test-only-token',
          onUnauthorized: () async {
            expired++;
          },
        ),
      );
      adapter.status = 403;
      adapter.response = {'code': 'FORBIDDEN', 'message': 'denied'};
      await expectLater(
        client.get('/workers?projectId=9'),
        throwsA(isA<ApiError>()),
      );
      expect(expired, 0);
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer test-only-token',
      );
      adapter.status = 401;
      adapter.response = {'code': 'UNAUTHORIZED', 'message': 'expired'};
      await expectLater(
        client.get('/workers?projectId=9'),
        throwsA(isA<ApiError>()),
      );
      expect(expired, 1);
      await expectLater(
        client.post('/authentication/sign-in', data: {}),
        throwsA(isA<ApiError>()),
      );
      expect(expired, 1);
      expect(adapter.requests.last.headers.containsKey('Authorization'), false);
    },
  );
}
