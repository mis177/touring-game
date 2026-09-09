import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:touring_game/core/errors/app_exception.dart';

abstract interface class ImagePickerRepository {
  Future<String?> pickFromGallery();
}

class DeviceImagePickerRepository implements ImagePickerRepository {
  DeviceImagePickerRepository({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } on PlatformException catch (error) {
      throw MediaException('Could not open the image gallery.', error);
    } on Exception catch (error) {
      throw MediaException('Could not select an image.', error);
    }
  }
}
