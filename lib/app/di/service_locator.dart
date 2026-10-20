import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'package:isapp/core/services/connectivity_service.dart';
import 'package:isapp/features/affairs/bindings/affairs_binding.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/features/affairs/controllers/affairs_public_controller.dart';
import 'package:isapp/features/auth/controllers/auth_controller.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/controllers/home_controller.dart';
import 'package:isapp/features/kidling/controllers/progress_controller.dart';
import 'package:isapp/features/notifications/controllers/notifications_controller.dart';
import 'package:isapp/features/parents/controllers/parent_controller.dart';
import 'package:isapp/features/school/screens/faculty.dart';
import 'package:isapp/features/teachly/data/repo/course_repo.dart';
import 'package:isapp/features/teachly/data/repo/teacher_repo.dart';
import 'package:isapp/features/teachly/screens/teacher_page.dart';
import 'package:isapp/features/teachly/services/storage_services.dart';

/// Registers every long-lived dependency. Controllers that are only needed
/// by one product (Kidling) are lazy so they cost nothing for other users.
class ServiceLocator {
  ServiceLocator._();

  static void registerCore() {
    Get.put(ConnectivityService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(AuthenticationController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
  }

  static void registerSchool() {
    Get.put(FacultyController(), permanent: true);
    Get.put(AffairsBinding(), permanent: true);
    Get.put(ConnectController(), permanent: true);
    Get.put(AffairsController(), permanent: true);
    Get.put(AffairsPublicController(), permanent: true);
    Get.put(BoardController(), permanent: true);
    Get.put(ParentController(), permanent: true);
  }

  /// Kidling controllers load Firestore data in onInit, so they are created on
  /// first use instead of at startup.
  static void registerKidling() {
    Get.lazyPut<AudioAssistantService>(() => AudioAssistantService(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ActivityController>(() => ActivityController(), fenix: true);
    Get.lazyPut<ProgressController>(() => ProgressController(), fenix: true);
  }

  static Future<void> registerStorage() async {
    try {
      await Get.putAsync<StorageService>(() async {
        final service = StorageService();
        await service.onInit().timeout(const Duration(seconds: 5));
        return service;
      }, permanent: true);
    } catch (e) {
      debugPrint('StorageService init failed: $e');
    }
    Get.put(CourseRepository(), permanent: true);
    Get.put(TeacherRepository(), permanent: true);
  }
}
