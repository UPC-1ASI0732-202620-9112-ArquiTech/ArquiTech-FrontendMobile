import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/localization_context.dart';
import '../errors/error_mapper.dart';
import 'app_error_view.dart';
import 'localized_value.dart';

class RecordList<T> extends StatefulWidget {
  const RecordList({
    super.key,
    required this.title,
    required this.state,
    required this.refresh,
    required this.statuses,
    required this.status,
    required this.searchText,
    required this.card,
    this.create,
    this.actions = const [],
    this.header,
  });
  final String title;
  final AsyncValue<List<T>> state;
  final Future<void> Function() refresh;
  final List<String> statuses;
  final String Function(T) status, searchText;
  final Widget Function(T) card;
  final VoidCallback? create;
  final List<Widget> actions;
  final Widget? header;
  @override
  State<RecordList<T>> createState() => _RecordListState<T>();
}

class _RecordListState<T> extends State<RecordList<T>> {
  String search = '', filter = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title), actions: widget.actions),
    floatingActionButton: widget.create == null
        ? null
        : FloatingActionButton(
            tooltip: context.l10n.create,
            onPressed: widget.create,
            child: const Icon(Icons.add),
          ),
    body: Column(
      children: [
        if (widget.header != null) widget.header!,
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              labelText: context.l10n.search,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => search = v.toLowerCase()),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in ['', ...widget.statuses])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      s.isEmpty
                          ? context.l10n.all
                          : localizedValue(context.l10n, s),
                    ),
                    selected: filter == s,
                    onSelected: (_) => setState(() => filter = s),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: widget.state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorView(
              message: ErrorMapper.message(context.l10n, e),
              retryLabel: context.l10n.retry,
              onRetry: widget.refresh,
            ),
            data: (items) {
              final visible = items
                  .where(
                    (e) =>
                        (filter.isEmpty || widget.status(e) == filter) &&
                        widget.searchText(e).toLowerCase().contains(search),
                  )
                  .toList();
              return RefreshIndicator(
                onRefresh: widget.refresh,
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  role: SemanticsRole.region,
                  label: widget.title,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: visible.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(context.l10n.noRecords),
                            ),
                          ]
                        : visible
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: widget.card(e),
                                ),
                              )
                              .toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Future<void> deleteRecord(
  BuildContext context,
  Future<void> Function() action,
) async {
  final yes = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(c.l10n.deleteRecord),
      content: Text(c.l10n.deleteWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(c.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(c.l10n.delete),
        ),
      ],
    ),
  );
  if (yes != true || !context.mounted) return;
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.saved)));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorMapper.message(context.l10n, e))),
      );
    }
  }
}
