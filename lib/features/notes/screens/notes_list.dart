import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isapp/features/notes/controllers/note_controller.dart';
import 'package:isapp/features/notes/models/notes_model.dart';

class NotesListView extends GetView<NotesController> {
  const NotesListView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rich Notes'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.notes.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Text(
                  'No notes yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap + to create your first note',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return _buildNoteCard(note);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.createNewNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Get.toNamed('/editor', arguments: note),
        title: Text(
          note.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              note.previewText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Updated ${DateFormat.yMMMd().add_jm().format(note.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showNoteOptions(note),
        ),
      ),
    );
  }
  
  void _showNoteOptions(Note note) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Note'),
              onTap: () {
                Get.back();
                _confirmDelete(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Get.back();
                // Implement duplicate
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Get.back();
                // Implement share
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDelete(Note note) {
    Get.defaultDialog(
      title: 'Delete Note',
      middleText: 'Are you sure you want to delete "${note.title}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteNote(note.id!);
        Get.back();
      },
    );
  }
}