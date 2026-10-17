import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:isapp/features/notes/models/notes_model.dart';

class NotesRepository extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Change from private to public getter
  String get userId => FirebaseAuth.instance.currentUser!.uid;
  
  CollectionReference get _notesCollection =>
      _firestore.collection('users').doc(userId).collection('notes');
  
  Stream<List<Note>> streamNotes() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
  
  Future<Note?> getNote(String noteId) async {
    try {
      final doc = await _notesCollection.doc(noteId).get();
      if (doc.exists) {
        return Note.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting note: $e');
      return null;
    }
  }
  
  Future<String> createNote(Note note) async {
    try {
      final docRef = await _notesCollection.add(note.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }
  
  Future<void> updateNote(Note note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _notesCollection
          .doc(note.id)
          .update(updatedNote.toMap());
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }
  
  Future<void> deleteNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }
}