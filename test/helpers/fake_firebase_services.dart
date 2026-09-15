import 'package:path/path.dart' as path;
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/game_data_service.dart';
import 'package:touring_game/services/media/note_image_storage_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.user});

  AuthServiceUser? user;
  Object? error;
  Object? deleteError;
  bool initialized = false;
  bool userDeleted = false;

  @override
  AuthServiceUser? get currentUser => user;

  @override
  Stream<AuthServiceUser?> watchAuthState() => const Stream.empty();

  @override
  Future<void> initialize() async {
    initialized = true;
    if (error case final error?) {
      throw error;
    }
  }

  @override
  Future<void> reloadCurrentUser() async {
    if (error case final error?) {
      throw error;
    }
  }

  @override
  Future<void> createUser({
    required String email,
    required String password,
  }) async {
    if (error case final error?) {
      throw error;
    }
  }

  @override
  Future<void> logIn({required String email, required String password}) async {
    if (error case final error?) {
      throw error;
    }
  }

  @override
  Future<void> logOut() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> deleteCurrentUser() async {
    if (deleteError case final error?) {
      throw error;
    }
    userDeleted = true;
    user = null;
  }
}

class FakeNoteImageStorageService implements NoteImageStorageService {
  final List<({String userId, String noteId, String sourcePath})> savedImages =
      [];
  final List<({String userId, String fileName})> deletedImages = [];
  final Map<String, String?> resolvedPaths = {};
  Object? saveError;
  Object? deleteError;

  @override
  Future<String> saveImage({
    required String userId,
    required String noteId,
    required String sourcePath,
  }) async {
    if (saveError case final error?) {
      throw error;
    }
    savedImages.add((userId: userId, noteId: noteId, sourcePath: sourcePath));
    return 'local-$noteId${path.extension(sourcePath)}';
  }

  @override
  Future<String?> findImage({
    required String userId,
    required String fileName,
  }) async => resolvedPaths.containsKey(fileName)
      ? resolvedPaths[fileName]
      : path.join('local', userId, fileName);

  @override
  Future<void> deleteImage({
    required String userId,
    required String fileName,
  }) async {
    deletedImages.add((userId: userId, fileName: fileName));
    if (deleteError case final error?) {
      throw error;
    }
  }
}

class FakeGameDataService implements GameDataService {
  List<GameServicePlace> places = const [];
  final Map<String, List<GameServiceActivity>> activities = {};
  List<GameServiceNote> notes = const [];
  GameServiceNote? savedNote;
  String? savedNoteUserId;
  String? deletedNoteId;
  Object? saveError;
  Object? deleteError;

  @override
  Future<List<GameServicePlace>> loadPlaces() async => places;

  @override
  Future<List<GameServiceActivity>> loadActivities({
    required String placeId,
    required String userId,
  }) async => activities[placeId] ?? const [];

  @override
  Future<void> updateActivityDone({
    required String userId,
    required String activityId,
    required bool isDone,
  }) async {}

  @override
  Future<void> saveNote({
    required String userId,
    required GameServiceNote note,
  }) async {
    if (saveError case final error?) {
      throw error;
    }
    savedNoteUserId = userId;
    savedNote = note;
  }

  @override
  Future<List<GameServiceNote>> loadNotes({
    required String userId,
    required String activityId,
  }) async => notes;

  @override
  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    if (deleteError case final error?) {
      throw error;
    }
    deletedNoteId = noteId;
  }
}
