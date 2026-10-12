import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isapp/Models/user.dart';  // Use BaseUser instead of ConnectUser
import 'package:isapp/Screens/affairs/models/affairs_model.dart';

class AffairsPublicController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Reactive lists
  final RxList<NewsPost> newsPosts = <NewsPost>[].obs;
  final RxList<Event> events = <Event>[].obs;
  final RxList<Poll> polls = <Poll>[].obs;
  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxList<Map<String, dynamic>> userPolls = <Map<String, dynamic>>[].obs;

  // User data - using BaseUser from your user model
  final Rx<BaseUser?> currentUser = Rx<BaseUser?>(null);
  final RxString schoolId = ''.obs;

  // Loading states
  final RxBool isLoadingNews = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingPolls = false.obs;
  final RxBool isLoadingAnnouncements = false.obs;

  // Stats
  final RxInt totalNews = 0.obs;
  final RxInt totalEvents = 0.obs;
  final RxInt totalPolls = 0.obs;
  final RxInt totalAnnouncements = 0.obs;
  final RxInt activeRegistrations = 0.obs;
  final RxDouble engagementRate = 0.0.obs;

  // Stream subscriptions
  StreamSubscription? _newsSubscription;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _pollsSubscription;
  StreamSubscription? _announcementsSubscription;

  final RxBool isLoadingUser = false.obs;
  final RxBool isInitializing = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _newsSubscription?.cancel();
    _eventsSubscription?.cancel();
    _pollsSubscription?.cancel();
    _announcementsSubscription?.cancel();

    super.onClose();
  }

  String get userType {
    return currentUser.value?.userType.name ?? 'guest';
  }

  String get schoolName {
    if (currentUser.value == null) return 'School';
    
    // Check user type and get school name accordingly
    if (currentUser.value is StudentUser) {
      return (currentUser.value as StudentUser).schoolName ?? 'School';
    } else if (currentUser.value is TeacherUser) {
      return (currentUser.value as TeacherUser).schoolName ?? 'School';
    } else if (currentUser.value is SchoolAdminUser) {
      return (currentUser.value as SchoolAdminUser).schoolName ?? 'School';
    } else if (currentUser.value is ParentUser) {
      return (currentUser.value as ParentUser).schoolName ?? 'School';
    }
    return 'School';
  }

  String get userName {
    return currentUser.value?.name ?? 'User';
  }

  Future<void> _initialize() async {
    try {
      isInitializing.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        isInitializing.value = false;
        return;
      }

      // Load user data using BaseUser factory
      await getCurrentUser();

      // Setup realtime listeners if we have a schoolId
      if (schoolId.value.isNotEmpty) {
        _setupRealtimeListeners();
        await _loadStats();
      }
    } catch (e) {
      print('Affairs initialization error: $e');
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> setCurrentSchool(
    Map<String, dynamic> schoolData,
    BaseUser user,
  ) async {
    try {
      currentUser.value = user;
      schoolId.value = schoolData['id'] ?? schoolData['schoolId'] ?? '';
      await refreshAll();
    } catch (e) {
      print('Error setting school: $e');
      Get.snackbar('Error', 'Failed to load school data');
    }
  }

  Future<void> initializeForPublicView(
    String schoolId,
    BaseUser user,
  ) async {
    try {
      this.schoolId.value = schoolId;
      currentUser.value = user;
      await refreshAll();
    } catch (e) {
      print('Error initializing public view: $e');
      throw e;
    }
  }

  Future<dynamic> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      // Use the factory function from user.dart
      currentUser.value = createUserFromMap(userDoc.data()!);

      return;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  void _setupRealtimeListeners() {
    if (schoolId.value.isEmpty) return;

    // News listener
    _newsSubscription = _firestore
        .collection('news_posts')
        .where('schoolId', isEqualTo: schoolId.value)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          newsPosts.value = snapshot.docs
              .map((doc) => NewsPost.fromFirestore(doc.data()))
              .toList();
          totalNews.value = newsPosts.length;
        });

    // Events listener
    _eventsSubscription = _firestore
        .collection('events')
        .where('schoolId', isEqualTo: schoolId.value)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate')
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          events.value = snapshot.docs
              .map((doc) => Event.fromFirestore(doc.data()))
              .toList();
          totalEvents.value = events.length;
        });

    // Polls listener
    _pollsSubscription = _firestore
        .collection('polls')
        .where('schoolId', isEqualTo: schoolId.value)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate')
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          polls.value = snapshot.docs
              .map((doc) => Poll.fromFirestore(doc.data()))
              .toList();
          totalPolls.value = polls.length;
        });

    // Announcements listener
    _announcementsSubscription = _firestore
        .collection('announcements')
        .where('schoolId', isEqualTo: schoolId.value)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          announcements.value = snapshot.docs
              .map((doc) => Announcement.fromFirestore(doc.data()))
              .toList();
          totalAnnouncements.value = announcements.length;
        });
  }

  Future<void> loadPublicSchoolData(String schoolId) async {
    try {
      this.schoolId.value = schoolId;
      await refreshAll();
    } catch (e) {
      print('Error loading public school data: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      if (schoolId.value.isEmpty) return;

      // Load active registrations
      final registrations = await _firestore
          .collection('event_registrations')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('status', isEqualTo: 'registered')
          .get();
      activeRegistrations.value = registrations.docs.length;

      // Calculate engagement rate
      final totalUsers = await _getTotalSchoolUsers();
      final engagedUsers = await _getEngagedUsers();
      if (totalUsers > 0) {
        engagementRate.value = (engagedUsers / totalUsers * 100);
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<int> _getTotalSchoolUsers() async {
    try {
      final students = await _firestore
          .collection('users')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('userType', isEqualTo: 'student')
          .count()
          .get();

      final parents = await _firestore
          .collection('users')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('userType', isEqualTo: 'parent')
          .count()
          .get();

      final teachers = await _firestore
          .collection('users')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('userType', isEqualTo: 'teacher')
          .count()
          .get();

      return (students.count ?? 0) +
          (parents.count ?? 0) +
          (teachers.count ?? 0);
    } catch (e) {
      return 100;
    }
  }

  Future<int> _getEngagedUsers() async {
    try {
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

      final newsEngaged = await _firestore
          .collection('news_views')
          .where('schoolId', isEqualTo: schoolId.value)
          .where(
            'viewedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo),
          )
          .count()
          .get();

      final pollsEngaged = await _firestore
          .collection('poll_votes')
          .where('schoolId', isEqualTo: schoolId.value)
          .where(
            'votedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo),
          )
          .count()
          .get();

      final eventsEngaged = await _firestore
          .collection('event_registrations')
          .where('schoolId', isEqualTo: schoolId.value)
          .where(
            'registeredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo),
          )
          .count()
          .get();

      return (newsEngaged.count ?? 0) +
          (pollsEngaged.count ?? 0) +
          (eventsEngaged.count ?? 0);
    } catch (e) {
      return 50;
    }
  }

  // Vote on poll
  Future<void> voteOnPoll(String pollId, List<int> optionIndexes) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final pollDoc = await _firestore.collection('polls').doc(pollId).get();
      if (!pollDoc.exists) return;

      final poll = Poll.fromFirestore(pollDoc.data()!);

      // Check if user already voted
      if (poll.voterIds.contains(userId) && !poll.isMultiChoice) {
        throw 'You have already voted on this poll';
      }

      // Update poll
      final batch = _firestore.batch();
      final pollRef = _firestore.collection('polls').doc(pollId);

      // Update vote counts
      for (var index in optionIndexes) {
        if (index < poll.options.length) {
          final option = poll.options[index];
          final optionVotesRef = _firestore
              .collection('polls')
              .doc(pollId)
              .collection('options')
              .doc(option.id);

          batch.update(optionVotesRef, {
            'votes': FieldValue.increment(1),
            'voters': FieldValue.arrayUnion([userId]),
          });
        }
      }

      // Update poll totals
      batch.update(pollRef, {
        'totalVotes': FieldValue.increment(1),
        'voterIds': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.now(),
      });

      // Record individual vote
      final voteId = 'vote_${pollId}_$userId';
      final voteRef = _firestore.collection('poll_votes').doc(voteId);
      batch.set(voteRef, {
        'id': voteId,
        'pollId': pollId,
        'userId': userId,
        'optionIndexes': optionIndexes,
        'votedAt': Timestamp.now(),
        'schoolId': schoolId.value,
      });

      await batch.commit();
    } catch (e) {
      print('Error voting on poll: $e');
      rethrow;
    }
  }

  // Register for event
  Future<void> registerForEvent(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return;

      final event = Event.fromFirestore(eventDoc.data()!);

      // Check if event requires registration and has capacity
      if (event.requiresRegistration &&
          event.registeredCount >= event.maxAttendees) {
        throw 'Event is full';
      }

      // Check if already registered
      final existingRegistration = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw 'Already registered for this event';
      }

      final registrationId = 'reg_${eventId}_$userId';

      await _firestore
          .collection('event_registrations')
          .doc(registrationId)
          .set({
            'id': registrationId,
            'eventId': eventId,
            'userId': userId,
            'userName': currentUser.value?.name ?? 'User',
            'userType': currentUser.value?.userType.name ?? 'user',
            'registeredAt': Timestamp.now(),
            'status': 'registered',
            'schoolId': schoolId.value,
          });

      // Update event registration count
      await _firestore.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });

      // Send confirmation
      await _createNotification(
        userId: userId,
        title: 'Event Registration Confirmed',
        body: 'You are registered for ${event.title}',
        type: 'event_registration',
        data: {'eventId': eventId},
      );
    } catch (e) {
      print('Error registering for event: $e');
      rethrow;
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'id': notificationId,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
        'read': false,
        'createdAt': Timestamp.now(),
        'schoolId': schoolId.value,
      });
    } catch (e) {
      print('Create notification error: $e');
    }
  }

  // Analytics
  Future<void> recordNewsView(String newsId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final viewId = 'view_${newsId}_$userId';

      await _firestore.collection('news_views').doc(viewId).set({
        'id': viewId,
        'newsId': newsId,
        'userId': userId,
        'viewedAt': Timestamp.now(),
        'schoolId': schoolId.value,
      });

      await _firestore.collection('news_posts').doc(newsId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error recording news view: $e');
    }
  }

  // Data fetching with pagination
  Future<void> loadMoreNews() async {
    if (isLoadingNews.value || newsPosts.isEmpty) return;

    isLoadingNews.value = true;
    try {
      final lastPost = newsPosts.last;
      final snapshot = await _firestore
          .collection('news_posts')
          .where('schoolId', isEqualTo: schoolId.value)
          .orderBy('createdAt', descending: true)
          .startAfter([lastPost.createdAt])
          .limit(10)
          .get();

      final newPosts = snapshot.docs
          .map((doc) => NewsPost.fromFirestore(doc.data()))
          .toList();

      newsPosts.addAll(newPosts);
    } catch (e) {
      print('Error loading more news: $e');
    } finally {
      isLoadingNews.value = false;
    }
  }

  Future<void> refreshAll() async {
    isLoadingNews.value = true;
    isLoadingEvents.value = true;
    isLoadingPolls.value = true;
    isLoadingAnnouncements.value = true;

    try {
      await Future.wait([
        _loadNews(),
        _loadEvents(),
        _loadPolls(),
        _loadAnnouncements(),
        _loadStats(),
      ]);
    } catch (e) {
      print('Error refreshing: $e');
    } finally {
      isLoadingNews.value = false;
      isLoadingEvents.value = false;
      isLoadingPolls.value = false;
      isLoadingAnnouncements.value = false;
    }
  }

  Future<void> _loadNews() async {
    try {
      final snapshot = await _firestore
          .collection('news_posts')
          .where('schoolId', isEqualTo: schoolId.value)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      newsPosts.value = snapshot.docs
          .map((doc) => NewsPost.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading news: $e');
    }
  }

  Future<void> _loadEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('endDate')
          .limit(10)
          .get();

      events.value = snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> _loadPolls() async {
    try {
      final snapshot = await _firestore
          .collection('polls')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('endDate')
          .limit(10)
          .get();

      polls.value = snapshot.docs
          .map((doc) => Poll.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading polls: $e');
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final snapshot = await _firestore
          .collection('announcements')
          .where('schoolId', isEqualTo: schoolId.value)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      announcements.value = snapshot.docs
          .map((doc) => Announcement.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading announcements: $e');
    }
  }

  // Search functionality
  Future<List<NewsPost>> searchNews(String query) async {
    try {
      final snapshot = await _firestore
          .collection('news_posts')
          .where('schoolId', isEqualTo: schoolId.value)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NewsPost.fromFirestore(doc.data()))
          .where(
            (post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching news: $e');
      return [];
    }
  }

  // Statistics getters
  String getFormattedEngagementRate() {
    return '${engagementRate.value.toStringAsFixed(1)}%';
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String getFormattedDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }
}