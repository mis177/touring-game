import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/game/game_repository.dart';

class DemoGameRepository implements GameRepository {
  final List<DatabaseActivity> _activities = [...demoActivities];
  final Map<String, List<DatabaseNote>> _notesByActivity = {
    'wawel': [
      const DatabaseNote(
        id: 'demo-note',
        activityId: 'wawel',
        content: 'Look for the dragon near the river!',
        color: '4294961979',
        positionX: 0.08,
        positionY: 0.08,
        isImage: false,
        imagePath: null,
      ),
    ],
  };

  static const demoPlaces = [
    DatabasePlace(id: 'krakow', name: 'Kraków'),
    DatabasePlace(id: 'warsaw', name: 'Warsaw'),
  ];

  static const demoActivities = [
    DatabaseActivity(
      id: 'wawel',
      name: 'Explore Wawel Castle',
      webUrl: 'https://en.wikipedia.org/wiki/Wawel_Castle',
      isDone: false,
      coords: Coordinates(latitude: 50.054, longitude: 19.936),
      placeId: 'krakow',
    ),
    DatabaseActivity(
      id: 'market-square',
      name: 'Walk around the Main Market Square',
      webUrl: 'https://en.wikipedia.org/wiki/Main_Market_Square,_Krak%C3%B3w',
      isDone: true,
      coords: Coordinates(latitude: 50.0617, longitude: 19.9373),
      placeId: 'krakow',
    ),
    DatabaseActivity(
      id: 'old-town',
      name: 'Discover Warsaw Old Town',
      webUrl: 'https://en.wikipedia.org/wiki/Warsaw_Old_Town',
      isDone: false,
      coords: Coordinates(latitude: 52.2497, longitude: 21.0122),
      placeId: 'warsaw',
    ),
    DatabaseActivity(
      id: 'lazienki',
      name: 'Relax in Łazienki Park',
      webUrl: 'https://en.wikipedia.org/wiki/%C5%81azienki_Park',
      isDone: false,
      coords: Coordinates(latitude: 52.214, longitude: 21.035),
      placeId: 'warsaw',
    ),
  ];

  @override
  Future<GameCatalog> loadCatalog() async => GameCatalog(
    places: List.unmodifiable(demoPlaces),
    activities: List.unmodifiable(_activities),
  );

  @override
  Future<void> updateActivityDone(DatabaseActivity activity) async {
    final index = _activities.indexWhere((item) => item.id == activity.id);
    if (index >= 0) {
      _activities[index] = activity;
    }
  }

  @override
  Future<List<DatabaseNote>> loadNotes(String activityId) async =>
      List.unmodifiable(_notesByActivity[activityId] ?? const []);

  @override
  Future<DatabaseNote> saveNote(DatabaseNote note) async {
    final notes = _notesByActivity.putIfAbsent(note.activityId, () => []);
    notes.add(note);
    return note;
  }

  @override
  Future<DatabaseNote> updateNote(
    DatabaseNote previousNote,
    DatabaseNote updatedNote,
  ) async {
    final notes = _notesByActivity.putIfAbsent(
      updatedNote.activityId,
      () => [],
    );
    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index >= 0) {
      notes[index] = updatedNote;
    } else {
      notes.add(updatedNote);
    }
    return updatedNote;
  }

  @override
  Future<void> deleteNote(DatabaseNote note) async {
    _notesByActivity[note.activityId]?.removeWhere(
      (storedNote) => storedNote.id == note.id,
    );
  }
}
