import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/material.dart' as domain;

enum MaterialAction { edit, entry, usage, delete }

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.material,
    required this.canWrite,
    required this.onAction,
  });

  final domain.Material material;
  final bool canWrite;
  final ValueChanged<MaterialAction> onAction;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).languageCode,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    material.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  currency.format(material.unitPrice),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: AppColors.fulvous),
                ),
                if (canWrite)
                  PopupMenuButton<MaterialAction>(
                    onSelected: onAction,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: MaterialAction.entry,
                        child: Text(context.l10n.registerEntry),
                      ),
                      PopupMenuItem(
                        value: MaterialAction.usage,
                        child: Text(context.l10n.registerUsage),
                      ),
                      PopupMenuItem(
                        value: MaterialAction.edit,
                        child: Text(context.l10n.edit),
                      ),
                      PopupMenuItem(
                        value: MaterialAction.delete,
                        child: Text(context.l10n.delete),
                      ),
                    ],
                  ),
              ],
            ),
            if (material.isLowStock) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: AppStatusChip(
                  label: context.l10n.lowStock,
                  foreground: AppColors.sinopia,
                  background: AppColors.dangerContainer,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: context.l10n.quantity,
                    value:
                        '${_formatQuantity(material.quantity)} ${material.unit}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: context.l10n.stock,
                    value:
                        '${_formatQuantity(material.stock)} ${material.unit}',
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: context.l10n.provider,
                    value: material.provider,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: context.l10n.date,
                    value: material.date == null
                        ? '—'
                        : MaterialLocalizations.of(context)
                              .formatMediumDate(material.date!),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });
  final String label;
  final String value;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: AppColors.mutedText),
      ),
      Text(
        value,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ],
  );
}
