import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../domain/entities/week_range.dart';
import '../../domain/entities/weekly_report.dart';
import '../controllers/reports_controller.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../widgets/report_pdf.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});
  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTime date = WeekRange(DateTime.now()).start;
  bool printing = false;
  String day(DateTime d) => d.toLocal().toIso8601String().split('T').first;
  Widget section(String title, List<String> rows) => Semantics(
    container: true,
    explicitChildNodes: true,
    role: SemanticsRole.region,
    label: title,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            for (final row in rows.isEmpty ? [context.l10n.noRecords] : rows)
              Padding(padding: const EdgeInsets.only(top: 8), child: Text(row)),
          ],
        ),
      ),
    ),
  );
  Future<void> printReport(WeeklyReport report) async {
    setState(() => printing = true);
    final l = context.l10n;
    try {
      final bytes = await buildReportPdf(report, l);
      await Printing.layoutPdf(
        name: 'ARQUITECH-${day(date)}',
        onLayout: (_) => Future.value(bytes),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ErrorMapper.message(l, e))));
      }
    } finally {
      if (mounted) {
        setState(() => printing = false);
      }
    }
  }

  Widget reportView(WeeklyReport r) => ListView(
    padding: const EdgeInsets.all(16),
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      Text(r.project.name, style: Theme.of(context).textTheme.headlineSmall),
      Text('${context.l10n.progress}: ${r.project.progress}%'),
      Text('${context.l10n.openTasks}: ${r.openTasks}'),
      Text('${context.l10n.openIncidents}: ${r.openIncidents}'),
      if (ref.watch(sessionControllerProvider).user?.isSupervisor ?? false)
        FilledButton.icon(
          onPressed: printing ? null : () => printReport(r),
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(
            printing ? context.l10n.loading : context.l10n.generatePdf,
          ),
        ),
      section(
        context.l10n.completedTasks,
        r.completedTasks
            .map(
              (e) =>
                  '${e.task.title} · ${e.workerName} · ${day(e.completedOn)}',
            )
            .toList(),
      ),
      section(
        context.l10n.entry,
        r.entries
            .map(
              (e) =>
                  '${e.materialName}: ${e.quantity} ${e.unit} · ${day(e.occurredAt)}',
            )
            .toList(),
      ),
      section(
        context.l10n.usage,
        r.usages
            .map(
              (e) =>
                  '${e.materialName}: ${e.quantity} ${e.unit} · ${day(e.occurredAt)}',
            )
            .toList(),
      ),
      section(
        context.l10n.incidents,
        r.incidents
            .map(
              (e) =>
                  '${e.description} · ${localizedValue(context.l10n, e.status.apiValue)}',
            )
            .toList(),
      ),
      section(
        context.l10n.lowStock,
        r.lowStockMaterials
            .map((e) => '${e.name}: ${e.stock} / ${e.minimumStock} ${e.unit}')
            .toList(),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final provider = weeklyReportProvider(date);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reports)),
      body: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              IconButton(
                tooltip: context.l10n.previousWeek,
                onPressed: () => setState(
                  () => date = DateTime(date.year, date.month, date.day - 7),
                ),
                icon: const Icon(Icons.chevron_left),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => date = WeekRange(DateTime.now()).start),
                child: Text(context.l10n.currentWeek),
              ),
              IconButton(
                tooltip: context.l10n.nextWeek,
                onPressed: date.isBefore(WeekRange(DateTime.now()).start)
                    ? () => setState(
                        () => date = DateTime(
                          date.year,
                          date.month,
                          date.day + 7,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                tooltip: context.l10n.selectDate,
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selected != null && mounted) {
                    setState(() => date = WeekRange(selected).start);
                  }
                },
                icon: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          Text('${day(date)} - ${day(WeekRange(date).end)}'),
          Expanded(
            child: ref
                .watch(provider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => AppErrorView(
                    message: ErrorMapper.message(context.l10n, e),
                    retryLabel: context.l10n.retry,
                    onRetry: () => ref.invalidate(provider),
                  ),
                  data: (r) => RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(provider);
                      await ref.read(provider.future);
                    },
                    child: reportView(r),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
