import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAXOuSGQSGucsYvlD1t89Ka4dHaA9wggRE',
    appId: '1:1012266956991:web:cf3f0b4987be3f03fb2e0a',
    messagingSenderId: '1012266956991',
    projectId: 'jalan-sehat-b1f75',
    storageBucket: 'jalan-sehat-b1f75.firebasestorage.app',
    authDomain: 'jalan-sehat-b1f75.firebaseapp.com',
    measurementId: 'G-KPZEGY6WPW',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyAXOuSGQSGucsYvlD1t89Ka4dHaA9wggRE',
    appId: '1:1012266956991:web:cf3f0b4987be3f03fb2e0a',
    messagingSenderId: '1012266956991',
    projectId: 'jalan-sehat-b1f75',
    storageBucket: 'jalan-sehat-b1f75.firebasestorage.app',
    authDomain: 'jalan-sehat-b1f75.firebaseapp.com',
    measurementId: 'G-KPZEGY6WPW',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXOuSGQSGucsYvlD1t89Ka4dHaA9wggRE',
    appId: '1:1012266956991:web:cf3f0b4987be3f03fb2e0a',
    messagingSenderId: '1012266956991',
    projectId: 'jalan-sehat-b1f75',
    storageBucket: 'jalan-sehat-b1f75.firebasestorage.app',
    authDomain: 'jalan-sehat-b1f75.firebaseapp.com',
    measurementId: 'G-KPZEGY6WPW',
  );
}
