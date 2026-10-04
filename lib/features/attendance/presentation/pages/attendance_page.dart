import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_list.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/attendance.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/attendance_form.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key, required this.projectId});
  final int projectId;
  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  DateTime? date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final write =
        ref.watch(sessionControllerProvider).user?.isSupervisor ?? false;
    final provider = attendanceControllerProvider(widget.projectId);
    final state = ref
        .watch(provider)
        .whenData(
          (rows) => rows
              .where(
                (a) =>
                    date == null ||
                    (a.attendanceDate.year == date!.year &&
                        a.attendanceDate.month == date!.month &&
                        a.attendanceDate.day == date!.day),
              )
              .toList(),
        );
    final locale = Localizations.localeOf(context).languageCode;
    return RecordList<Attendance>(
      title: context.l10n.attendance,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Text(
          date == null
              ? context.l10n.attendanceHistory
              : DateFormat.yMMMMd(locale).format(date!),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      state: state,
      refresh: () => ref.read(provider.notifier).refresh(),
      statuses: AttendanceStatus.values.map((s) => s.apiValue).toList(),
      status: (a) => a.status.apiValue,
      searchText: (a) => '${a.workerName} ${a.notes}',
      create: write
          ? () => showAttendanceForm(context, ref, widget.projectId, date: date)
          : null,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.date_range),
          tooltip: context.l10n.attendanceDate,
          onSelected: (value) async {
            if (value == 'all') {
              setState(() => date = null);
              return;
            }
            final selected = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (selected != null && mounted) setState(() => date = selected);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'date', child: Text(context.l10n.selectDate)),
            PopupMenuItem(
              value: 'all',
              child: Text(context.l10n.attendanceHistory),
            ),
          ],
        ),
      ],
      card: (a) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.workerName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(DateFormat.yMd(locale).format(a.attendanceDate)),
              Chip(label: Text(attendanceLabel(context, a.status))),
              if (a.checkInAt != null)
                Text(
                  '${context.l10n.checkIn}: ${DateFormat.yMd(locale).add_Hm().format(a.checkInAt!.toLocal())}',
                ),
              if (a.checkOutAt != null)
                Text(
                  '${context.l10n.checkOut}: ${DateFormat.yMd(locale).add_Hm().format(a.checkOutAt!.toLocal())}',
                ),
              if (a.notes.isNotEmpty) Text(a.notes),
              if (write)
                Wrap(
                  children: [
                    TextButton(
                      onPressed: () => showAttendanceForm(
                        context,
                        ref,
                        widget.projectId,
                        existing: a,
                      ),
                      child: Text(context.l10n.edit),
                    ),
                    TextButton(
                      onPressed: () => deleteRecord(
                        context,
                        () => ref.read(provider.notifier).delete(a.id),
                      ),
                      child: Text(context.l10n.delete),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
