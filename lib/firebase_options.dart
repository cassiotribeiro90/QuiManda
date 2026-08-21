import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Para Android (já que você tem o google-services.json)
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNRZyW1TEAo9DP_Z3T6MBbN5Q9bIfGeEQ',
    appId: '1:477697812477:android:086b0ca5fb981a80df9b94',
    messagingSenderId: '477697812477',
    projectId: 'quimanda-5e5c9',
    authDomain: 'quimanda-5e5c9.firebaseapp.com',
    storageBucket: 'quimanda-5e5c9.firebasestorage.app',
    measurementId: null,
  );

  // Adicione se quiser testar na WEB depois
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNRZyW1TEAo9DP_Z3T6MBbN5Q9bIfGeEQ',
    appId: '1:477697812477:web:???', // Pega no Firebase Console > Web App
    messagingSenderId: '477697812477',
    projectId: 'quimanda-5e5c9',
    authDomain: 'quimanda-5e5c9.firebaseapp.com',
    storageBucket: 'quimanda-5e5c9.firebasestorage.app',
  );
}