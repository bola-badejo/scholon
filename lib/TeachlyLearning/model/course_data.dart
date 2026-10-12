import 'package:flutter/material.dart';

enum CourseDifficulty { beginner, intermediate, advanced }
enum CourseStatus { draft, published, archived }

class Instructor {
  final String name;
  final String bio;
  final String image;
  final double rating;
  final int coursesTaught;
  final List<String> specializations;

  const Instructor({
    required this.name,
    required this.bio,
    required this.image,
    required this.rating,
    required this.coursesTaught,
    required this.specializations,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      coursesTaught: json['coursesTaught'] ?? 0,
      specializations: List<String>.from(json['specialization'] ?? json['specializations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'image': image,
      'rating': rating,
      'coursesTaught': coursesTaught,
      'specialization': specializations,
    };
  }
}

class CourseDuration {
  final int totalHours;
  final int weeks;
  final String weeklyCommitment;

  const CourseDuration({
    required this.totalHours,
    required this.weeks,
    required this.weeklyCommitment,
  });

  factory CourseDuration.fromJson(Map<String, dynamic> json) {
    return CourseDuration(
      totalHours: json['totalHours'] ?? 0,
      weeks: json['weeks'] ?? 0,
      weeklyCommitment: json['weeklyCommitment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHours': totalHours,
      'weeks': weeks,
      'weeklyCommitment': weeklyCommitment,
    };
  }
}

class Certification {
  final bool available;
  final String type;
  final String issuer;
  final bool verified;
  final String? accreditation;

  const Certification({
    required this.available,
    required this.type,
    required this.issuer,
    required this.verified,
    this.accreditation,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      available: json['available'] ?? false,
      type: json['type'] ?? '',
      issuer: json['issuer'] ?? '',
      verified: json['verified'] ?? false,
      accreditation: json['accreditation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'type': type,
      'issuer': issuer,
      'verified': verified,
      if (accreditation != null) 'accreditation': accreditation,
    };
  }
}

class Course {
  final String id;
  final String code;
  final String title;
  final String subtitle;
  final String description;
  final String longDescription;
  final String image;
  final String banner;
  final Instructor instructor;
  final String category;
  final String? subCategory;
  final double price;
  final String currency;
  final double? discountPrice;
  final double rating;
  final int totalRatings;
  final int enrollmentCount;
  final CourseDifficulty difficulty;
  final CourseDuration duration;
  final Certification certification;
  final List<String> prerequisites;
  final List<String> learningOutcomes;
  final List<String> targetAudience;
  final String language;
  final List<String> subtitles;
  final List<String> features;
  final DateTime lastUpdated;
  final CourseStatus status;
  final List<String> tags;
  final Map<String, dynamic>? platformFeatures;
  final int chaptersCount;
  final int assignmentsCount;
  final int quizzesCount;

  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.longDescription,
    required this.image,
    required this.banner,
    required this.instructor,
    required this.category,
    this.subCategory,
    required this.price,
    required this.currency,
    this.discountPrice,
    required this.rating,
    required this.totalRatings,
    required this.enrollmentCount,
    required this.difficulty,
    required this.duration,
    required this.certification,
    required this.prerequisites,
    required this.learningOutcomes,
    required this.targetAudience,
    required this.language,
    required this.subtitles,
    required this.features,
    required this.lastUpdated,
    required this.status,
    required this.tags,
    this.platformFeatures,
    required this.chaptersCount,
    required this.assignmentsCount,
    required this.quizzesCount,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? UniqueKey().toString(),
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      longDescription: json['longDescription'] ?? '',
      image: json['image'] ?? '',
      banner: json['banner'] ?? json['image'] ?? '',
      instructor: Instructor.fromJson(json['instructor'] ?? {}),
      category: json['category'] ?? '',
      subCategory: json['subCategory'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'NGN',
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] ?? 0,
      enrollmentCount: json['enrollmentCount'] ?? 0,
      difficulty: _parseDifficulty(json['difficulty']),
      duration: CourseDuration.fromJson(json['duration'] ?? {}),
      certification: Certification.fromJson(json['certification'] ?? {}),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      learningOutcomes: List<String>.from(json['learningOutcomes'] ?? []),
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
      language: json['language'] ?? 'English',
      subtitles: List<String>.from(json['subtitles'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      status: _parseStatus(json['status']),
      tags: List<String>.from(json['tags'] ?? []),
      platformFeatures: json['platformFeatures'] != null 
          ? Map<String, dynamic>.from(json['platformFeatures'])
          : null,
      chaptersCount: json['chaptersCount'] ?? 12,
      assignmentsCount: json['assignmentsCount'] ?? 12,
      quizzesCount: json['quizzesCount'] ?? 6,
    );
  }

  static CourseDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'intermediate':
        return CourseDifficulty.intermediate;
      case 'advanced':
        return CourseDifficulty.advanced;
      default:
        return CourseDifficulty.beginner;
    }
  }

  static CourseStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return CourseStatus.published;
      case 'archived':
        return CourseStatus.archived;
      default:
        return CourseStatus.draft;
    }
  }

  // Helper getters
  String get formattedPrice {
    if (price == 0) return 'Free';
    final symbol = currency == 'NGN' ? '₦' : '\$';
    final amount = discountPrice ?? price;
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  String get originalPrice {
    if (price == 0 || discountPrice == null) return '';
    final symbol = currency == 'NGN' ? '₦' : '\$';
    return '$symbol${price.toStringAsFixed(0)}';
  }

  double get discountPercentage {
    if (discountPrice == null || price == 0) return 0;
    return ((price - discountPrice!) / price) * 100;
  }

  String get durationText {
    if (duration.weeks > 0) {
      return '${duration.weeks} week${duration.weeks > 1 ? 's' : ''}';
    }
    return '${duration.totalHours} hour${duration.totalHours > 1 ? 's' : ''}';
  }

  String get difficultyText {
    switch (difficulty) {
      case CourseDifficulty.beginner:
        return 'Beginner';
      case CourseDifficulty.intermediate:
        return 'Intermediate';
      case CourseDifficulty.advanced:
        return 'Advanced';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case CourseDifficulty.beginner:
        return Colors.green;
      case CourseDifficulty.intermediate:
        return Colors.orange;
      case CourseDifficulty.advanced:
        return Colors.red;
    }
  }

  bool get hasDiscount => discountPrice != null;
  bool get isFree => price == 0;
  bool get isFeatured => rating >= 4.5 && enrollmentCount >= 1000;
  bool get isPopular => enrollmentCount >= 500;
  bool get isNew => DateTime.now().difference(lastUpdated).inDays < 30;
  bool get isPublished => status == CourseStatus.published;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'longDescription': longDescription,
      'image': image,
      'banner': banner,
      'instructor': instructor.toJson(),
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'currency': currency,
      'discountPrice': discountPrice,
      'rating': rating,
      'totalRatings': totalRatings,
      'enrollmentCount': enrollmentCount,
      'difficulty': difficulty.name,
      'duration': duration.toJson(),
      'certification': certification.toJson(),
      'prerequisites': prerequisites,
      'learningOutcomes': learningOutcomes,
      'targetAudience': targetAudience,
      'language': language,
      'subtitles': subtitles,
      'features': features,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status.name,
      'tags': tags,
      'platformFeatures': platformFeatures,
      'chaptersCount': chaptersCount,
      'assignmentsCount': assignmentsCount,
      'quizzesCount': quizzesCount,
    };
  }
}