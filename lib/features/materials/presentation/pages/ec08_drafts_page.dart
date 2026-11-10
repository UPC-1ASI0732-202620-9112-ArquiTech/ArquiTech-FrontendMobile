import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/role_permissions.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../data/ec08_draft_store.dart';
import '../../domain/entities/material_movement.dart';
import '../controllers/materials_controller.dart';

/// EC08 B: drafts stored locally. Synchronization is opt-in on a local API.
class Ec08DraftsPage extends ConsumerStatefulWidget {
  const Ec08DraftsPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<Ec08DraftsPage> createState() => _Ec08DraftsPageState();
}

class _Ec08DraftsPageState extends ConsumerState<Ec08DraftsPage> {
  Ec08DraftStore? _store;
  List<Ec08Draft> _drafts = const [];
  String? _error;
  bool _busy = false;
  final _materialId = TextEditingController();
  final _quantity = TextEditingController();
  final _supplier = TextEditingController();
  String _type = 'USAGE';

  static const allowSync = bool.fromEnvironment('EC08_ALLOW_SYNC', defaultValue: false);
  bool get syncEnabled => allowSync && (
    AppConfig.apiUri.host == 'localhost' ||
    AppConfig.apiUri.host == '127.0.0.1' ||
    AppConfig.apiUri.host == '10.0.2.2'
  );

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() {
    _materialId.dispose();
    _quantity.dispose();
    _supplier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final store = Ec08DraftStore(prefs);
      final drafts = store.load(widget.projectId);
      if (mounted) setState(() { _store = store; _drafts = drafts; _error = null; });
    } catch (error) {
      if (mounted) setState(() => _error = 'No se pudo abrir la cola local: $error');
    }
  }

  Future<void> _save() async {
    final store = _store;
    if (store == null || _busy) return;
    final material = int.tryParse(_materialId.text.trim());
    final quantity = double.tryParse(_quantity.text.trim());
    if (material == null || material <= 0 || quantity == null || !quantity.isFinite || quantity <= 0 ||
        (_type == 'ENTRY' && _supplier.text.trim().isEmpty)) {
      setState(() => _error = 'Se requiere un material válido, cantidad positiva y proveedor para entradas.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final now = DateTime.now().toUtc();
      await store.add(Ec08Draft(
        id: '${widget.projectId}-${now.microsecondsSinceEpoch}',
        projectId: widget.projectId, materialId: material,
        type: _type, quantity: quantity, supplier: _supplier.text.trim(),
        occurredAt: now, state: 'pending',
      ));
      if (mounted) {
        setState(() { _drafts = store.load(widget.projectId); _materialId.clear(); _quantity.clear(); });
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'No se pudo guardar: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sync() async {
    final store = _store;
    if (store == null || _busy || !syncEnabled) return;
    final role = ref.read(sessionControllerProvider).user?.role;
    if (role == null || !RolePermissions.canWriteMaterials(role)) return;
    setState(() { _busy = true; _error = null; });
    var sent = 0;
    try {
      final controller = ref.read(materialsControllerProvider(widget.projectId).notifier);
      for (final draft in store.load(widget.projectId).where((d) => d.state == 'pending')) {
        // Mark BEFORE POST: an uncertain response must not be retried blindly.
        await store.updateState(draft, 'review');
        if (mounted) setState(() => _drafts = store.load(widget.projectId));
        try {
          if (draft.type == 'ENTRY') {
            await controller.entry(draft.materialId, MaterialEntryRequest(
              quantity: draft.quantity, supplier: draft.supplier,
              occurredAt: draft.occurredAt, note: 'EC08 demo draft ${draft.id}',
            ));
          } else {
            await controller.usage(draft.materialId, MaterialUsageRequest(
              quantity: draft.quantity, occurredAt: draft.occurredAt,
              note: 'EC08 demo draft ${draft.id}',
            ));
          }
          await store.remove(draft);
          sent++;
        } catch (error) {
          if (mounted) {
            setState(() => _error =
              'Sincronización interrumpida: verifica historial antes de reintentar. $error');
          }
          break;
        }
      }
      if (mounted) setState(() => _drafts = store.load(widget.projectId));
      if (mounted && _error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$sent borradores confirmados y eliminados de la cola.')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Error de sincronización: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rearm(Ec08Draft draft) async {
    final store = _store;
    if (store == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comprobar duplicados antes de repetir'),
        content: const Text(
          'Comprueba el historial: si el movimiento ya llegó al servidor, no lo reenvíes. '
          '¿Confirmas que verificaste que no existe?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar revisión')),
        ],
      ),
    );
    if (confirmed != true) return;
    await store.updateState(draft, 'pending');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(sessionControllerProvider).user?.role;
    final canWrite = role != null && RolePermissions.canWriteMaterials(role);
    return Scaffold(
      appBar: AppBar(title: const Text('EC08 - Borradores sin conexión')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(child: Padding(
            padding: EdgeInsets.all(14),
            child: Text('Variante B experimental. Borradores persistentes en dispositivo; '
              'sincronización únicamente con API local de prueba. '
              'Sin claves de idempotencia del servidor no se garantiza exactamente una entrega.'),
          )),
          if (_error != null)
            Padding(padding: const EdgeInsets.all(8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (!canWrite)
            const Text('Solo un supervisor puede registrar movimientos.')
          else ...[
            TextField(controller: _materialId, decoration: const InputDecoration(
              labelText: 'ID del material', helperText: 'Material existente del proyecto de ensayo')),
            TextField(controller: _quantity, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cantidad')),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Operación'),
              items: const [
                DropdownMenuItem(value: 'USAGE', child: Text('Uso')),
                DropdownMenuItem(value: 'ENTRY', child: Text('Entrada')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'USAGE'),
            ),
            if (_type == 'ENTRY')
              TextField(controller: _supplier, decoration: const InputDecoration(labelText: 'Proveedor')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _busy || _store == null ? null : _save,
              child: const Text('Guardar borrador local')),
          ],
          const SizedBox(height: 18),
          Text('Borradores pendientes (${_drafts.length})',
            style: Theme.of(context).textTheme.titleLarge),
          for (final draft in _drafts)
            Card(child: ListTile(
              title: Text('${draft.type} - material #${draft.materialId} - ${draft.quantity}'),
              subtitle: Text("ID: ${draft.id}\n${draft.state == 'review' ? 'Revisar antes de repetir' : 'Pendiente'}"),
              isThreeLine: true,
              trailing: draft.state == 'review'
                ? IconButton(tooltip: 'Verificar antes del reintento',
                    icon: const Icon(Icons.fact_check), onPressed: () => _rearm(draft))
                : const Icon(Icons.cloud_upload_outlined),
            )),
          const SizedBox(height: 12),
          if (!syncEnabled) const Text(
            'Sincronización desactivada. Ejecuta con EC08_ALLOW_SYNC=true y '
            'API_BASE_URL apuntando a un servidor local de ensayo, nunca producción.'),
          FilledButton.icon(
            onPressed: syncEnabled && !_busy && canWrite &&
              _drafts.any((d) => d.state == 'pending') ? _sync : null,
            icon: const Icon(Icons.sync),
            label: const Text('Sincronizar con API local de ensayo'),
          ),
        ],
      ),
    );
  }
}
