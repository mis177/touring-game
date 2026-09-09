import 'package:flutter/widgets.dart';
import 'package:touring_game/main.dart';
import 'package:touring_game/models/address.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/auth/auth_repository.dart';
import 'package:touring_game/services/auth/auth_user.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:touring_game/services/map/place_search_repository.dart';
import 'package:touring_game/services/media/image_picker_repository.dart';
import 'package:touring_game/services/navigation/external_url_repository.dart';
import 'package:touring_game/services/theme/theme_repository.dart';

Widget buildTestApp({
  required AuthRepository authRepository,
  required GameRepository gameRepository,
  bool isDemoMode = false,
}) {
  return TouringGameApp(
    authRepository: authRepository,
    gameRepository: gameRepository,
    searchRepository: FakePlaceSearchRepository(),
    locationRepository: const FakeLocationRepository(),
    imagePickerRepository: const FakeImagePickerRepository(),
    externalUrlRepository: const FakeExternalUrlRepository(),
    themeRepository: const FakeThemeRepository(),
    isDemoMode: isDemoMode,
  );
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? currentUser, this.verificationError})
    : _currentUser = currentUser;

  AuthUser? _currentUser;
  final Exception? verificationError;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> watchAuthState() => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<AuthUser?> refreshCurrentUser() async => _currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    return _currentUser = AuthUser(
      id: 'user-1',
      email: email,
      isEmailVerified: true,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    return _currentUser = AuthUser(
      id: 'user-1',
      email: email,
      isEmailVerified: false,
    );
  }

  @override
  Future<void> logOut() async => _currentUser = null;

  @override
  Future<void> sendEmailVerification() async {
    if (verificationError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> sendPasswordResetForCurrentUser() async {}

  @override
  Future<void> deleteUser() async => _currentUser = null;
}

class FakePlaceSearchRepository implements PlaceSearchRepository {
  @override
  Future<List<AddressModel>> search(String query) async => const [];

  @override
  void close() {}
}

class FakeLocationRepository implements LocationRepository {
  const FakeLocationRepository();

  @override
  Future<Coordinates> getCurrentLocation() async =>
      const Coordinates(latitude: 50, longitude: 20);
}

class FakeImagePickerRepository implements ImagePickerRepository {
  const FakeImagePickerRepository();

  @override
  Future<String?> pickFromGallery() async => null;
}

class FakeExternalUrlRepository implements ExternalUrlRepository {
  const FakeExternalUrlRepository();

  @override
  Future<void> open(Uri uri) async {}
}

class FakeThemeRepository implements ThemeRepository {
  const FakeThemeRepository();

  @override
  Future<bool> loadIsDarkTheme() async => false;

  @override
  Future<void> saveIsDarkTheme(bool isDarkTheme) async {}
}
