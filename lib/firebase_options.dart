import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBd0z0Q_BiJhaJdJLKcVJrGzWDdLfoYkmQ',
    appId: '1:776370519623:android:e6e2fb16aed63776d57b62',
    messagingSenderId: '776370519623',
    projectId: 'orgfarmv3',
    storageBucket: 'orgfarmv3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3yIN0g0lVBZdrjZ4sM3dyoozk0xn0ZAI',
    appId: '1:776370519623:ios:d3f2e9b8c6a0c8add57b62', // You'll need the correct iOS appId
    messagingSenderId: '776370519623',
    projectId: 'orgfarmv3',
    storageBucket: 'orgfarmv3.firebasestorage.app',
    iosBundleId: 'com.orgfarm.customer',
  );
}