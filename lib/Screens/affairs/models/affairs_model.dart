import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// News Post Model
class NewsPost {
  final String id;
  final String title;
  final String content;
  final List<String> imageUrls;
  final String authorId;
  final String authorName;
  final String schoolId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int shares;
  final int views;
  final List<String> tags;

  NewsPost({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    required this.authorId,
    required this.authorName,
    required this.schoolId,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.shares = 0,
    this.views = 0,
    this.tags = const [],
  });

  factory NewsPost.fromFirestore(Map<String, dynamic> data) {
    return NewsPost(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      authorId: data['authorId']?.toString() ?? '',
      authorName: data['authorName']?.toString() ?? '',
      schoolId: data['schoolId']?.toString() ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      likes: data['likes'] ?? 0,
      shares: data['shares'] ?? 0,
      views: data['views'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'authorId': authorId,
      'authorName': authorName,
      'schoolId': schoolId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'shares': shares,
      'views': views,
      'tags': tags,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  bool get hasImages => imageUrls.isNotEmpty;
}

// Event Model
enum EventStatus {
  upcoming('Upcoming', Colors.blue),
  ongoing('Ongoing', Colors.green),
  completed('Completed', Colors.grey),
  cancelled('Cancelled', Colors.red);

  final String displayName;
  final Color color;

  const EventStatus(this.displayName, this.color);
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String organizerId;
  final String organizerName;
  final String schoolId;
  final DateTime createdAt;
  final bool requiresRegistration;
  final int maxAttendees;
  final int registeredCount;
  final DateTime? reminderDate;
  final String category;
  final EventStatus status;
  final List<String> attendees;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.organizerId,
    required this.organizerName,
    required this.schoolId,
    required this.createdAt,
    this.requiresRegistration = false,
    this.maxAttendees = 0,
    this.registeredCount = 0,
    this.reminderDate,
    this.category = 'General',
    this.status = EventStatus.upcoming,
    this.attendees = const [],
  });

  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(Duration(hours: 2)),
      location: data['location']?.toString() ?? 'School Campus',
      organizerId: data['organizerId']?.toString() ?? '',
      organizerName: data['organizerName']?.toString() ?? '',
      schoolId: data['schoolId']?.toString() ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      requiresRegistration: data['requiresRegistration'] ?? false,
      maxAttendees: data['maxAttendees'] ?? 0,
      registeredCount: data['registeredCount'] ?? 0,
      reminderDate: data['reminderDate'] != null 
          ? (data['reminderDate'] as Timestamp).toDate()
          : null,
      category: data['category']?.toString() ?? 'General',
      status: EventStatus.values.firstWhere(
        (e) => e.name == (data['status']?.toString() ?? 'upcoming'),
        orElse: () => EventStatus.upcoming,
      ),
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'location': location,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'schoolId': schoolId,
      'createdAt': Timestamp.fromDate(createdAt),
      'requiresRegistration': requiresRegistration,
      'maxAttendees': maxAttendees,
      'registeredCount': registeredCount,
      'reminderDate': reminderDate != null ? Timestamp.fromDate(reminderDate!) : null,
      'category': category,
      'status': status.name,
      'attendees': attendees,
      'updatedAt': Timestamp.now(),
    };
  }

  bool get isFull => requiresRegistration && registeredCount >= maxAttendees;
  bool get canRegister => requiresRegistration && !isFull;
  double get registrationProgress => maxAttendees > 0 ? registeredCount / maxAttendees : 0;
  
  String get formattedDate {
    if (startDate.year == endDate.year && 
        startDate.month == endDate.month && 
        startDate.day == endDate.day) {
      return '${_formatDate(startDate)} • ${_formatTime(startDate)} - ${_formatTime(endDate)}';
    }
    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// Poll Option Model
class PollOption {
  final String id;
  final String text;
  final int votes;
  final List<String> voters;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.voters = const [],
  });

  factory PollOption.fromFirestore(Map<String, dynamic> data) {
    return PollOption(
      id: data['id']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      votes: data['votes'] ?? 0,
      voters: List<String>.from(data['voters'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'voters': voters,
    };
  }
}

// Poll Model
class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final String creatorId;
  final String creatorName;
  final String schoolId;
  final DateTime createdAt;
  final DateTime endDate;
  final bool isMultiChoice;
  final int totalVotes;
  final List<String> voterIds;
  final String category;
  final bool isActive;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.creatorId,
    required this.creatorName,
    required this.schoolId,
    required this.createdAt,
    required this.endDate,
    this.isMultiChoice = false,
    this.totalVotes = 0,
    this.voterIds = const [],
    this.category = 'General',
    this.isActive = true,
  });

  factory Poll.fromFirestore(Map<String, dynamic> data) {
    final optionsData = List<Map<String, dynamic>>.from(data['options'] ?? []);
    return Poll(
      id: data['id']?.toString() ?? '',
      question: data['question']?.toString() ?? '',
      options: optionsData.map((opt) => PollOption.fromFirestore(opt)).toList(),
      creatorId: data['creatorId']?.toString() ?? '',
      creatorName: data['creatorName']?.toString() ?? '',
      schoolId: data['schoolId']?.toString() ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(Duration(days: 7)),
      isMultiChoice: data['isMultiChoice'] ?? false,
      totalVotes: data['totalVotes'] ?? 0,
      voterIds: List<String>.from(data['voterIds'] ?? []),
      category: data['category']?.toString() ?? 'General',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'question': question,
      'options': options.map((opt) => opt.toFirestore()).toList(),
      'creatorId': creatorId,
      'creatorName': creatorName,
      'schoolId': schoolId,
      'createdAt': Timestamp.fromDate(createdAt),
      'endDate': Timestamp.fromDate(endDate),
      'isMultiChoice': isMultiChoice,
      'totalVotes': totalVotes,
      'voterIds': voterIds,
      'category': category,
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
    };
  }

  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get hasVotes => totalVotes > 0;
  
  int get maxVotes {
    if (options.isEmpty) return 0;
    return options.map((opt) => opt.votes).reduce((a, b) => a > b ? a : b);
  }

  double getOptionPercentage(PollOption option) {
    if (totalVotes == 0) return 0;
    return option.votes / totalVotes;
  }
}

