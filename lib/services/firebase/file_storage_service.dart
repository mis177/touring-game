import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';

abstract interface class FileStorageService {
  Future<void> uploadFile(String remotePath, String localPath);
  Future<String?> getDownloadUrl(String remotePath);
  Future<void> deleteFile(String remotePath);
  Future<void> deleteFolder(String remotePath);
}

class FirebaseFileStorageService implements FileStorageService {
  FirebaseFileStorageService({FirebaseStorage? storage})
    : _storageOverride = storage;

  final FirebaseStorage? _storageOverride;

  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;

  @override
  Future<void> uploadFile(String remotePath, String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await _storage.ref(remotePath).putFile(file);
      }
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  @override
  Future<String?> getDownloadUrl(String remotePath) async {
    try {
      return await _storage.ref(remotePath).getDownloadURL();
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        return null;
      }
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  @override
  Future<void> deleteFile(String remotePath) async {
    try {
      await _storage.ref(remotePath).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        throw FirebaseServiceException(code: error.code, cause: error);
      }
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  @override
  Future<void> deleteFolder(String remotePath) async {
    try {
      await _deleteFolder(remotePath);
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  Future<void> _deleteFolder(String remotePath) async {
    final result = await _storage.ref(remotePath).listAll();
    await Future.wait(result.items.map((item) => item.delete()));
    await Future.wait(
      result.prefixes.map((prefix) => _deleteFolder(prefix.fullPath)),
    );
  }
}
