import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Screens/notes/controllers/note_controller.dart';
import 'package:isapp/Screens/notes/model/notes_model.dart';
import 'package:isapp/Screens/notes/repo/notes_repo.dart';
import '../services/pdf_service.dart';

class EditorController extends GetxController {
  final NotesRepository _repository = Get.find();
  final PdfService _pdfService = Get.find();

  final Rx<Note> note = Note.createNew('').obs;
  final RxInt focusedBlockIndex = 0.obs;
  final RxList<TextBlock> blocks = <TextBlock>[].obs;
  final RxBool isSaving = false.obs;

  final List<FocusNode> focusNodes = [];
  final List<TextEditingController> textControllers = [];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Note) {
      note.value = args;
      _initializeBlocks(args.blocks);
    } else if (args is String) {
      _loadNote(args);
    }
    _setupAutoSave();
  }

  void _initializeBlocks(List<TextBlock> initialBlocks) {
    blocks.assignAll(initialBlocks);

    // Clear existing controllers and focus nodes
    for (var controller in textControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    textControllers.clear();
    focusNodes.clear();

    // Initialize controllers and focus nodes
    for (var i = 0; i < blocks.length; i++) {
      final controller = TextEditingController(text: blocks[i].text);
      final focusNode = FocusNode();

      controller.addListener(() {
        blocks[i] = blocks[i].copyWith(text: controller.text);
        if (blocks[i].type == BlockType.title) {
          note.update((val) {
            val?.title = controller.text;
          });
        }
      });

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          focusedBlockIndex.value = i;
        }
      });

      textControllers.add(controller);
      focusNodes.add(focusNode);
    }
  }

  Future<void> _loadNote(String noteId) async {
    final loadedNote = await _repository.getNote(noteId);
    if (loadedNote != null) {
      note.value = loadedNote;
      _initializeBlocks(loadedNote.blocks);
    }
  }

  void _setupAutoSave() {
    debounce(blocks, (_) => _saveNote(), time: const Duration(seconds: 2));
  }

  Future<void> _saveNote() async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final updatedNote = note.value.copyWith(
        blocks: blocks.toList(),
        updatedAt: DateTime.now(),
      );

      if (updatedNote.id == null) {
        final id = await _repository.createNote(updatedNote);
        note.value = updatedNote.copyWith(id: id);
      } else {
        await _repository.updateNote(updatedNote);
        note.value = updatedNote;

        // Update the note in the list if we're coming from there
        final notesController = Get.find<NotesController>();
        notesController.updateNoteInList(updatedNote);
      }
    } catch (e) {
      print('Error saving note: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void changeBlockType(int index, BlockType newType) {
    if (index >= blocks.length) return;

    final oldBlock = blocks[index];
    blocks[index] = oldBlock.copyWith(type: newType);
    _saveNote();
  }

  void changeFontFamily(int index, FontFamily newFont) {
    if (index >= blocks.length) return;

    final oldBlock = blocks[index];
    blocks[index] = oldBlock.copyWith(fontFamily: newFont);
    _saveNote();
  }

  void addBlock(int index, BlockType type) {
    final newBlock = TextBlock(type: type, text: '');
    blocks.insert(index + 1, newBlock);

    final controller = TextEditingController();
    final focusNode = FocusNode();

    controller.addListener(() {
      blocks[index + 1] = newBlock.copyWith(text: controller.text);
    });

    textControllers.insert(index + 1, controller);
    focusNodes.insert(index + 1, focusNode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[index + 1].requestFocus();
    });

    _saveNote();
  }

  void removeBlock(int index) {
    if (blocks.length > 1) {
      textControllers[index].dispose();
      focusNodes[index].dispose();
      blocks.removeAt(index);
      textControllers.removeAt(index);
      focusNodes.removeAt(index);

      // Adjust focused index if needed
      if (focusedBlockIndex.value >= blocks.length) {
        focusedBlockIndex.value = blocks.length - 1;
      }

      _saveNote();
    }
  }

  void moveBlockUp(int index) {
    if (index > 0) {
      final block = blocks.removeAt(index);
      blocks.insert(index - 1, block);

      final controller = textControllers.removeAt(index);
      textControllers.insert(index - 1, controller);

      final focusNode = focusNodes.removeAt(index);
      focusNodes.insert(index - 1, focusNode);

      focusedBlockIndex.value = index - 1;
      _saveNote();
    }
  }

  void moveBlockDown(int index) {
    if (index < blocks.length - 1) {
      final block = blocks.removeAt(index);
      blocks.insert(index + 1, block);

      final controller = textControllers.removeAt(index);
      textControllers.insert(index + 1, controller);

      final focusNode = focusNodes.removeAt(index);
      focusNodes.insert(index + 1, focusNode);

      focusedBlockIndex.value = index + 1;
      _saveNote();
    }
  }

  Future<void> exportToPdf() async {
    try {
      final noteToExport = note.value.copyWith(blocks: blocks.toList());
      await _pdfService.generatePdf(noteToExport);
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  @override
  void onClose() {
    for (var controller in textControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    _saveNote();
    super.onClose();
  }
}