// Announcement Status
enum AnnouncementStatus {
  active('Active', Colors.green),
  expired('Expired', Colors.grey),
  draft('Draft', Colors.blue);

  final String displayName;
  final Color color;

  const AnnouncementStatus(this.displayName, this.color);
}

// Announcement Model
class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String schoolId;
  final DateTime createdAt;
  final bool isUrgent;
  final List<String> targets;
  final int priority;
  final AnnouncementStatus status;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.schoolId,
    required this.createdAt,
    this.isUrgent = false,
    this.targets = const [],
    this.priority = 3,
    this.status = AnnouncementStatus.active,
  });

  factory Announcement.fromFirestore(Map<String, dynamic> data) {
    return Announcement(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      authorId: data['authorId']?.toString() ?? '',
      authorName: data['authorName']?.toString() ?? '',
      schoolId: data['schoolId']?.toString() ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isUrgent: data['isUrgent'] ?? false,
      targets: List<String>.from(data['targets'] ?? []),
      priority: data['priority'] ?? 3,
      status: AnnouncementStatus.values.firstWhere(
        (e) => e.name == (data['status']?.toString() ?? 'active'),
        orElse: () => AnnouncementStatus.active,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'schoolId': schoolId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isUrgent': isUrgent,
      'targets': targets,
      'priority': priority,
      'status': status.name,
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedTargets {
    if (targets.isEmpty) return 'All Users';
    return targets.join(', ');
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }
    return 'Just now';
  }
}

// Event Registration Model
class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userType;
  final DateTime registeredAt;
  final String status;
  final String schoolId;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userType,
    required this.registeredAt,
    this.status = 'registered',
    required this.schoolId,
  });

  factory EventRegistration.fromFirestore(Map<String, dynamic> data) {
    return EventRegistration(
      id: data['id']?.toString() ?? '',
      eventId: data['eventId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      userType: data['userType']?.toString() ?? '',
      registeredAt: data['registeredAt'] != null 
          ? (data['registeredAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status']?.toString() ?? 'registered',
      schoolId: data['schoolId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'status': status,
      'schoolId': schoolId,
    };
  }
}