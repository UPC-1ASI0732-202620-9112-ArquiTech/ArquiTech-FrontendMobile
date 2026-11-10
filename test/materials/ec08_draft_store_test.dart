import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arquitech/features/materials/data/ec08_draft_store.dart';

Ec08Draft exampleDraft({String id = 'demo-1'}) => Ec08Draft(
  id: id,
  projectId: 11,
  materialId: 4,
  type: 'USAGE',
  quantity: 2.5,
  supplier: '',
  occurredAt: DateTime.utc(2026, 11, 9, 10),
  state: 'pending',
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('stores and reloads offline drafts in shared preferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = Ec08DraftStore(prefs);
    await store.add(exampleDraft());
    final another = Ec08DraftStore(prefs);
    final row = another.load(11).single;
    expect(row.id, 'demo-1');
    expect(row.materialId, 4);
    expect(row.quantity, 2.5);
    expect(row.state, 'pending');
  });

  test('requires review before retrying an uncertain request', () async {
    final store = Ec08DraftStore(await SharedPreferences.getInstance());
    final draft = exampleDraft();
    await store.add(draft);
    await store.updateState(draft, 'review');
    expect(store.load(11).single.state, 'review');
    await store.updateState(draft, 'pending');
    expect(store.load(11).single.state, 'pending');
    await store.remove(draft);
    expect(store.load(11), isEmpty);
  });

  test('rejects duplicate draft identifiers', () async {
    final store = Ec08DraftStore(await SharedPreferences.getInstance());
    await store.add(exampleDraft());
    await expectLater(store.add(exampleDraft()), throwsStateError);
    expect(store.load(11).length, 1);
  });

  test('isolates drafts from different projects', () async {
    final store = Ec08DraftStore(await SharedPreferences.getInstance());
    await store.add(exampleDraft());
    expect(store.load(12), isEmpty);
    expect(store.load(11).length, 1);
  });

  test('does not silently erase corrupted drafts', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Ec08DraftStore.key(11), 'not json');
    final store = Ec08DraftStore(prefs);
    expect(() => store.load(11), throwsFormatException);
  });
}
