import 'package:flutter/material.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/feature_placeholder_view.dart';

class MachineryPlaceholderPage extends StatelessWidget {
  const MachineryPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => FeaturePlaceholderView(
    title: context.l10n.machinery,
    message: context.l10n.comingSoon,
    icon: Icons.precision_manufacturing_outlined,
  );
}
