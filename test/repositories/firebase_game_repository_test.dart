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
  late FakeFileStorageService storageService;
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
    storageService = FakeFileStorageService();
    repository = FirebaseGameRepository(
      authService: authService,
      dataService: dataService,
      storageService: storageService,
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
    'saving an image note coordinates storage and Firestore services',
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

      final uploadedPath = storageService.uploadedFiles.single.$1;
      expect(uploadedPath, startsWith('notes_images/user-1/note-1_'));
      expect(uploadedPath, endsWith('.jpg'));
      expect(storageService.uploadedFiles.single.$2, image.path);
      expect(dataService.savedNoteUserId, 'user-1');
      expect(dataService.savedNote?.content, uploadedPath.split('/').last);
      expect(dataService.savedNote?.isImage, isTrue);
      expect(savedNote.imagePath, uploadedPath.split('/').last);
    },
  );

  test('failed Firestore save removes the newly uploaded image', () async {
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

    expect(storageService.uploadedFiles, hasLength(1));
    expect(storageService.deletedFiles, [
      storageService.uploadedFiles.single.$1,
    ]);
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

    expect(storageService.deletedFiles, hasLength(1));
    expect(storageService.deletedFiles.single, isNot(endsWith('/old.jpg')));
  });

  test(
    'note deletion commits Firestore before best-effort image cleanup',
    () async {
      storageService.deleteFileError = const FirebaseServiceException(
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
      expect(storageService.deletedFiles, ['notes_images/user-1/stored.jpg']);
    },
  );
}
