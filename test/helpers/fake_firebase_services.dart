import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/file_storage_service.dart';
import 'package:touring_game/services/firebase/game_data_service.dart';
import 'package:touring_game/services/firebase/user_data_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.user});

  AuthServiceUser? user;
  Object? error;
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
    userDeleted = true;
  }
}

class FakeUserDataService implements UserDataService {
  String? deletedUserId;
  Object? error;

  @override
  Future<void> deleteUserData(String userId) async {
    if (error case final error?) {
      throw error;
    }
    deletedUserId = userId;
  }
}

class FakeFileStorageService implements FileStorageService {
  final List<(String, String)> uploadedFiles = [];
  final List<String> deletedFiles = [];
  final List<String> deletedFolders = [];
  final Map<String, String?> downloadUrls = {};
  String? defaultDownloadUrl = 'https://example.com/image';
  Object? uploadError;
  Object? deleteFileError;
  Object? deleteFolderError;

  @override
  Future<void> uploadFile(String remotePath, String localPath) async {
    if (uploadError case final error?) {
      throw error;
    }
    uploadedFiles.add((remotePath, localPath));
  }

  @override
  Future<String?> getDownloadUrl(String remotePath) async =>
      downloadUrls.containsKey(remotePath)
      ? downloadUrls[remotePath]
      : defaultDownloadUrl;

  @override
  Future<void> deleteFile(String remotePath) async {
    deletedFiles.add(remotePath);
    if (deleteFileError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> deleteFolder(String remotePath) async {
    if (deleteFolderError case final error?) {
      throw error;
    }
    deletedFolders.add(remotePath);
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
