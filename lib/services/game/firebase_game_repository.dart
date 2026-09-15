import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/models/place.dart';
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';
import 'package:touring_game/services/firebase/game_data_service.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/media/note_image_storage_service.dart';

class FirebaseGameRepository implements GameRepository {
  const FirebaseGameRepository({
    required AuthService authService,
    required GameDataService dataService,
    required NoteImageStorageService imageStorageService,
  }) : _authService = authService,
       _dataService = dataService,
       _imageStorageService = imageStorageService;

  final AuthService _authService;
  final GameDataService _dataService;
  final NoteImageStorageService _imageStorageService;

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
    final userId = _userId;
    String? savedImageName;
    var dataCommitted = false;
    try {
      var storedContent = note.content;
      String? localImagePath = note.imagePath;
      if (note.isImage) {
        final imagePath = note.imagePath;
        if (imagePath == null) {
          throw const DataException('The note image is missing.');
        }
        final localFile = File(imagePath);
        if (await localFile.exists()) {
          savedImageName = await _imageStorageService.saveImage(
            userId: userId,
            noteId: note.id,
            sourcePath: imagePath,
          );
          storedContent = savedImageName;
          localImagePath = await _imageStorageService.findImage(
            userId: userId,
            fileName: savedImageName,
          );
        } else {
          storedContent = path.basename(imagePath);
          localImagePath = await _imageStorageService.findImage(
            userId: userId,
            fileName: storedContent,
          );
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
      if (savedImageName != null) {
        final previousImage = previousNote?.imagePath;
        if (previousImage != null &&
            path.basename(previousImage) != storedContent) {
          await _deleteLocalImageBestEffort(userId, previousImage);
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
        imagePath: note.isImage ? localImagePath : null,
      );
    } on AppException {
      if (!dataCommitted) {
        await _rollbackLocalImage(savedImageName, userId: userId);
      }
      rethrow;
    } on FirebaseServiceException catch (error) {
      if (!dataCommitted) {
        await _rollbackLocalImage(savedImageName, userId: userId);
      }
      throw DataException('Could not save the note.', error.cause);
    } catch (error) {
      if (!dataCommitted) {
        await _rollbackLocalImage(savedImageName, userId: userId);
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
      return await Future.wait(
        notes.map((note) async {
          final localImagePath = note.isImage
              ? await _imageStorageService.findImage(
                  userId: userId,
                  fileName: note.content,
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
            imagePath: localImagePath,
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
        await _deleteLocalImageBestEffort(userId, note.imagePath!);
      }
    } on AppException {
      rethrow;
    } on FirebaseServiceException catch (error) {
      throw DataException('Could not delete the note.', error.cause);
    } catch (error) {
      throw DataException('Could not delete the note.', error);
    }
  }

  Future<void> _deleteLocalImageBestEffort(
    String userId,
    String imagePath,
  ) async {
    try {
      await _imageStorageService.deleteImage(
        userId: userId,
        fileName: path.basename(imagePath),
      );
    } on Exception {
      // The Firestore write is already committed. A stale local file is safer
      // than reverting the visible note.
    }
  }

  Future<void> _rollbackLocalImage(
    String? savedImageName, {
    required String userId,
  }) async {
    if (savedImageName == null) {
      return;
    }
    try {
      await _imageStorageService.deleteImage(
        userId: userId,
        fileName: savedImageName,
      );
    } on Exception {
      // Preserve the original persistence failure.
    }
  }
}
