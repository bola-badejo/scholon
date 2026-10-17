import 'package:get/get.dart';
import 'package:isapp/features/teachly/data/repo/course_repo.dart';
import 'package:isapp/features/teachly/data/repo/teacher_repo.dart';
import 'package:isapp/features/teachly/controllers/learning_center_controller.dart';
import 'package:isapp/features/teachly/services/storage_services.dart';

class LearningCenterBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize services first
    Get.lazyPut(() => StorageService(), fenix: true);
    
    // Initialize repositories
    Get.lazyPut(() => CourseRepository(), fenix: true);
    Get.lazyPut(() => TeacherRepository(), fenix: true);
    
    // Initialize controller
    Get.lazyPut(() => LearningCenterController(), fenix: true);
  }
}