// // web/web_plugin_registrant.dart
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth_web/firebase_auth_web.dart';
// import 'package:cloud_firestore_web/cloud_firestore_web.dart';
// import 'package:firebase_storage_web/firebase_storage_web.dart';
// import 'package:shared_preferences_web/shared_preferences_web.dart';
// import 'package:image_picker_web/image_picker_web.dart';
// import 'package:url_launcher_web/url_launcher_web.dart';
// import 'package:webview_flutter_web/webview_flutter_web.dart';

// // Conditional imports for packages that might not have web support
// void registerPlugins() {
//   // Register Firebase plugins
//   FirebaseFirestoreWeb.registerWith(Registrar);
//   FirebaseAuthWeb.registerWith(Registrar);
//   FirebaseStorageWeb.registerWith(Registrar);
  
//   // Register other essential plugins
//   SharedPreferencesWeb.registerWith(Registrar);
//   ImagePickerWeb.registerWith(Registrar);
//   GoogleFontsWeb.registerWith(Registrar);
//   UrlLauncherPlugin.registerWith(Registrar);
//   WebViewPlugin.registerWith(Registrar);
  
//   // Initialize Firebase
//   Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: 'AIzaSyC4URS-MQzKQlkXBGAXnkgbVx39R5tsILo',
//       appId: '1:118311628878:web:73a65e05b0d9f32c97531f',
//       messagingSenderId: '118311628878',
//       projectId: 'istudyapp-de440',
//       authDomain: 'istudyapp-de440.firebaseapp.com',
//       storageBucket: 'istudyapp-de440.firebasestorage.app',
//       measurementId: 'G-PKSMZ354EP',
//     ),
//   );
// }