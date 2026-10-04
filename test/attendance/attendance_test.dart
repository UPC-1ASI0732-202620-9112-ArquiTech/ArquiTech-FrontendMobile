import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:arquitech/core/network/api_client.dart';
import 'package:arquitech/core/errors/api_error.dart';
import 'package:arquitech/core/errors/error_mapper.dart';
import 'package:arquitech/app/localization/app_localizations_es.dart';
import 'package:arquitech/app/localization/app_localizations_en.dart';
import 'package:arquitech/features/attendance/domain/entities/attendance.dart';
import 'package:arquitech/features/attendance/domain/entities/attendance_request.dart';
import 'package:arquitech/features/attendance/data/models/attendance_model.dart';
import 'package:arquitech/features/attendance/data/models/attendance_request_model.dart';
import 'package:arquitech/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:arquitech/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:arquitech/features/projects/presentation/controllers/projects_controller.dart';

import '../core/api_contract_test.dart';
import '../support/fake_repositories.dart';

Map<String, dynamic> attendanceJson([String status = 'PRESENT']) => {
  'id': 20,
  'projectId': 9,
  'workerId': 3,
  'workerName': 'Ana Torres',
  'attendanceDate': '2026-10-03',
  'status': status,
  'checkInAt': '2026-10-03T13:00:00Z',
  'checkOutAt': null,
  'notes': null,
  'registeredByUserId': 1,
  'createdAt': '2026-10-03T13:00:00Z',
  'updatedAt': '2026-10-03T13:00:00Z',
};
void main() {
  test(
    'Parses every attendance status, optional times and server-managed fields',
    () {
      for (final status in AttendanceStatus.values) {
        final item = AttendanceModel.fromJson(attendanceJson(status.apiValue));
        expect(item.status, status);
        expect(item.attendanceDate, DateTime(2026, 10, 3));
        expect(item.checkInAt!.isUtc, true);
        expect(item.checkOutAt, isNull);
        expect(item.notes, '');
        expect(item.registeredByUserId, 1);
        expect(item.createdAt, isNotNull);
      }
    },
  );
  test('Unknown attendance status is rejected', () {
    expect(() => AttendanceStatus.fromApi('ACTIVE'), throwsStateError);
  });
  test('Attendance payload preserves LocalDate and serializes UTC, excludes authority and project on update', () {
    final request = AttendanceRequest(
      workerId: 3,
      attendanceDate: DateTime(2026, 10, 3),
      status: AttendanceStatus.present,
      checkInAt: DateTime.parse('2026-10-03T08:00:00-05:00'),
      notes: ' Site ',
    );
    final body = request.toJson();
    expect(body['attendanceDate'], '2026-10-03');
    expect(body['checkInAt'], '2026-10-03T13:00:00.000Z');
    expect(body['notes'], 'Site');
    expect(body.keys.toSet(), {
      'workerId',
      'attendanceDate',
      'status',
      'checkInAt',
      'checkOutAt',
      'notes',
    });
  });
  test('Attendance time rules allow overnight shifts and reject inconsistent states', () {
    AttendanceRequest request(
      AttendanceStatus status,
      DateTime? start,
      DateTime? end,
    ) => AttendanceRequest(
      workerId: 3,
      attendanceDate: DateTime(2026, 10, 3),
      status: status,
      checkInAt: start,
      checkOutAt: end,
    );
    final start = DateTime.utc(2026, 10, 3, 22),
        end = DateTime.utc(2026, 10, 4, 6);
    expect(request(AttendanceStatus.present, start, end).hasValidTimes, true);
    expect(request(AttendanceStatus.late, start, null).hasValidTimes, true);
    expect(request(AttendanceStatus.present, null, end).hasValidTimes, false);
    expect(request(AttendanceStatus.present, end, start).hasValidTimes, false);
    expect(request(AttendanceStatus.absent, start, null).hasValidTimes, false);
    expect(request(AttendanceStatus.excused, null, null).hasValidTimes, true);
  });
  test('Attendance HTTP CRUD and optional date filter match backend', () async {
    final adapter = RecordingAdapter(),
        dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    final source = AttendanceRemoteDataSource(ApiClient(dio));
    adapter.response = [attendanceJson()];
    await source.list(9, date: DateTime(2026, 10, 3));
    expect(adapter.requests.last.uri.queryParameters, {
      'projectId': '9',
      'date': '2026-10-03',
    });
    adapter.response = attendanceJson();
    await source.create(
      AttendanceRequest(
        projectId: 9,
        workerId: 3,
        attendanceDate: DateTime(2026, 10, 3),
        status: AttendanceStatus.present,
      ),
    );
    expect(adapter.requests.last.method, 'POST');
    expect((adapter.requests.last.data as Map)['projectId'], 9);
    await source.update(
      20,
      AttendanceRequest(
        workerId: 3,
        attendanceDate: DateTime(2026, 10, 3),
        status: AttendanceStatus.excused,
      ),
    );
    expect(adapter.requests.last.path, '/attendance/20');
    expect(adapter.requests.last.method, 'PUT');
    expect((adapter.requests.last.data as Map).containsKey('projectId'), false);
    adapter.status = 204;
    await source.delete(20);
    expect(adapter.requests.last.method, 'DELETE');
  });
  test('Project deletion uses DELETE and accepts empty 204 response', () async {
    final adapter = RecordingAdapter()..status = 204;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    await ProjectRemoteDataSource(ApiClient(dio)).deleteProject(9);
    expect(adapter.requests.single.path, '/projects/9');
    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.data, isNull);
  });
  test('Attendance duplicate and 403 keep structured API errors', () async {
    final adapter = RecordingAdapter(),
        dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'));
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    final source = AttendanceRemoteDataSource(ApiClient(dio));
    for (final pair in [(409, 'DUPLICATE_ATTENDANCE'), (403, 'FORBIDDEN')]) {
      adapter.status = pair.$1;
      adapter.response = {'code': pair.$2, 'message': 'Rejected'};
      await expectLater(
        source.delete(20),
        throwsA(isA<ApiError>().having((e) => e.code, 'code', pair.$2)),
      );
    }
  });
  test('Attendance errors are translated in ES and EN', () {
    for (final locale in [AppLocalizationsEs(), AppLocalizationsEn()]) {
      expect(
        ErrorMapper.message(
          locale,
          const ApiError(code: 'DUPLICATE_ATTENDANCE', message: ''),
        ),
        locale.errorDuplicateAttendance,
      );
      expect(
        ErrorMapper.message(
          locale,
          const ApiError(code: 'WORKER_HAS_ATTENDANCE', message: ''),
        ),
        locale.errorWorkerHasAttendance,
      );
    }
  });
  test(
    'Failed project delete keeps list; success removes only the target',
    () async {
      final repository = FakeProjectRepository();
      final controller = ProjectsController(repository);
      addTearDown(controller.dispose);
      await controller.refresh();
      repository.failure = const ApiError(code: 'FORBIDDEN', message: '');
      await expectLater(controller.delete(9), throwsA(isA<ApiError>()));
      expect(controller.state.value!.length, 1);
      repository.failure = null;
      await controller.delete(9);
      expect(controller.state.value, isEmpty);
    },
  );
}
