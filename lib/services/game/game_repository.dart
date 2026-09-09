import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/models/place.dart';

class GameCatalog {
  const GameCatalog({required this.places, required this.activities});

  final List<DatabasePlace> places;
  final List<DatabaseActivity> activities;
}

abstract interface class CatalogRepository {
  Future<GameCatalog> loadCatalog();
}

abstract interface class ActivityProgressRepository {
  Future<void> updateActivityDone(DatabaseActivity activity);
}

abstract interface class NotesRepository {
  Future<List<DatabaseNote>> loadNotes(String activityId);
  Future<DatabaseNote> saveNote(DatabaseNote note);
  Future<DatabaseNote> updateNote(
    DatabaseNote previousNote,
    DatabaseNote updatedNote,
  );
  Future<void> deleteNote(DatabaseNote note);
}

abstract interface class GameRepository
    implements CatalogRepository, ActivityProgressRepository, NotesRepository {}
