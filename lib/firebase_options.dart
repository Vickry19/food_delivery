// File: lib/firebase_options.dart
// Generated manually based on your Firebase config.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak mendukung platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDRzoAmPCaZcKecJ0p_A3hJzce2keIxL7Y",
    authDomain: "food-order-app-f330c.firebaseapp.com",
    projectId: "food-order-app-f330c",
    storageBucket: "food-order-app-f330c.firebasestorage.app",
    messagingSenderId: "203570544489",
    appId: "1:203570544489:web:92ab716085dda814bcc7f8",
    measurementId: "G-NQLTR9NXN2",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDRzoAmPCaZcKecJ0p_A3hJzce2keIxL7Y",
    appId: "1:203570544489:web:92ab716085dda814bcc7f8",
    messagingSenderId: "203570544489",
    projectId: "food-order-app-f330c",
    storageBucket: "food-order-app-f330c.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDRzoAmPCaZcKecJ0p_A3hJzce2keIxL7Y",
    appId: "1:203570544489:web:92ab716085dda814bcc7f8",
    messagingSenderId: "203570544489",
    projectId: "food-order-app-f330c",
    storageBucket: "food-order-app-f330c.firebasestorage.app",
    iosBundleId: "com.example.flutterApplication1",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyDRzoAmPCaZcKecJ0p_A3hJzce2keIxL7Y",
    appId: "1:203570544489:web:92ab716085dda814bcc7f8",
    messagingSenderId: "203570544489",
    projectId: "food-order-app-f330c",
    storageBucket: "food-order-app-f330c.firebasestorage.app",
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyDRzoAmPCaZcKecJ0p_A3hJzce2keIxL7Y",
    appId: "1:203570544489:web:92ab716085dda814bcc7f8",
    messagingSenderId: "203570544489",
    projectId: "food-order-app-f330c",
    storageBucket: "food-order-app-f330c.firebasestorage.app",
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: "AIzaSyDRzoAmPCaZcKecJ0p_A3hJzce2keIxL7Y",
    appId: "1:203570544489:web:92ab716085dda814bcc7f8",
    messagingSenderId: "203570544489",
    projectId: "food-order-app-f330c",
    storageBucket: "food-order-app-f330c.firebasestorage.app",
  );
}
