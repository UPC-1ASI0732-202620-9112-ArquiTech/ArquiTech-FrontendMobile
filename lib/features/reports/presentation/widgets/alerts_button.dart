import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/localization_context.dart';
import '../controllers/reports_controller.dart';

class AlertsButton extends ConsumerWidget {
  const AlertsButton({super.key, required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectAlertsProvider(projectId));
    final count = state.valueOrNull?.length ?? 0;
    return IconButton(
      tooltip: context.l10n.alerts,
      onPressed: () => context.push('/projects/$projectId/alerts'),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: Icon(
          state.hasError
              ? Icons.notifications_off_outlined
              : Icons.notifications_outlined,
        ),
      ),
    );
  }
}
