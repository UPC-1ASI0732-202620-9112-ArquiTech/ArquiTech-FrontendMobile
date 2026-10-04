import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_request.dart';
import '../controllers/attendance_controller.dart';
import '../../../workers/domain/entities/worker.dart';
import '../../../workers/presentation/controllers/workers_controller.dart';

String attendanceLabel(BuildContext context, AttendanceStatus s) => switch (s) {
  AttendanceStatus.present => context.l10n.attendancePresent,
  AttendanceStatus.absent => context.l10n.attendanceAbsent,
  AttendanceStatus.late => context.l10n.attendanceLate,
  AttendanceStatus.excused => context.l10n.attendanceExcused,
};
Future<void> showAttendanceForm(
  BuildContext context,
  WidgetRef ref,
  int projectId, {
  Attendance? existing,
  DateTime? date,
}) async {
  final repository = ref.read(attendanceRepositoryProvider);
  List<Worker> workers;
  try {
    workers = await ref.read(workerRepositoryProvider).list(projectId);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorMapper.message(context.l10n, e))),
      );
    }
    return;
  }
  if (!context.mounted) return;
  final eligible = workers
      .where(
        (w) =>
            w.projectId == projectId &&
            (w.status != WorkerStatus.inactive || w.id == existing?.workerId),
      )
      .toList();
  if (eligible.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.noEligibleWorkers)));
    return;
  }
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => AttendanceForm(
        projectId: projectId,
        workers: eligible,
        existing: existing,
        initialDate: date,
        onSave: (request) async {
          if (existing == null) {
            await repository.create(request);
          } else {
            await repository.update(existing.id, request);
          }
        },
      ),
    ),
  );
  if (context.mounted) ref.invalidate(attendanceControllerProvider(projectId));
}

class AttendanceForm extends StatefulWidget {
  const AttendanceForm({
    super.key,
    required this.projectId,
    required this.workers,
    required this.onSave,
    this.existing,
    this.initialDate,
  });
  final int projectId;
  final List<Worker> workers;
  final Attendance? existing;
  final DateTime? initialDate;
  final Future<void> Function(AttendanceRequest) onSave;
  @override
  State<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  final form = GlobalKey<FormState>();
  late int workerId = widget.existing?.workerId ?? widget.workers.first.id;
  late DateTime date =
      widget.existing?.attendanceDate ?? widget.initialDate ?? DateTime.now();
  late AttendanceStatus status =
      widget.existing?.status ?? AttendanceStatus.present;
  late DateTime? checkIn = widget.existing?.checkInAt?.toLocal();
  late DateTime? checkOut = widget.existing?.checkOutAt?.toLocal();
  late final notes = TextEditingController(text: widget.existing?.notes ?? '');
  bool submitting = false;
  String? error;
  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Future<void> pickTime(bool isCheckIn) async {
    final current = (isCheckIn ? checkIn : checkOut) ?? date;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final instant = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isCheckIn) {
        checkIn = instant;
      } else {
        checkOut = instant;
      }
    });
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final request = AttendanceRequest(
      projectId: widget.existing == null ? widget.projectId : null,
      workerId: workerId,
      attendanceDate: date,
      status: status,
      checkInAt: checkIn,
      checkOutAt: checkOut,
      notes: notes.text,
    );
    if (!request.hasValidTimes) {
      setState(() => error = context.l10n.attendanceInvalidTimes);
      return;
    }
    final worker = widget.workers.firstWhere((w) => w.id == workerId);
    if (DateTime(date.year, date.month, date.day).isBefore(worker.hireDate)) {
      setState(() => error = context.l10n.attendanceBeforeHire);
      return;
    }
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      await widget.onSave(request);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saved)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => error = ErrorMapper.message(context.l10n, e));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.attendance)),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          DropdownButtonFormField<int>(
            initialValue: workerId,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.l10n.worker),
            items: widget.workers
                .map(
                  (w) => DropdownMenuItem(value: w.id, child: Text(w.fullName)),
                )
                .toList(),
            onChanged: submitting ? null : (v) => setState(() => workerId = v!),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: submitting
                ? null
                : () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (selected != null && mounted) {
                      setState(() => date = selected);
                    }
                  },
            icon: const Icon(Icons.calendar_month),
            label: Text(
              '${context.l10n.attendanceDate}: ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(date)}',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AttendanceStatus>(
            initialValue: status,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.l10n.status),
            items: AttendanceStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(attendanceLabel(context, s)),
                  ),
                )
                .toList(),
            onChanged: submitting
                ? null
                : (v) => setState(() {
                    status = v!;
                    if (!status.allowsTimes) {
                      checkIn = null;
                      checkOut = null;
                    }
                  }),
          ),
          if (status.allowsTimes) ...[
            const SizedBox(height: 16),
            for (final isIn in [true, false])
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: submitting ? null : () => pickTime(isIn),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      '${isIn ? context.l10n.checkIn : context.l10n.checkOut}: ${(isIn ? checkIn : checkOut) == null ? context.l10n.optional : DateFormat.yMd(Localizations.localeOf(context).languageCode).add_Hm().format((isIn ? checkIn : checkOut)!)}',
                    ),
                  ),
                  if ((isIn ? checkIn : checkOut) != null)
                    IconButton(
                      tooltip: context.l10n.clearTime,
                      onPressed: submitting
                          ? null
                          : () => setState(() {
                              if (isIn) {
                                checkIn = null;
                                checkOut = null;
                              } else {
                                checkOut = null;
                              }
                            }),
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: notes,
            enabled: !submitting,
            maxLength: 1000,
            maxLines: 3,
            decoration: InputDecoration(labelText: context.l10n.note),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: submitting ? null : save,
            child: submitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.save),
          ),
        ],
      ),
    ),
  );
}
