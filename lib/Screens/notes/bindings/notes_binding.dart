import 'package:get/get.dart';
import 'package:isapp/Screens/notes/controllers/note_controller.dart';
import 'package:isapp/Screens/notes/repo/notes_repo.dart';
import '../controllers/editor_controller.dart';
import '../services/pdf_service.dart';

class NotesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotesRepository());
    Get.lazyPut(() => PdfService());
    Get.lazyPut(() => NotesController());
  }
}

class EditorBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditorController());
  }
}