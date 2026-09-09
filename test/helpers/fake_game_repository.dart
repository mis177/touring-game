import 'dart:async';

import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/game_repository.dart';

class FakeGameRepository implements GameRepository {
  FakeGameRepository({
    this.catalog = const GameCatalog(places: [], activities: []),
    this.catalogError,
    this.updateError,
    this.saveError,
    this.notes = const [],
    this.controlledSaves = false,
  });

  final GameCatalog catalog;
  final Exception? catalogError;
  final Exception? updateError;
  final Exception? saveError;
  final List<DatabaseNote> notes;
  final bool controlledSaves;
  final List<DatabaseNote> savedNotes = [];
  final List<Completer<void>> saveCompleters = [];

  @override
  Future<GameCatalog> loadCatalog() async {
    if (catalogError case final error?) {
      throw error;
    }
    return catalog;
  }

  @override
  Future<void> updateActivityDone(DatabaseActivity activity) async {
    if (updateError case final error?) {
      throw error;
    }
  }

  @override
  Future<List<DatabaseNote>> loadNotes(String activityId) async => notes;

  @override
  Future<DatabaseNote> saveNote(DatabaseNote note) async {
    if (saveError case final error?) {
      throw error;
    }
    savedNotes.add(note);
    if (controlledSaves) {
      final completer = Completer<void>();
      saveCompleters.add(completer);
      await completer.future;
    }
    return note;
  }

  @override
  Future<DatabaseNote> updateNote(
    DatabaseNote previousNote,
    DatabaseNote updatedNote,
  ) => saveNote(updatedNote);

  @override
  Future<void> deleteNote(DatabaseNote note) async {}
}
