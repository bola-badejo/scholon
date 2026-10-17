import 'package:get/get.dart';
import 'package:isapp/features/notes/controllers/note_controller.dart';
import 'package:isapp/features/notes/data/notes_repo.dart';
import 'package:isapp/features/notes/controllers/editor_controller.dart';
import 'package:isapp/features/notes/services/pdf_service.dart';

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