// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDLwBWUb1vRR-_JhY3QRhzKzejTgaifqBk',
    appId: '1:773014983829:web:20c425f5ec3c53c9c4379c',
    messagingSenderId: '773014983829',
    projectId: 'cart-app-dae7f',
    authDomain: 'cart-app-dae7f.firebaseapp.com',
    storageBucket: 'cart-app-dae7f.appspot.com',
    measurementId: 'G-E7QWY4YFKJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-Ii2Uo7cYozQuOLU-2CnGVt-X2_AFhZM',
    appId: '1:773014983829:android:9c0da5c0cdcfa259c4379c',
    messagingSenderId: '773014983829',
    projectId: 'cart-app-dae7f',
    storageBucket: 'cart-app-dae7f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0X6VKGI57AMoHyU93eKFbUMXh7YEuzA0',
    appId: '1:773014983829:ios:396082517a7c4c05c4379c',
    messagingSenderId: '773014983829',
    projectId: 'cart-app-dae7f',
    storageBucket: 'cart-app-dae7f.appspot.com',
    iosBundleId: 'com.example.totalizerCart',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0X6VKGI57AMoHyU93eKFbUMXh7YEuzA0',
    appId: '1:773014983829:ios:396082517a7c4c05c4379c',
    messagingSenderId: '773014983829',
    projectId: 'cart-app-dae7f',
    storageBucket: 'cart-app-dae7f.appspot.com',
    iosBundleId: 'com.example.totalizerCart',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDLwBWUb1vRR-_JhY3QRhzKzejTgaifqBk',
    appId: '1:773014983829:web:cedaaa6c8b0ed4edc4379c',
    messagingSenderId: '773014983829',
    projectId: 'cart-app-dae7f',
    authDomain: 'cart-app-dae7f.firebaseapp.com',
    storageBucket: 'cart-app-dae7f.appspot.com',
    measurementId: 'G-SFG44T6XSN',
  );
}
