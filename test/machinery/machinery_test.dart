import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:arquitech/app/localization/app_localizations.dart';
import 'package:arquitech/core/errors/error_mapper.dart';
import 'package:arquitech/core/errors/api_error.dart';
import 'package:arquitech/features/machinery/data/models/machinery_model.dart';
import 'package:arquitech/features/machinery/data/models/machinery_request_model.dart';
import 'package:arquitech/features/machinery/domain/entities/machinery.dart';
import 'package:arquitech/features/machinery/domain/entities/machinery_request.dart';

import '../support/second_half_fixtures.dart';

void main() {
  for (final status in MachineryStatus.values) {
    test('Machinery parses ${status.apiValue}', () {
      final m = MachineryModel.fromJson(machineryJson(status: status.apiValue));
      expect(m.status, status);
      expect(m.description, '');
      expect(m.registeredAt, DateTime(2026, 9, 1));
    });
  }
  test('Serial validation handles boundaries and uppercase serialization', () {
    expect(Machinery.validSerial('ab-'), true);
    for (final s in ['ab', 'A B', 'ABC_1', 'ABCDEFGHIJKLMNOPQRSTU']) {
      expect(Machinery.validSerial(s), false);
    }
    final p = MachineryRequest(
      name: 'Excavadora',
      serialNumber: 'abc-123',
      registeredAt: DateTime(2026, 9, 1),
      description: '',
      status: MachineryStatus.maintenance,
    ).toJson();
    expect(p['serialNumber'], 'ABC-123');
    expect(p['registeredAt'], '2026-09-01');
    expect(p.containsKey('projectId'), false);
  });
  test('Duplicate serial error is localized', () async {
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(
      ErrorMapper.message(
        l,
        const ApiError(code: 'DUPLICATED_SERIAL_NUMBER', message: 'duplicate'),
      ),
      l.errorDuplicatedSerialNumber,
    );
  });
}
