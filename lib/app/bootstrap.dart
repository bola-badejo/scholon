import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:isapp/app/app.dart';
import 'package:isapp/app/di/service_locator.dart';
import 'package:isapp/app/firebase_error_app.dart';
import 'package:isapp/core/firebase/firebase_config.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/kidling/controllers/home_controller.dart';
import 'package:isapp/features/kidling/data/data.dart';
import 'package:isapp/features/notifications/services/notifications_service.dart';

/// Everything that must happen before the first frame, in one place.
Future<void> bootstrap() async {
  try {
    await Firebase.initializeApp(options: FirebaseConfig.options);
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(const FirebaseErrorApp());
    return;
  }
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  ServiceLocator.registerCore();
  ServiceLocator.registerSchool();
  ServiceLocator.registerKidling();
  await ServiceLocator.registerStorage();

  runApp(const MyApp());

  // Non-blocking work after the first frame.
  unawaited(_seedKidlingContent());
  unawaited(NotificationService().initialize());
}

/// Seeds Kidling activities only when the collection is empty
/// (override: false never wipes live data).
Future<void> _seedKidlingContent() async {
  try {
    await SeedActivities.seedAllActivities(override: false)
        .timeout(const Duration(seconds: 30));
  } catch (e) {
    debugPrint('Kidling seeding skipped: $e');
  }
}
