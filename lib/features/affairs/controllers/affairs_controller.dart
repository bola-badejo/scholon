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
import 'package:isapp/features/auth/models/user.dart';  // This should have BaseUser and UserType
import 'package:isapp/features/affairs/models/affairs_model.dart';
import 'package:isapp/features/school/screens/faculty.dart';

class AffairsController extends GetxController {
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

  // User data
  final Rx<BaseUser?> currentUser = Rx<BaseUser?>(null);
  final RxString schoolId = ''.obs;
  final RxString schoolName = ''.obs; // ADDED THIS LINE
  final RxBool isAdmin = false.obs;
  final RxBool canView = false.obs;

  // Loading states
  final RxBool isLoadingNews = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingPolls = false.obs;
  final RxBool isLoadingAnnouncements = false.obs;
  final RxBool isInitializing = true.obs;

  // Form controllers
  final TextEditingController newsTitleController = TextEditingController();
  final TextEditingController newsContentController = TextEditingController();
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();
  final TextEditingController pollQuestionController = TextEditingController();
  final List<TextEditingController> pollOptionControllers = [];
  final TextEditingController announcementTitleController = TextEditingController();
  final TextEditingController announcementContentController = TextEditingController();

  // Form state
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<String> uploadedImageUrls = <String>[].obs;
  final Rx<DateTime?> selectedEventDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedEventTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> selectedReminderDate = Rx<DateTime?>(null);
  final RxBool requiresRegistration = false.obs;
  final RxInt maxAttendees = 100.obs;
  final RxBool isMultiChoicePoll = false.obs;
  final Rx<DateTime?> pollEndDate = Rx<DateTime?>(null);
  final RxBool isUrgentAnnouncement = false.obs;
  final RxList<String> announcementTargets = <String>[].obs;

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
    
    // Dispose controllers
    newsTitleController.dispose();
    newsContentController.dispose();
    eventTitleController.dispose();
    eventDescriptionController.dispose();
    pollQuestionController.dispose();
    for (var controller in pollOptionControllers) {
      controller.dispose();
    }
    announcementTitleController.dispose();
    announcementContentController.dispose();
    
