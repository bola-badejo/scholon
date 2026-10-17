import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/models/student_progress.dart';

/// Firestore layout:
///   users/{uid}/study_guide/progress           StudentProgress
///   users/{uid}/study_mastery/{topicKey}       MasteryRecord
///   users/{uid}/study_sessions/{autoId}        finished plan items
class StudyGuideRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  DocumentReference<Map<String, dynamic>> get _user => _db.collection('users').doc(uid);

  String _safe(String key) => key.replaceAll('/', '_');

  Future<StudentProgress> loadProgress() async {
    final d = await _user.collection('study_guide').doc('progress').get();
    return d.exists ? StudentProgress.fromMap(d.data()!) : const StudentProgress();
  }

  Future<void> saveProgress(StudentProgress p) => _user.collection('study_guide').doc('progress').set(p.toMap(), SetOptions(merge: true));

  Future<Map<String, MasteryRecord>> loadMastery() async {
    final snap = await _user.collection('study_mastery').get();
    return {for (final d in snap.docs) d.data()['topicKey'] as String: MasteryRecord.fromMap(d.data())};
  }

  Future<void> saveMastery(MasteryRecord r) => _user.collection('study_mastery').doc(_safe(r.topicKey)).set(r.toMap());

  Future<void> addSession({
    required String itemId,
    required String topicKey,
    required String subject,
    required int minutes,
    required int quality,
    required int xp,
  }) =>
      _user.collection('study_sessions').add({
        'itemId': itemId,
        'topicKey': topicKey,
        'subject': subject,
        'minutes': minutes,
        'quality': quality,
        'xp': xp,
        'at': Timestamp.now(),
      });

  /// Sessions since [from] (client-side filtering avoids a composite index).
  Future<List<Map<String, dynamic>>> sessionsSince(DateTime from) async {
    final snap = await _user.collection('study_sessions').where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(from)).get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
