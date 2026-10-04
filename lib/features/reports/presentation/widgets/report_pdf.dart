import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/widgets/localized_value.dart';
import '../../domain/entities/weekly_report.dart';

Future<Uint8List> buildReportPdf(WeeklyReport r, AppLocalizations l) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
  );
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  String day(DateTime d) => d.toLocal().toIso8601String().split('T').first;
  pw.Widget section(String title, List<String> rows) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 16),
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      for (final row in rows.isEmpty ? [l.noRecords] : rows)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(row),
        ),
    ],
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Text(
          'ARQUITECH',
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#C43508'),
          ),
        ),
        pw.Text(r.project.name),
        pw.Text('${day(r.week.start)} - ${day(r.week.end)}'),
        pw.Text('${l.progress}: ${r.project.progress}%'),
        pw.Text(
          '${l.openTasks}: ${r.openTasks} | ${l.openIncidents}: ${r.openIncidents}',
        ),
        section(
          l.completedTasks,
          r.completedTasks
              .map(
                (e) =>
                    '${e.task.title} | ${e.workerName} | ${day(e.completedOn)}',
              )
              .toList(),
        ),
        section(
          l.entry,
          r.entries
              .map(
                (e) =>
                    '${e.materialName}: ${e.quantity} ${e.unit} | ${day(e.occurredAt)}',
              )
              .toList(),
        ),
        section(
          l.usage,
          r.usages
              .map(
                (e) =>
                    '${e.materialName}: ${e.quantity} ${e.unit} | ${day(e.occurredAt)}',
              )
              .toList(),
        ),
        section(
          l.incidents,
          r.incidents
              .map(
                (e) =>
                    '${e.description} | ${localizedValue(l, e.severity.apiValue)} | ${localizedValue(l, e.status.apiValue)}',
              )
              .toList(),
        ),
        section(
          l.lowStock,
          r.lowStockMaterials
              .map((e) => '${e.name}: ${e.stock} / ${e.minimumStock} ${e.unit}')
              .toList(),
        ),
      ],
    ),
  );
  return doc.save();
}
