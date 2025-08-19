import 'dart:async';
import 'models.dart';


/// Abstraction so we can swap persistence later (Hive/SQLite/etc.)
abstract class ProgressRepository {
Future<Map<String, CardProgress>> loadAll();
Future<void> upsert(CardProgress progress);
Stream<void> watchChanges();
}


class InMemoryProgressRepository implements ProgressRepository {
final Map<String, CardProgress> _store = {};
final StreamController<void> _changes = StreamController.broadcast();


@override
Future<Map<String, CardProgress>> loadAll() async => Map.of(_store);


@override
Future<void> upsert(CardProgress progress) async {
_store[progress.cardId] = progress;
_changes.add(null);
}


@override
Stream<void> watchChanges() => _changes.stream;
}