// Manually configured FirebaseOptions for Android only
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  // Android config extracted from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCT9jOpIUxdgK8imr-ucMsOlktZAksx5GY',
    appId: '1:909179088734:android:c4804ec01f4ea4fe93e9cf',
    messagingSenderId: '909179088734',
    projectId: 'virtual-wardrobe-db7a5',
    storageBucket: 'virtual-wardrobe-db7a5.firebasestorage.app',
  );
}