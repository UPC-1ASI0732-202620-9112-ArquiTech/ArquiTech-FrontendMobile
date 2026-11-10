import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/utils/role_permissions.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../data/ec08_draft_store.dart';
import '../../data/ec08_material_catalog.dart';
import '../../domain/entities/material.dart' as domain;
import '../../domain/entities/material_movement.dart';
import '../controllers/materials_controller.dart';

/// Offline draft entry. Sending is explicitly opt-in and restricted to local APIs.
class Ec08DraftsPage extends ConsumerStatefulWidget {
  const Ec08DraftsPage({super.key, required this.projectId});

  final int projectId;

  @override
  ConsumerState<Ec08DraftsPage> createState() => _Ec08DraftsPageState();
}

enum _DraftError {
  draftLoad,
  catalogLoad,
  material,
  quantity,
  supplier,
  save,
  sync,
  review,
}

class _Ec08DraftsPageState extends ConsumerState<Ec08DraftsPage> {
  Ec08DraftStore? _store;
  List<Ec08Draft> _drafts = const [];
  List<Ec08CatalogMaterial> _materials = const [];
  int? _selectedMaterialId;
  _DraftError? _error;
  bool _busy = false;
  bool _syncSupported = false;
  bool _checkingSync = false;
  Timer? _syncProbeTimer;

  final _quantity = TextEditingController();
  final _supplier = TextEditingController();
  String _type = 'USAGE';

  // Only a backend that explicitly supports idempotent writes may receive
  // offline drafts. Older Railway deployments remain read-only for this flow.
  bool get syncEnabled => _syncSupported;

