// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHqSc8lp_4rgK3MoPpViQlFrGQVBOMXv0',
    appId: '1:285934909074:web:33bd03c6c09a85bfc5184b',
    messagingSenderId: '285934909074',
    projectId: 'touring-game',
    authDomain: 'touring-game.firebaseapp.com',
    storageBucket: 'touring-game.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeZSiM6YEJck2txCA_NKZEEsRIkKSt3uo',
    appId: '1:285934909074:android:a9c2dd3d021c94fec5184b',
    messagingSenderId: '285934909074',
    projectId: 'touring-game',
    storageBucket: 'touring-game.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLzlXZhnpldI54WpS_2er7Nwsj8lMBquI',
    appId: '1:285934909074:ios:8198acbc6839313bc5184b',
    messagingSenderId: '285934909074',
    projectId: 'touring-game',
    storageBucket: 'touring-game.appspot.com',
    iosBundleId: 'com.example.touringGame',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBLzlXZhnpldI54WpS_2er7Nwsj8lMBquI',
    appId: '1:285934909074:ios:e45073e753bdf161c5184b',
    messagingSenderId: '285934909074',
    projectId: 'touring-game',
    storageBucket: 'touring-game.appspot.com',
    iosBundleId: 'com.example.touringGame.RunnerTests',
  );
}
