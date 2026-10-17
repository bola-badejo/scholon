import 'package:get/get.dart';
import 'package:isapp/features/notes/models/notes_model.dart';
import 'package:isapp/features/notes/data/notes_repo.dart';

class NotesController extends GetxController {
  final NotesRepository _repository = Get.find();
  final RxList<Note> notes = <Note>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }
  
  void loadNotes() {
    _repository.streamNotes().listen((fetchedNotes) {
      notes.assignAll(fetchedNotes);
    });
  }

  void updateNoteInList(Note updatedNote) {
  final index = notes.indexWhere((note) => note.id == updatedNote.id);
  if (index != -1) {
    notes[index] = updatedNote;
  }
}
  
  Future<void> createNewNote() async {
    try {
      isLoading.value = true;
      final newNote = Note.createNew(_repository.userId);
      final noteId = await _repository.createNote(newNote);
      final noteWithId = newNote.copyWith(id: noteId);
      Get.toNamed('/editor', arguments: noteWithId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create note: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteNote(String noteId) async {
    try {
      await _repository.deleteNote(noteId);
      Get.snackbar('Success', 'Note deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete note');
    }
  }
}