import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local experimental draft. No network access occurs in this store.
class Ec08Draft {
  const Ec08Draft({
    required this.id,
    required this.projectId,
    required this.materialId,
    required this.type,
    required this.quantity,
    required this.supplier,
    required this.occurredAt,
    required this.state,
  });

  final String id;
  final int projectId;
  final int materialId;
  final String type; // ENTRY or USAGE
  final double quantity;
  final String supplier;
  final DateTime occurredAt;
  final String state; // pending or review; review is NEVER automatically retried

  Ec08Draft withState(String next) => Ec08Draft(
    id: id,
    projectId: projectId,
    materialId: materialId,
    type: type,
    quantity: quantity,
    supplier: supplier,
    occurredAt: occurredAt,
    state: next,
  );

  Map<String, Object> toJson() => {
    'id': id, 'projectId': projectId, 'materialId': materialId,
    'type': type, 'quantity': quantity, 'supplier': supplier,
    'occurredAt': occurredAt.toIso8601String(), 'state': state,
  };

  factory Ec08Draft.fromJson(Map<String, dynamic> json) => Ec08Draft(
    id: json['id'] as String,
    projectId: json['projectId'] as int,
    materialId: json['materialId'] as int,
    type: json['type'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    supplier: json['supplier'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String),
    state: json['state'] as String,
  );
}

class Ec08DraftStore {
  Ec08DraftStore(this.prefs);
  final SharedPreferences prefs;
  static String key(int projectId) => 'arquitech.ec08.drafts.$projectId';

  List<Ec08Draft> load(int projectId) {
    try {
      final value = prefs.getString(key(projectId));
      if (value == null) return [];
      final rows = jsonDecode(value) as List<dynamic>;
      return rows.map((row) =>
          Ec08Draft.fromJson(Map<String, dynamic>.from(row as Map))).toList();
    } catch (_) {
      // Corrupt data must not silently be treated as an empty queue:
      // the UI must surface it before writing a new queue.
      throw const FormatException('No se pudo leer la cola de borradores locales.');
    }
  }

  Future<void> replace(int projectId, List<Ec08Draft> drafts) async {
    final ids = drafts.map((draft) => draft.id).toSet();
    if (ids.length != drafts.length || drafts.any((d) => d.projectId != projectId)) {
      throw ArgumentError('Cola de borradores inconsistente.');
    }
    final ok = await prefs.setString(key(projectId), jsonEncode(drafts.map((d) => d.toJson()).toList()));
    if (!ok) throw StateError('No se pudo persistir la cola de borradores.');
  }

  Future<void> add(Ec08Draft draft) async {
    final current = load(draft.projectId);
    if (current.any((item) => item.id == draft.id)) throw StateError('Identificador duplicado');
    await replace(draft.projectId, [...current, draft]);
  }

  Future<void> updateState(Ec08Draft draft, String state) async {
    final current = load(draft.projectId);
    if (!current.any((item) => item.id == draft.id)) return;
    await replace(draft.projectId, [
      for (final item in current) item.id == draft.id ? item.withState(state) : item,
    ]);
  }

  Future<void> remove(Ec08Draft draft) async {
    final current = load(draft.projectId);
    await replace(draft.projectId, current.where((item) => item.id != draft.id).toList());
  }
}
