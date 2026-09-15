import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/services/media/note_image_storage_service.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory storageDirectory;
  late LocalNoteImageStorageService service;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'touring-game-local-images-',
    );
    storageDirectory = Directory(path.join(temporaryDirectory.path, 'app'));
    service = LocalNoteImageStorageService(
      rootDirectory: () async => storageDirectory,
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('copies, resolves, and deletes an image in app-local storage', () async {
    final source = File(path.join(temporaryDirectory.path, 'photo.JPG'));
    await source.writeAsBytes(const [1, 2, 3]);

    final fileName = await service.saveImage(
      userId: 'user/1',
      noteId: 'note-1',
      sourcePath: source.path,
    );
    final storedPath = await service.findImage(
      userId: 'user/1',
      fileName: fileName,
    );

    expect(fileName, startsWith('note-1_'));
    expect(fileName, endsWith('.jpg'));
    expect(storedPath, isNotNull);
    expect(await File(storedPath!).readAsBytes(), const [1, 2, 3]);
    expect(path.dirname(storedPath), contains('user_1'));

    await service.deleteImage(userId: 'user/1', fileName: fileName);

    expect(
      await service.findImage(userId: 'user/1', fileName: fileName),
      isNull,
    );
  });

  test('reports a missing selected image as a media error', () async {
    await expectLater(
      service.saveImage(
        userId: 'user-1',
        noteId: 'note-1',
        sourcePath: path.join(temporaryDirectory.path, 'missing.jpg'),
      ),
      throwsA(isA<MediaException>()),
    );
  });
}
