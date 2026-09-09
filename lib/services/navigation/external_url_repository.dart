import 'package:touring_game/core/errors/app_exception.dart';
import 'package:url_launcher/url_launcher.dart';

abstract interface class ExternalUrlRepository {
  Future<void> open(Uri uri);
}

class DeviceExternalUrlRepository implements ExternalUrlRepository {
  const DeviceExternalUrlRepository();

  @override
  Future<void> open(Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw const ExternalNavigationException(
          'Could not open the activity page in a browser.',
        );
      }
    } on AppException {
      rethrow;
    } on Exception catch (error) {
      throw ExternalNavigationException(
        'Could not open the activity page in a browser.',
        error,
      );
    }
  }
}
