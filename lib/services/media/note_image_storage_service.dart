import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:touring_game/core/errors/app_exception.dart';

abstract interface class NoteImageStorageService {
  Future<String> saveImage({
    required String userId,
    required String noteId,
    required String sourcePath,
  });

  Future<String?> findImage({required String userId, required String fileName});

  Future<void> deleteImage({required String userId, required String fileName});
}

class LocalNoteImageStorageService implements NoteImageStorageService {
  LocalNoteImageStorageService({Future<Directory> Function()? rootDirectory})
    : _rootDirectory = rootDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _rootDirectory;

  @override
  Future<String> saveImage({
    required String userId,
    required String noteId,
    required String sourcePath,
  }) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        throw FileSystemException('Selected image does not exist.', sourcePath);
      }

      final directory = await _userDirectory(userId);
      await directory.create(recursive: true);
      final fileName =
          '${_safeSegment(noteId)}_${DateTime.now().microsecondsSinceEpoch}'
          '${path.extension(sourcePath).toLowerCase()}';
      await source.copy(path.join(directory.path, fileName));
      return fileName;
    } catch (error) {
      throw MediaException('Could not store the note image locally.', error);
    }
  }

  @override
  Future<String?> findImage({
    required String userId,
    required String fileName,
  }) async {
    try {
      final file = File(
        path.join((await _userDirectory(userId)).path, path.basename(fileName)),
      );
      return await file.exists() ? file.path : null;
    } catch (error) {
      throw MediaException('Could not load the local note image.', error);
    }
  }

  @override
  Future<void> deleteImage({
    required String userId,
    required String fileName,
  }) async {
    try {
      final file = File(
        path.join((await _userDirectory(userId)).path, path.basename(fileName)),
      );
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      throw MediaException('Could not delete the local note image.', error);
    }
  }

  Future<Directory> _userDirectory(String userId) async {
    final root = await _rootDirectory();
    return Directory(path.join(root.path, 'note_images', _safeSegment(userId)));
  }

  String _safeSegment(String value) =>
      value.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
}
