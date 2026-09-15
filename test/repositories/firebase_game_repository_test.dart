import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/game_data_service.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';
import 'package:touring_game/services/game/firebase_game_repository.dart';

import '../helpers/fake_firebase_services.dart';

void main() {
  late FakeAuthService authService;
  late FakeGameDataService dataService;
  late FakeNoteImageStorageService imageStorageService;
  late FirebaseGameRepository repository;

  setUp(() {
    authService = FakeAuthService(
      user: AuthServiceUser(
        id: 'user-1',
        email: 'user@example.com',
        isEmailVerified: true,
        lastSignInTime: DateTime.now(),
      ),
    );
    dataService = FakeGameDataService();
    imageStorageService = FakeNoteImageStorageService();
    repository = FirebaseGameRepository(
      authService: authService,
      dataService: dataService,
      imageStorageService: imageStorageService,
    );
  });

  test('maps service DTOs into domain catalog models', () async {
    dataService.places = const [
      GameServicePlace(id: 'place-1', name: 'Kraków'),
    ];
    dataService.activities['place-1'] = const [
      GameServiceActivity(
        id: 'activity-1',
        placeId: 'place-1',
        name: 'Wawel Castle',
        webUrl: 'https://example.com',
        latitude: 50.054,
        longitude: 19.935,
        isDone: false,
      ),
    ];

    final catalog = await repository.loadCatalog();

    expect(catalog.places.single.name, 'Kraków');
    expect(catalog.activities.single.name, 'Wawel Castle');
    expect(catalog.activities.single.coords.latitude, 50.054);
  });

  test(
    'saving an image note coordinates local storage and Firestore metadata',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'touring-game-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final image = File('${directory.path}${Platform.pathSeparator}photo.jpg');
      await image.writeAsBytes(const [1, 2, 3]);
      final note = DatabaseNote(
        id: 'note-1',
        activityId: 'activity-1',
        content: '',
        color: '0xffffeb3b',
        positionX: 1,
        positionY: 2,
        isImage: true,
        imagePath: image.path,
      );

      final savedNote = await repository.saveNote(note);

      expect(imageStorageService.savedImages.single.userId, 'user-1');
      expect(imageStorageService.savedImages.single.noteId, 'note-1');
      expect(imageStorageService.savedImages.single.sourcePath, image.path);
      expect(dataService.savedNoteUserId, 'user-1');
      expect(dataService.savedNote?.content, 'local-note-1.jpg');
      expect(dataService.savedNote?.isImage, isTrue);
      expect(savedNote.imagePath, endsWith('local-note-1.jpg'));
      expect(savedNote.imageUrl, isNull);
    },
  );

  test('failed Firestore save removes the newly copied local image', () async {
    final directory = await Directory.systemTemp.createTemp(
      'touring-game-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}${Platform.pathSeparator}photo.jpg');
    await image.writeAsBytes(const [1, 2, 3]);
    dataService.saveError = const FirebaseServiceException(
      code: 'unavailable',
      cause: 'offline',
    );
    final note = DatabaseNote(
      id: 'note-1',
      activityId: 'activity-1',
      content: '',
      color: '0xffffeb3b',
      positionX: 1,
      positionY: 2,
      isImage: true,
      imagePath: image.path,
    );

    await expectLater(repository.saveNote(note), throwsA(isA<DataException>()));

    expect(imageStorageService.savedImages, hasLength(1));
    expect(
      imageStorageService.deletedImages.single.fileName,
      'local-note-1.jpg',
    );
  });

  test('failed image replacement keeps the previously stored image', () async {
    final directory = await Directory.systemTemp.createTemp(
      'touring-game-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}${Platform.pathSeparator}new.jpg');
    await image.writeAsBytes(const [1, 2, 3]);
    dataService.saveError = const FirebaseServiceException(
      code: 'unavailable',
      cause: 'offline',
    );
    const previous = DatabaseNote(
      id: 'note-1',
      activityId: 'activity-1',
      content: '',
      color: '0xffffeb3b',
      positionX: 1,
      positionY: 2,
      isImage: true,
      imagePath: 'old.jpg',
      imageUrl: 'https://example.com/old.jpg',
    );
    final updated = previous.copyWith(imagePath: image.path);

    await expectLater(
      repository.updateNote(previous, updated),
      throwsA(isA<DataException>()),
    );

    expect(imageStorageService.deletedImages, hasLength(1));
    expect(
      imageStorageService.deletedImages.single.fileName,
      'local-note-1.jpg',
    );
  });

  test(
    'note deletion commits Firestore before best-effort image cleanup',
    () async {
      imageStorageService.deleteError = const FirebaseServiceException(
        code: 'unavailable',
        cause: 'offline',
      );
      const note = DatabaseNote(
        id: 'note-1',
        activityId: 'activity-1',
        content: '',
        color: '0xffffeb3b',
        positionX: 1,
        positionY: 2,
        isImage: true,
        imagePath: 'stored.jpg',
      );

      await repository.deleteNote(note);

      expect(dataService.deletedNoteId, note.id);
      expect(imageStorageService.deletedImages.single.userId, 'user-1');
      expect(imageStorageService.deletedImages.single.fileName, 'stored.jpg');
    },
  );

  test('loading image notes resolves their device-local paths', () async {
    dataService.notes = const [
      GameServiceNote(
        id: 'note-1',
        activityId: 'activity-1',
        content: 'stored.jpg',
        color: '0xffffeb3b',
        positionX: 1,
        positionY: 2,
        isImage: true,
      ),
    ];
    imageStorageService.resolvedPaths['stored.jpg'] =
        '${Directory.systemTemp.path}${Platform.pathSeparator}stored.jpg';

    final notes = await repository.loadNotes('activity-1');

    expect(notes.single.imagePath, endsWith('stored.jpg'));
    expect(notes.single.imageUrl, isNull);
  });
}
