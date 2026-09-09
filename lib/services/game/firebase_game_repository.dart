import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/file_storage_service.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';
import 'package:touring_game/services/firebase/game_data_service.dart';
import 'package:touring_game/services/game/game_repository.dart';

class FirebaseGameRepository implements GameRepository {
  const FirebaseGameRepository({
    required AuthService authService,
    required GameDataService dataService,
    required FileStorageService storageService,
  }) : _authService = authService,
       _dataService = dataService,
       _storageService = storageService;

  final AuthService _authService;
  final GameDataService _dataService;
  final FileStorageService _storageService;

  String get _userId {
    final user = _authService.currentUser;
    if (user == null) {
      throw const AuthenticationException('You must be signed in.');
    }
    return user.id;
  }

  @override
  Future<GameCatalog> loadCatalog() async {
    try {
      final servicePlaces = await _dataService.loadPlaces();
      final places = servicePlaces
          .map((place) => DatabasePlace(id: place.id, name: place.name))
          .toList(growable: false);
      final userId = _userId;
      final activityGroups = await Future.wait(
        places.map(
          (place) =>
              _dataService.loadActivities(placeId: place.id, userId: userId),
        ),
      );
      final activities = activityGroups
          .expand((group) => group)
          .map(
            (activity) => DatabaseActivity(
              id: activity.id,
              name: activity.name,
              webUrl: activity.webUrl,
              isDone: activity.isDone,
              coords: Coordinates(
                latitude: activity.latitude,
                longitude: activity.longitude,
              ),
              placeId: activity.placeId,
            ),
          )
          .toList(growable: false);
      return GameCatalog(places: places, activities: activities);
    } on AppException {
      rethrow;
    } on FirebaseServiceException catch (error) {
      throw DataException('Could not load places and activities.', error.cause);
    } catch (error) {
      throw DataException('Places and activities contain invalid data.', error);
    }
  }

  @override
  Future<void> updateActivityDone(DatabaseActivity activity) async {
    try {
      await _dataService.updateActivityDone(
        userId: _userId,
        activityId: activity.id,
        isDone: activity.isDone,
      );
    } on AppException {
      rethrow;
    } on FirebaseServiceException catch (error) {
      throw DataException('Could not update the activity.', error.cause);
    } catch (error) {
      throw DataException('Could not update the activity.', error);
    }
  }

  @override
  Future<DatabaseNote> saveNote(DatabaseNote note) => _persistNote(note);

  @override
  Future<DatabaseNote> updateNote(
    DatabaseNote previousNote,
    DatabaseNote updatedNote,
  ) => _persistNote(updatedNote, previousNote: previousNote);

  Future<DatabaseNote> _persistNote(
    DatabaseNote note, {
    DatabaseNote? previousNote,
  }) async {
    String? uploadedPath;
    var dataCommitted = false;
    try {
      final userId = _userId;
      var storedContent = note.content;
      String? imageUrl = note.imageUrl;
      if (note.isImage) {
        final imagePath = note.imagePath;
        if (imagePath == null) {
          throw const DataException('The note image is missing.');
        }
        final localFile = File(imagePath);
        if (await localFile.exists()) {
          storedContent = _newImageName(note.id, imagePath);
          uploadedPath = _imagePathFor(userId, storedContent);
          await _storageService.uploadFile(uploadedPath, imagePath);
          imageUrl = await _storageService.getDownloadUrl(uploadedPath);
          if (imageUrl == null) {
            throw const DataException(
              'The uploaded note image is not available.',
            );
          }
        } else {
          storedContent = path.basename(imagePath);
        }
      }
      await _dataService.saveNote(
        userId: userId,
        note: GameServiceNote(
          id: note.id,
          activityId: note.activityId,
          content: storedContent,
          color: note.color,
          positionX: note.positionX,
          positionY: note.positionY,
          isImage: note.isImage,
        ),
      );
      dataCommitted = true;
      if (uploadedPath != null) {
        final previousImage = previousNote?.imagePath;
        if (previousImage != null &&
            path.basename(previousImage) != storedContent) {
          await _deleteImageBestEffort(userId, previousImage);
        }
      }
      return DatabaseNote(
        id: note.id,
        activityId: note.activityId,
        content: note.content,
        color: note.color,
        positionX: note.positionX,
        positionY: note.positionY,
        isImage: note.isImage,
        imagePath: note.isImage ? storedContent : null,
        imageUrl: imageUrl,
      );
    } on AppException {
      if (!dataCommitted) {
        await _rollbackUpload(uploadedPath);
      }
      rethrow;
    } on FirebaseServiceException catch (error) {
      if (!dataCommitted) {
        await _rollbackUpload(uploadedPath);
      }
      throw DataException('Could not save the note.', error.cause);
    } catch (error) {
      if (!dataCommitted) {
        await _rollbackUpload(uploadedPath);
      }
      throw DataException('Could not save the note.', error);
    }
  }

  @override
  Future<List<DatabaseNote>> loadNotes(String activityId) async {
    try {
      final userId = _userId;
      final notes = await _dataService.loadNotes(
        userId: userId,
        activityId: activityId,
      );
      return Future.wait(
        notes.map((note) async {
          final imageUrl = note.isImage
              ? await _storageService.getDownloadUrl(
                  _imagePathFor(userId, note.content),
                )
              : null;
          return DatabaseNote(
            id: note.id,
            activityId: note.activityId,
            content: note.isImage ? '' : note.content,
            color: note.color,
            positionX: note.positionX,
            positionY: note.positionY,
            isImage: note.isImage,
            imagePath: note.isImage ? note.content : null,
            imageUrl: imageUrl,
          );
        }),
      );
    } on AppException {
      rethrow;
    } on FirebaseServiceException catch (error) {
      throw DataException('Could not load notes.', error.cause);
    } catch (error) {
      throw DataException('Notes contain invalid data.', error);
    }
  }

  @override
  Future<void> deleteNote(DatabaseNote note) async {
    try {
      final userId = _userId;
      await _dataService.deleteNote(userId: userId, noteId: note.id);
      if (note.isImage && note.imagePath != null) {
        await _deleteImageBestEffort(userId, note.imagePath!);
      }
    } on AppException {
      rethrow;
    } on FirebaseServiceException catch (error) {
      throw DataException('Could not delete the note.', error.cause);
    } catch (error) {
      throw DataException('Could not delete the note.', error);
    }
  }

  Future<void> _deleteImageBestEffort(String userId, String imagePath) async {
    try {
      await _storageService.deleteFile(_imagePathFor(userId, imagePath));
    } on Exception {
      // The Firestore write is already committed. A stale file is safer than
      // reverting the visible note to a broken image reference.
    }
  }

  Future<void> _rollbackUpload(String? remotePath) async {
    if (remotePath == null) {
      return;
    }
    try {
      await _storageService.deleteFile(remotePath);
    } on Exception {
      // Preserve the original failure; account deletion can clean stale files.
    }
  }

  String _newImageName(String noteId, String localPath) =>
      '${noteId}_${DateTime.now().microsecondsSinceEpoch}'
      '${path.extension(localPath)}';

  String _imagePathFor(String userId, String imagePath) =>
      'notes_images/$userId/${path.basename(imagePath)}';
}
