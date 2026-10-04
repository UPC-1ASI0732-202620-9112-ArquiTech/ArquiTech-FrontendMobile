import 'package:flutter/material.dart';

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: icon == null ? null : Icon(icon, size: 16, color: foreground),
    label: Text(label),
    labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w700),
    backgroundColor: background,
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
  );
}