  @override
  void initState() {
    super.initState();
    _load();
    _checkSyncSupport();
    _syncProbeTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkSyncSupport(),
    );
  }

  @override
  void dispose() {
    _syncProbeTimer?.cancel();
    _quantity.dispose();
    _supplier.dispose();
    super.dispose();
  }

  Future<void> _checkSyncSupport() async {
    if (!mounted || _checkingSync || _busy) return;
    _checkingSync = true;
    var supported = false;
    try {
      supported = await ref
          .read(materialsControllerProvider(widget.projectId).notifier)
          .supportsOfflineSync();
    } on Object catch (error) {
      // A missing endpoint or offline network must never enable writes.
      debugPrint('EC08 sync capability unavailable: $error');
    } finally {
      _checkingSync = false;
    }
    if (mounted && supported != _syncSupported) {
      setState(() => _syncSupported = supported);
    }
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final store = Ec08DraftStore(prefs);
      final drafts = store.load(widget.projectId);

      var materials = <Ec08CatalogMaterial>[];
      _DraftError? warning;
      final userId = ref.read(sessionControllerProvider).user?.id;
      if (userId != null) {
        try {
          final catalog = Ec08MaterialCatalog(prefs);
          final online = ref
              .read(materialsControllerProvider(widget.projectId))
              .asData
              ?.value;
          if (online != null) {
            await catalog.save(userId, widget.projectId, online);
          }
          materials = catalog.load(userId, widget.projectId);
        } on Object catch (error) {
          debugPrint('EC08 material catalog error: $error');
          warning = _DraftError.catalogLoad;
        }
      }
      if (!mounted) return;
      setState(() {
        _store = store;
        _drafts = drafts;
        _materials = materials;
        _selectedMaterialId = materials.isEmpty ? null : materials.first.id;
        _error = warning;
      });
    } on Object catch (error) {
      debugPrint('EC08 draft loading error: $error');
      if (mounted) setState(() => _error = _DraftError.draftLoad);
    }
  }

  Future<void> _cacheMaterials(List<domain.Material> online) async {
    final userId = ref.read(sessionControllerProvider).user?.id;
    if (userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final catalog = Ec08MaterialCatalog(prefs);
      await catalog.save(userId, widget.projectId, online);
      final items = catalog.load(userId, widget.projectId);
      if (!mounted) return;
      setState(() {
        _materials = items;
        if (!items.any((item) => item.id == _selectedMaterialId)) {
          _selectedMaterialId = items.isEmpty ? null : items.first.id;
        }
        if (_error == _DraftError.catalogLoad) _error = null;
      });
    } on Object catch (error) {
      debugPrint('EC08 material catalog refresh error: $error');
      if (mounted) setState(() => _error = _DraftError.catalogLoad);
    }
  }

  Ec08CatalogMaterial? get selectedMaterial {
    for (final material in _materials) {
      if (material.id == _selectedMaterialId) return material;
    }
    return null;
  }

  Ec08CatalogMaterial? _materialFor(int id) {
    for (final material in _materials) {
      if (material.id == id) return material;
    }
    return null;
  }

  String _quantityLabel(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString();

  Future<void> _save() async {
    final store = _store;
    if (store == null || _busy) return;
    final material = selectedMaterial;
    final quantity = double.tryParse(_quantity.text.trim().replaceAll(',', '.'));
    if (material == null) {
      setState(() => _error = _DraftError.material);
      return;
    }
    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      setState(() => _error = _DraftError.quantity);
      return;
    }
    if (_type == 'ENTRY' && _supplier.text.trim().isEmpty) {
      setState(() => _error = _DraftError.supplier);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final now = DateTime.now().toUtc();
      await store.add(Ec08Draft(
        id: '${widget.projectId}-${now.microsecondsSinceEpoch}',
        projectId: widget.projectId,
        materialId: material.id,
        type: _type,
        quantity: quantity,
        supplier: _type == 'ENTRY' ? _supplier.text.trim() : '',
        occurredAt: now,
        state: 'pending',
      ));
      if (!mounted) return;
      setState(() {
        _drafts = store.load(widget.projectId);
        _quantity.clear();
        _supplier.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ec08DraftSaved)),
      );
    } on Object catch (error) {
      debugPrint('EC08 draft save error: $error');
      if (mounted) setState(() => _error = _DraftError.save);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sync() async {
    final store = _store;
    if (store == null || _busy || !syncEnabled) return;
    final role = ref.read(sessionControllerProvider).user?.role;
    if (role == null || !RolePermissions.canWriteMaterials(role)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    var sent = 0;
    try {
      final controller = ref.read(
        materialsControllerProvider(widget.projectId).notifier,
      );
      for (final draft in store.load(widget.projectId).where(
        (item) => item.state == 'pending',
      )) {
        try {
          await controller.syncOfflineMovement(
            draft.materialId,
            OfflineMovementRequest(
              clientRequestId: draft.id,
              type: draft.type == 'ENTRY' ? MovementType.entry : MovementType.usage,
              quantity: draft.quantity,
              supplier: draft.supplier,
              occurredAt: draft.occurredAt,
              note: 'EC08 offline movement ${draft.id}',
            ),
          );
          // A successful first write or server-confirmed replay are equivalent.
          await store.remove(draft);
          sent++;
        } on Object catch (error) {
          debugPrint('EC08 idempotent sync interrupted: $error');
          if (error is ApiError && error.code == 'OFFLINE_REQUEST_CONFLICT') {
            // A request id used with different content must be reviewed.
            await store.updateState(draft, 'review');
            if (mounted) setState(() => _error = _DraftError.review);
          } else if (mounted) {
            // Ambiguous network response is safe to retry with the same id:
            // the backend's unique constraint prevents a second stock change.
            setState(() => _error = _DraftError.sync);
          }
          break;
        }
      }
      if (!mounted) return;
      setState(() => _drafts = store.load(widget.projectId));
      if (_error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l10n.ec08Sent} $sent')),
        );
      }
    } on Object catch (error) {
      debugPrint('EC08 sync error: $error');
      if (mounted) setState(() => _error = _DraftError.sync);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rearm(Ec08Draft draft) async {
    final store = _store;
    if (store == null || _busy) return;
    final role = ref.read(sessionControllerProvider).user?.role;
    if (role == null || !RolePermissions.canWriteMaterials(role)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.ec08ReviewTitle),
        content: Text(context.l10n.ec08ReviewMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.ec08ReviewConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await store.updateState(draft, 'pending');
      await _load();
    } on Object catch (error) {
      debugPrint('EC08 retry review error: $error');
      if (mounted) setState(() => _error = _DraftError.review);
    }
  }


  Future<void> _deleteDraft(Ec08Draft draft) async {
    final store = _store;
    if (store == null || _busy) return;
    final role = ref.read(sessionControllerProvider).user?.role;
    if (role == null || !RolePermissions.canWriteMaterials(role)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.ec08DeleteDraftTitle),
        content: Text(context.l10n.ec08DeleteDraftMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await store.remove(draft);
      if (!mounted) return;
      setState(() => _drafts = store.load(widget.projectId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ec08DraftDeleted)),
      );
    } on Object catch (error) {
      debugPrint('EC08 local draft deletion failed: $error');
      if (mounted) setState(() => _error = _DraftError.save);
    }
  }

  String? _errorText(BuildContext context) => switch (_error) {
    _DraftError.draftLoad => context.l10n.ec08DraftLoadError,
    _DraftError.catalogLoad => context.l10n.ec08CatalogLoadError,
    _DraftError.material => context.l10n.ec08MaterialRequired,
    _DraftError.quantity => context.l10n.positiveNumber,
    _DraftError.supplier => context.l10n.requiredField,
    _DraftError.save => context.l10n.ec08DraftSaveError,
    _DraftError.sync => context.l10n.ec08SyncError,
    _DraftError.review => context.l10n.ec08SyncReview,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(sessionControllerProvider).user?.role;
    final canWrite = role != null && RolePermissions.canWriteMaterials(role);
    // Refresh cached labels whenever inventory data becomes available.
    ref.listen(materialsControllerProvider(widget.projectId), (_, next) {
      final online = next.asData?.value;
      if (online != null) _cacheMaterials(online);
    });

    final error = _errorText(context);
    final chosen = selectedMaterial;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.ec08PageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud_off_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.ec08Description)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (error != null) ...[
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (!canWrite)
            Text(context.l10n.ec08SupervisorOnly)
          else ...[
            if (_materials.isEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.l10n.ec08CatalogMissing),
                ),
              ),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<int>(
              key: ValueKey('ec08-material-${_selectedMaterialId ?? 'none'}'),
              initialValue: chosen?.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.l10n.materialName,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final material in _materials)
                  DropdownMenuItem(
                    value: material.id,
                    child: Text(
                      '${material.name} (${material.unit})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _busy || _materials.isEmpty
                  ? null
                  : (value) => setState(() => _selectedMaterialId = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: context.l10n.ec08Quantity,
                suffixText: chosen?.unit,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.l10n.ec08Operation,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'USAGE',
                  child: Text(context.l10n.usage),
                ),
                DropdownMenuItem(
                  value: 'ENTRY',
                  child: Text(context.l10n.entry),
                ),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _type = value ?? 'USAGE'),
            ),
            if (_type == 'ENTRY') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _supplier,
                decoration: InputDecoration(
                  labelText: context.l10n.supplier,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy || _store == null || _materials.isEmpty
                  ? null
                  : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(context.l10n.ec08SaveDraft),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '${context.l10n.ec08SavedDrafts} (${_drafts.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_drafts.isEmpty) ...[
            Text(context.l10n.ec08EmptyDrafts),
            const SizedBox(height: 10),
          ],
          for (final draft in _drafts) ...[
            Card(
              child: ListTile(
                leading: Icon(
                  draft.state == 'review'
                      ? Icons.fact_check_outlined
                      : Icons.cloud_off_outlined,
                ),
                title: Text(
                  '${_materialFor(draft.materialId)?.name ?? '#${draft.materialId}'}'
                  ' · ${_quantityLabel(draft.quantity)}'
                  ' ${_materialFor(draft.materialId)?.unit ?? ''}',
                ),
                subtitle: Text(
                  '${draft.type == 'ENTRY' ? context.l10n.entry : context.l10n.usage}'
                  ' · ${draft.state == 'review' ? context.l10n.ec08NeedsReview : context.l10n.ec08Pending}',
                ),
                trailing: canWrite
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (draft.state == 'review')
                            IconButton(
                              tooltip: context.l10n.ec08ReviewConfirm,
                              icon: const Icon(Icons.fact_check),
                              onPressed: _busy ? null : () => _rearm(draft),
                            ),
                          IconButton(
                            tooltip: context.l10n.ec08DeleteDraftTitle,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _busy ? null : () => _deleteDraft(draft),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 16),
          if (!syncEnabled) ...[
            Text(
              context.l10n.ec08SyncUnavailable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _checkingSync ? null : _checkSyncSupport,
              icon: const Icon(Icons.wifi_find_outlined),
              label: Text(context.l10n.ec08CheckConnection),
            ),
            const SizedBox(height: 8),
          ],
          FilledButton.icon(
            onPressed: syncEnabled && !_busy && canWrite &&
                    _drafts.any((draft) => draft.state == 'pending')
                ? _sync
                : null,
            icon: const Icon(Icons.sync),
            label: Text(context.l10n.ec08Sync),
          ),
        ],
      ),
    );
  }
}
