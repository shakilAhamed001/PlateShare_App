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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAla9E19eMD8XQn2Nu7G2a92lF5YzDIBTs',
    appId: '1:443760337202:android:deafec15c22fd6a3cc372b',
    messagingSenderId: '443760337202',
    projectId: 'plateshare-9ce71',
    storageBucket: 'plateshare-9ce71.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAla9E19eMD8XQn2Nu7G2a92lF5YzDIBTs',
    appId:
        '1:443760337202:ios:deafec15c22fd6a3cc372b', // Assuming same as android for now
    messagingSenderId: '443760337202',
    projectId: 'plateshare-9ce71',
    storageBucket: 'plateshare-9ce71.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAla9E19eMD8XQn2Nu7G2a92lF5YzDIBTs',
    appId: '1:443760337202:web:deafec15c22fd6a3cc372b', // Assuming
    messagingSenderId: '443760337202',
    projectId: 'plateshare-9ce71',
    authDomain: 'plateshare-9ce71.firebaseapp.com',
    storageBucket: 'plateshare-9ce71.firebasestorage.app',
  );
}