    super.onClose();
  }

  Future<void> _initialize() async {
    try {
      isInitializing.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        canView.value = false;
        isInitializing.value = false;
        return;
      }

      // Load user data
      await _loadUserData(user.uid);
      
      // Setup realtime listeners if user can view
      if (canView.value && schoolId.value.isNotEmpty) {
        _setupRealtimeListeners();
        await _loadStats();
      }
      
    } catch (e) {
      print('Affairs initialization error: $e');
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      // Try to find user in any of the user collections
      final userTypes = ['student_details', 'teacher_details', 'school_details', 'parent_details'];
      
      for (final collection in userTypes) {
        final doc = await _firestore.collection(collection).doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          data['userType'] = collection.replaceAll('_details', '');
          currentUser.value = createUserFromMap(data);
          
          // Determine user role and access
          await _determineUserAccess(); // Changed to async
          return;
        }
      }
      
      // If user not found in specific collections, try users collection
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        currentUser.value = createUserFromMap(userDoc.data()!);
        await _determineUserAccess(); // Changed to async
      } else {
        canView.value = false;
      }
      
    } catch (e) {
      print('Error loading user data: $e');
      canView.value = false;
    }
  }

  Future<void> _determineUserAccess() async {
    if (currentUser.value == null) {
      canView.value = false;
      isAdmin.value = false;
      return;
    }

    // FIRST: Load the actual school ID
    await _loadSchoolId();
    
    // ALL USERS CAN VIEW IF THEY HAVE A SCHOOL
    canView.value = schoolId.value.isNotEmpty;
    
    // Determine if user is admin
    isAdmin.value = currentUser.value!.userType == UserType.schoolAdmin;
    
    // Also allow teachers to create content if needed
    if (currentUser.value!.userType == UserType.teacher) {
      final profile = await _getSchoolUserProfile();
      if (profile != null && profile.canManageStudents) {
        // Teachers with high authority can also create content
        isAdmin.value = true;
      }
    }
  }

  Future<SchoolUserProfile?> _getSchoolUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || schoolId.value.isEmpty) return null;
    
    final query = await _firestore
        .collection('school_user_profiles')
        .where('userId', isEqualTo: userId)
        .where('schoolId', isEqualTo: schoolId.value)
        .limit(1)
        .get();
        
    if (query.docs.isNotEmpty) {
      return SchoolUserProfile.fromFirestore(query.docs.first.data());
    }
    return null;
  }

  // ADDED THIS METHOD - FIXED VERSION
  Future<void> _loadSchoolId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Try school_user_profiles first (most reliable)
    final profileSnapshot = await _firestore
        .collection('school_user_profiles')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (profileSnapshot.docs.isNotEmpty) {
      final profile = profileSnapshot.docs.first.data();
      schoolId.value = profile['schoolId'] ?? profile['schoolCode'] ?? '';
      schoolName.value = profile['schoolName'] ?? '';
      return;
    }

    // Fallback to user collection
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final user = createUserFromMap(userDoc.data()!);
      
      String? userSchoolName = '';
      
      switch (user.userType) {
        case UserType.student:
          final student = user as StudentUser;
          userSchoolName = student.schoolName ?? '';
          break;
          case UserType.kidling:
          final learner = user as ParentUser;
          userSchoolName = learner.schoolName ?? '';
          break;
        case UserType.teacher:
          final teacher = user as TeacherUser;
          userSchoolName = teacher.schoolName ?? '';
          break;
        case UserType.schoolAdmin:
          final admin = user as SchoolAdminUser;
          userSchoolName = admin.schoolName ?? '';
          schoolId.value = admin.schoolCode ?? admin.uid;
          break;
        case UserType.parent:
          final parent = user as ParentUser;
          userSchoolName = parent.schoolName ?? '';
          break;
      }
      
      if (userSchoolName!.isNotEmpty && schoolId.value.isEmpty) {
        schoolName.value = userSchoolName;
        await _findSchoolIdByName(userSchoolName);
      }
    }
  }

  // ADDED THIS METHOD - FIXED VERSION
  Future<void> _findSchoolIdByName(String name) async {
    if (name.isEmpty) return;
    
    try {
      // Try to find school by name in schools collection
      final schoolQuery = await _firestore
          .collection('schools')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (schoolQuery.docs.isNotEmpty) {
        schoolId.value = schoolQuery.docs.first.id;
        schoolName.value = name;
      } else {
        // Fallback: use school name as ID
        schoolId.value = name;
        schoolName.value = name;
      }
    } catch (e) {
      print('Error finding school by name: $e');
      // Fallback
      schoolId.value = name;
      schoolName.value = name;
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
          .map((doc) => NewsPost.fromFirestore(doc.data()!))
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
          .map((doc) => Event.fromFirestore(doc.data()!))
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
          .map((doc) => Poll.fromFirestore(doc.data()!))
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
          .map((doc) => Announcement.fromFirestore(doc.data()!))
          .toList();
      totalAnnouncements.value = announcements.length;
    });
  }

  Future<int> _getTotalSchoolUsers() async {
    try {
      // Use schoolId instead of schoolName for consistency
      final schoolUsers = await _firestore
          .collection('school_user_profiles')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      return schoolUsers.count ?? 0;
    } catch (e) {
      return 100; // Default fallback
    }
  }

  Future<void> _sendNotificationToAll({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Use schoolId instead of schoolName for querying
      final usersSnapshot = await _firestore
          .collection('school_user_profiles')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      final timestamp = Timestamp.now();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.data()['userId'];
        if (userId != null) {
          final notificationId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

          final notificationRef = _firestore.collection('notifications').doc(notificationId);
          batch.set(notificationRef, {
            'id': notificationId,
            'userId': userId,
            'title': title,
            'body': body,
            'type': type,
            'data': data ?? {},
            'read': false,
            'createdAt': timestamp,
            'schoolId': schoolId.value,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error sending notifications: $e');
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


  Future<int> _getEngagedUsers() async {
  try {
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    final newsEngaged = await _firestore
        .collection('news_views')
        .where('schoolId', isEqualTo: schoolId.value)  // CHANGED
        .where('viewedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .count()
        .get();

    final pollsEngaged = await _firestore
        .collection('poll_votes')
        .where('schoolId', isEqualTo: schoolId.value)  // CHANGED
        .where('votedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .count()
        .get();

    final eventsEngaged = await _firestore
        .collection('event_registrations')
        .where('schoolId', isEqualTo: schoolId.value)  // CHANGED
        .where('registeredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .count()
        .get();

    return (newsEngaged.count ?? 0) + (pollsEngaged.count ?? 0) + (eventsEngaged.count ?? 0);
  } catch (e) {
    return 50;
  }
}

  // Image handling
  Future<void> pickImages() async {
    try {
      final pickedImages = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedImages != null) {
        selectedImages.addAll(pickedImages);
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Error', 'Failed to pick images');
    }
  }

  Future<void> removeImage(int index) async {
    if (index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  Future<List<String>> uploadImages() async {
    uploadedImageUrls.clear();
    
    for (var image in selectedImages) {
      try {
        final fileName = 'news_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
        final ref = _storage.ref().child('news_images/$schoolId/$fileName');
        
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        uploadedImageUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    
    return uploadedImageUrls;
  }

  // News creation - NULL SAFETY FIXED
  Future<String> createNewsPost() async {
    try {
      if (!isAdmin.value) {
        throw 'Only administrators can create news posts';
      }

      if (newsTitleController.text.isEmpty || newsContentController.text.isEmpty) {
        throw 'Please fill in all required fields';
      }

      final imageUrls = await uploadImages();
      
      final newsId = 'news_${DateTime.now().millisecondsSinceEpoch}';
      final newsPost = NewsPost(
        id: newsId,
        title: newsTitleController.text,
        content: newsContentController.text,
        imageUrls: imageUrls,
        authorId: _auth.currentUser!.uid,
        authorName: currentUser.value?.name ?? 'Admin',
        schoolId: schoolId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: 0,
        shares: 0,
        views: 0,
      );

      await _firestore.collection('news_posts').doc(newsId).set(newsPost.toFirestore());
      
      // Clear form
      newsTitleController.clear();
      newsContentController.clear();
      selectedImages.clear();
      uploadedImageUrls.clear();

      // Send notification
      await _sendNotificationToAll(
        title: 'New News Post',
        body: newsPost.title,
        type: 'news',
        data: {'newsId': newsId},
      );

      Get.snackbar('Success', 'News post created successfully');
      return newsId;
    } catch (e) {
      print('Error creating news post: $e');
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  // Event creation - NULL SAFETY FIXED
  Future<String> createEvent() async {
    try {
      if (!isAdmin.value) {
        throw 'Only administrators can create events';
      }

      if (eventTitleController.text.isEmpty || 
          eventDescriptionController.text.isEmpty ||
          selectedEventDate.value == null ||
          selectedEventTime.value == null) {
        throw 'Please fill in all required fields';
      }

      final eventDateTime = DateTime(
        selectedEventDate.value!.year,
        selectedEventDate.value!.month,
        selectedEventDate.value!.day,
        selectedEventTime.value!.hour,
        selectedEventTime.value!.minute,
      );

      final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';
      final event = Event(
        id: eventId,
        title: eventTitleController.text,
        description: eventDescriptionController.text,
        startDate: eventDateTime,
        endDate: eventDateTime.add(Duration(hours: 2)),
        location: 'School Campus',
        organizerId: _auth.currentUser!.uid,
        organizerName: currentUser.value?.name ?? 'Admin',
        schoolId: schoolId.value,
        createdAt: DateTime.now(),
        requiresRegistration: requiresRegistration.value,
        maxAttendees: requiresRegistration.value ? maxAttendees.value : 0,
        registeredCount: 0,
        reminderDate: selectedReminderDate.value,
        category: 'General',
        status: EventStatus.upcoming,
      );

      await _firestore.collection('events').doc(eventId).set(event.toFirestore());
      
      // Clear form
      eventTitleController.clear();
      eventDescriptionController.clear();
      selectedEventDate.value = null;
      selectedEventTime.value = null;
      requiresRegistration.value = false;
      maxAttendees.value = 100;
      selectedReminderDate.value = null;

      // Send notification
      await _sendNotificationToAll(
        title: 'New Event',
        body: event.title,
        type: 'event',
        data: {'eventId': eventId},
      );

      Get.snackbar('Success', 'Event created successfully');
      return eventId;
    } catch (e) {
      print('Error creating event: $e');
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  // Poll creation - NULL SAFETY FIXED
  Future<String> createPoll() async {
    try {
      if (!isAdmin.value) {
        throw 'Only administrators can create polls';
      }

      if (pollQuestionController.text.isEmpty || 
          pollOptionControllers.length < 2 ||
          pollOptionControllers.any((c) => c.text.isEmpty)) {
        throw 'Please fill in question and at least 2 options';
      }

      final options = pollOptionControllers.map((c) => PollOption(
        id: 'option_${pollOptionControllers.indexOf(c)}',
        text: c.text,
        votes: 0,
        voters: [],
      )).toList();

      final pollId = 'poll_${DateTime.now().millisecondsSinceEpoch}';
      final poll = Poll(
        id: pollId,
        question: pollQuestionController.text,
        options: options,
        creatorId: _auth.currentUser!.uid,
        creatorName: currentUser.value?.name ?? 'Admin',
        schoolId: schoolId.value,
        createdAt: DateTime.now(),
        endDate: pollEndDate.value ?? DateTime.now().add(Duration(days: 7)),
        isMultiChoice: isMultiChoicePoll.value,
        totalVotes: 0,
        voterIds: [],
        category: 'General',
        isActive: true,
      );

      await _firestore.collection('polls').doc(pollId).set(poll.toFirestore());
      
      // Clear form
      pollQuestionController.clear();
      pollOptionControllers.clear();
      isMultiChoicePoll.value = false;
      pollEndDate.value = null;

      // Send notification
      await _sendNotificationToAll(
        title: 'New Poll',
        body: poll.question,
        type: 'poll',
        data: {'pollId': pollId},
      );

      Get.snackbar('Success', 'Poll created successfully');
      return pollId;
    } catch (e) {
      print('Error creating poll: $e');
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  // Announcement creation - NULL SAFETY FIXED
  Future<String> createAnnouncement() async {
    try {
      if (!isAdmin.value) {
        throw 'Only administrators can create announcements';
      }

      if (announcementTitleController.text.isEmpty || 
          announcementContentController.text.isEmpty) {
        throw 'Please fill in all required fields';
      }

      final announcementId = 'announcement_${DateTime.now().millisecondsSinceEpoch}';
      final announcement = Announcement(
        id: announcementId,
        title: announcementTitleController.text,
        content: announcementContentController.text,
        authorId: _auth.currentUser!.uid,
        authorName: currentUser.value?.name ?? 'Admin',
        schoolId: schoolId.value,
        createdAt: DateTime.now(),
        isUrgent: isUrgentAnnouncement.value,
        targets: announcementTargets,
        priority: isUrgentAnnouncement.value ? 1 : 3,
        status: AnnouncementStatus.active,
      );

      await _firestore.collection('announcements').doc(announcementId).set(announcement.toFirestore());
      
      // Clear form
      announcementTitleController.clear();
      announcementContentController.clear();
      isUrgentAnnouncement.value = false;
      announcementTargets.clear();

      // Send notification
      await _sendNotificationToTargets(
        title: isUrgentAnnouncement.value ? 'URGENT: ${announcement.title}' : announcement.title,
        body: announcement.content.length > 100 ? '${announcement.content.substring(0, 100)}...' : announcement.content,
        type: 'announcement',
        data: {'announcementId': announcementId},
        targets: announcementTargets,
      );

      Get.snackbar('Success', 'Announcement created successfully');
      return announcementId;
    } catch (e) {
      print('Error creating announcement: $e');
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  // Vote on poll - ALL USERS CAN VOTE
  Future<void> voteOnPoll(String pollId, List<int> optionIndexes) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in to vote');
        return;
      }

      final pollDoc = await _firestore.collection('polls').doc(pollId).get();
      if (!pollDoc.exists) {
        Get.snackbar('Error', 'Poll not found');
        return;
      }

      final poll = Poll.fromFirestore(pollDoc.data()!);
      
      // Check if user already voted
      if (poll.voterIds.contains(userId) && !poll.isMultiChoice) {
        Get.snackbar('Notice', 'You have already voted on this poll');
        return;
      }

      // Update poll
      final batch = _firestore.batch();
      final pollRef = _firestore.collection('polls').doc(pollId);
      
      // Update vote counts for each selected option
      for (var index in optionIndexes) {
        if (index < poll.options.length) {
          final option = poll.options[index];
          final optionData = {
            'votes': FieldValue.increment(1),
            'voters': FieldValue.arrayUnion([userId]),
          };
          
          // Update the option in the poll document
          batch.update(pollRef, {
            'options.$index.votes': FieldValue.increment(1),
            'options.$index.voters': FieldValue.arrayUnion([userId]),
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
        'userName': currentUser.value?.name ?? 'User',
        'userType': currentUser.value?.userType.name ?? 'user',
      });

      await batch.commit();
      
      Get.snackbar('Success', 'Vote recorded successfully');
    } catch (e) {
      print('Error voting on poll: $e');
      Get.snackbar('Error', 'Failed to record vote');
    }
  }

  // Register for event - ALL USERS CAN REGISTER
  Future<void> registerForEvent(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'You must be logged in to register');
        return;
      }

      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        Get.snackbar('Error', 'Event not found');
        return;
      }

      final event = Event.fromFirestore(eventDoc.data()!);
      
      // Check if event requires registration and has capacity
      if (event.requiresRegistration && 
          event.registeredCount >= event.maxAttendees) {
        Get.snackbar('Notice', 'Event is full');
        return;
      }

      // Check if already registered
      final existingRegistration = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        Get.snackbar('Notice', 'Already registered for this event');
        return;
      }

      final registrationId = 'reg_${eventId}_$userId';
      
      await _firestore.collection('event_registrations').doc(registrationId).set({
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

      Get.snackbar('Success', 'Registration successful');
    } catch (e) {
      print('Error registering for event: $e');
      Get.snackbar('Error', 'Registration failed');
    }
  }


Future<void> _sendNotificationToTargets({
  required String title,
  required String body,
  required String type,
  Map<String, dynamic>? data,
  required List<String> targets,
}) async {
  try {
    if (targets.isEmpty) {
      await _sendNotificationToAll(
        title: title,
        body: body,
        type: type,
        data: data,
      );
      return;
    }

    final batch = _firestore.batch();
    final timestamp = Timestamp.now();

    for (var userType in targets) {
      final usersSnapshot = await _firestore
          .collection('school_user_profiles')
          .where('schoolId', isEqualTo: schoolId.value)  // CHANGED THIS
          .where('userType', isEqualTo: userType)
          .where('isActive', isEqualTo: true)
          .get();

      // ... rest of the method stays the same
    }

    await batch.commit();
  } catch (e) {
    print('Error sending targeted notifications: $e');
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
      final notificationId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

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
        'userName': currentUser.value?.name ?? 'User',
        'userType': currentUser.value?.userType.name ?? 'user',
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

  // Form helpers
  void addPollOption() {
    pollOptionControllers.add(TextEditingController());
    update();
  }

  void removePollOption(int index) {
    if (index < pollOptionControllers.length) {
      pollOptionControllers[index].dispose();
      pollOptionControllers.removeAt(index);
      update();
    }
  }

  void clearAllForms() {
    // News
    newsTitleController.clear();
    newsContentController.clear();
    selectedImages.clear();
    uploadedImageUrls.clear();
    
    // Event
    eventTitleController.clear();
    eventDescriptionController.clear();
    selectedEventDate.value = null;
    selectedEventTime.value = null;
    requiresRegistration.value = false;
    maxAttendees.value = 100;
    selectedReminderDate.value = null;
    
    // Poll
    pollQuestionController.clear();
    for (var controller in pollOptionControllers) {
      controller.dispose();
    }
    pollOptionControllers.clear();
    isMultiChoicePoll.value = false;
    pollEndDate.value = null;
    
    // Announcement
    announcementTitleController.clear();
    announcementContentController.clear();
    isUrgentAnnouncement.value = false;
    announcementTargets.clear();
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
          .map((doc) => NewsPost.fromFirestore(doc.data()!))
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
      if (schoolId.value.isEmpty) return;
      
      final snapshot = await _firestore
          .collection('news_posts')
          .where('schoolId', isEqualTo: schoolId.value)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      newsPosts.value = snapshot.docs
          .map((doc) => NewsPost.fromFirestore(doc.data()!))
          .toList();
    } catch (e) {
      print('Error loading news: $e');
    }
  }

  Future<void> _loadEvents() async {
    try {
      if (schoolId.value.isEmpty) return;
      
      final snapshot = await _firestore
          .collection('events')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('endDate')
          .limit(10)
          .get();

      events.value = snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data()!))
          .toList();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> _loadPolls() async {
    try {
      if (schoolId.value.isEmpty) return;
      
      final snapshot = await _firestore
          .collection('polls')
          .where('schoolId', isEqualTo: schoolId.value)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('endDate')
          .limit(10)
          .get();

      polls.value = snapshot.docs
          .map((doc) => Poll.fromFirestore(doc.data()!))
          .toList();
    } catch (e) {
      print('Error loading polls: $e');
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      if (schoolId.value.isEmpty) return;
      
      final snapshot = await _firestore
          .collection('announcements')
          .where('schoolId', isEqualTo: schoolId.value)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      announcements.value = snapshot.docs
          .map((doc) => Announcement.fromFirestore(doc.data()!))
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
          .map((doc) => NewsPost.fromFirestore(doc.data()!))
          .where((post) => 
              post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching news: $e');
      return [];
    }
  }

  // Delete operations - ADMIN ONLY
  Future<void> deleteNewsPost(String newsId) async {
    try {
      if (!isAdmin.value) {
        Get.snackbar('Error', 'Only administrators can delete posts');
        return;
      }

      await _firestore.collection('news_posts').doc(newsId).delete();
      newsPosts.removeWhere((post) => post.id == newsId);
      
      Get.snackbar(
        'Success',
        'News post deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting news post: $e');
      Get.snackbar(
        'Error',
        'Failed to delete news post',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      if (!isAdmin.value) {
        Get.snackbar('Error', 'Only administrators can delete events');
        return;
      }

      await _firestore.collection('events').doc(eventId).delete();
      events.removeWhere((event) => event.id == eventId);
      
      Get.snackbar(
        'Success',
        'Event deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting event: $e');
      Get.snackbar(
        'Error',
        'Failed to delete event',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deletePoll(String pollId) async {
    try {
      if (!isAdmin.value) {
        Get.snackbar('Error', 'Only administrators can delete polls');
        return;
      }

      await _firestore.collection('polls').doc(pollId).delete();
      polls.removeWhere((poll) => poll.id == pollId);
      
      Get.snackbar(
        'Success',
        'Poll deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting poll: $e');
      Get.snackbar(
        'Error',
        'Failed to delete poll',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      if (!isAdmin.value) {
        Get.snackbar('Error', 'Only administrators can delete announcements');
        return;
      }

      await _firestore.collection('announcements').doc(announcementId).delete();
      announcements.removeWhere((announcement) => announcement.id == announcementId);
      
      Get.snackbar(
        'Success',
        'Announcement deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deleting announcement: $e');
      Get.snackbar(
        'Error',
        'Failed to delete announcement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  // Check if user can create content
  bool get canCreateContent => isAdmin.value;
} 