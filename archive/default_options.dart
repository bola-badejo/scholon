// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC4URS-MQzKQlkXBGAXnkgbVx39R5tsILo',
    appId: '1:118311628878:web:73a65e05b0d9f32c97531f',
    messagingSenderId: '118311628878',
    projectId: 'istudyapp-de440',
    authDomain: 'istudyapp-de440.firebaseapp.com',
    storageBucket: 'istudyapp-de440.firebasestorage.app',
    measurementId: 'G-PKSMZ354EP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4URS-MQzKQlkXBGAXnkgbVx39R5tsILo',
    appId: '1:118311628878:android:YOUR_ANDROID_APP_ID_HERE', // You'll need to get this
    messagingSenderId: '118311628878',
    projectId: 'istudyapp-de440',
    storageBucket: 'istudyapp-de440.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4URS-MQzKQlkXBGAXnkgbVx39R5tsILo',
    appId: '1:118311628878:ios:YOUR_IOS_APP_ID_HERE', // You'll need to get this
    messagingSenderId: '118311628878',
    projectId: 'istudyapp-de440',
    storageBucket: 'istudyapp-de440.firebasestorage.app',
    iosBundleId: 'com.example.isapp', // Change this to your bundle ID
  );
}