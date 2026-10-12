import 'package:cloud_firestore/cloud_firestore.dart';

// ========== ENUMS ==========
enum UserType {
  student,
  teacher,
  schoolAdmin,
  parent,
  kidling
}
enum SubscriptionPlan { 
  trial, 
  free, 
  basic, 
  premium, 
  enterprise,
  // Platform-specific plans
  studentMonthly, studentAnnual,
  teacherMonthly, teacherAnnual,
  schoolBasic, schoolAdvanced, schoolEnterprise,
  parentFree, parentPremium,
  // Kidling-specific plans
  kidlingFree, kidlingPremium, kidlingFamily
}
enum PaymentStatus { pending, completed, failed, cancelled, refunded }
enum UserStatus { active, inactive, suspended, deleted }
enum Platform { istudyapp, teachly, automatedSchool, parentsPortal, kidling }

// ========== PLATFORM-SPECIFIC PLAN ENUMS ==========

// Student-specific plans
enum StudentPlan { trial, basic, premium, family }

// Teacher-specific plans
enum TeacherPlan { trial, basic, pro, school }

// School-specific plans
enum SchoolPlan { trial, basic, advanced, enterprise }

// Parent-specific plans
enum ParentPlan { free, premium }

// Kidling-specific plans
enum KidlingPlan { free, premium, family }

// ========== BASE SUBSCRIPTION CLASS ==========

abstract class Subscription {
  final String id;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime expiryDate;
  final double amount;
  final PaymentStatus paymentStatus;
  final String transactionId;
  final DateTime? lastRenewalDate;
  final bool autoRenew;

  Subscription({
    required this.id,
    required this.plan,
    required this.startDate,
    required this.expiryDate,
    required this.amount,
    required this.paymentStatus,
    required this.transactionId,
    this.lastRenewalDate,
    this.autoRenew = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan': plan.name,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'amount': amount,
      'paymentStatus': paymentStatus.name,
      'transactionId': transactionId,
      'lastRenewalDate': lastRenewalDate != null
          ? Timestamp.fromDate(lastRenewalDate!)
          : null,
      'autoRenew': autoRenew,
    };
  }

  bool get isActive => paymentStatus == PaymentStatus.completed;
  bool get hasExpired => DateTime.now().isAfter(expiryDate);
  
  int get daysRemaining {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;
  bool get isExpired => daysRemaining <= 0;

  Subscription renew({String? newTransactionId});

  String get planDescription {
    switch (plan) {
      case SubscriptionPlan.trial:
        return '30-day Free Trial';
      case SubscriptionPlan.free:
        return 'Free Plan';
      case SubscriptionPlan.basic:
        return 'Basic Plan';
      case SubscriptionPlan.premium:
        return 'Premium Plan';
      case SubscriptionPlan.enterprise:
        return 'Enterprise Plan';
      case SubscriptionPlan.studentMonthly:
        return 'Student Monthly';
      case SubscriptionPlan.studentAnnual:
        return 'Student Annual';
      case SubscriptionPlan.teacherMonthly:
        return 'Teacher Monthly';
      case SubscriptionPlan.teacherAnnual:
        return 'Teacher Annual';
      case SubscriptionPlan.schoolBasic:
        return 'School Basic';
      case SubscriptionPlan.schoolAdvanced:
        return 'School Advanced';
      case SubscriptionPlan.schoolEnterprise:
        return 'School Enterprise';
      case SubscriptionPlan.parentFree:
        return 'Parent Free';
      case SubscriptionPlan.parentPremium:
        return 'Parent Premium';
      case SubscriptionPlan.kidlingFree:
        return 'Kidling Free';
      case SubscriptionPlan.kidlingPremium:
        return 'Kidling Premium';
      case SubscriptionPlan.kidlingFamily:
        return 'Kidling Family';
    }
  }

  // Helper method to convert platform-specific plan to SubscriptionPlan
  static SubscriptionPlan convertStudentPlan(StudentPlan plan) {
    switch (plan) {
      case StudentPlan.trial:
        return SubscriptionPlan.trial;
      case StudentPlan.basic:
        return SubscriptionPlan.basic;
      case StudentPlan.premium:
        return SubscriptionPlan.premium;
      case StudentPlan.family:
        return SubscriptionPlan.enterprise;
    }
  }

  static SubscriptionPlan convertTeacherPlan(TeacherPlan plan) {
    switch (plan) {
      case TeacherPlan.trial:
        return SubscriptionPlan.trial;
      case TeacherPlan.basic:
        return SubscriptionPlan.basic;
      case TeacherPlan.pro:
        return SubscriptionPlan.premium;
      case TeacherPlan.school:
        return SubscriptionPlan.enterprise;
    }
  }

  static SubscriptionPlan convertSchoolPlan(SchoolPlan plan) {
    switch (plan) {
      case SchoolPlan.trial:
        return SubscriptionPlan.trial;
      case SchoolPlan.basic:
        return SubscriptionPlan.schoolBasic;
      case SchoolPlan.advanced:
        return SubscriptionPlan.schoolAdvanced;
      case SchoolPlan.enterprise:
        return SubscriptionPlan.schoolEnterprise;
    }
  }

  static SubscriptionPlan convertParentPlan(ParentPlan plan) {
    switch (plan) {
      case ParentPlan.free:
        return SubscriptionPlan.parentFree;
      case ParentPlan.premium:
        return SubscriptionPlan.parentPremium;
    }
  }

  static SubscriptionPlan convertKidlingPlan(KidlingPlan plan) {
    switch (plan) {
      case KidlingPlan.free:
        return SubscriptionPlan.kidlingFree;
      case KidlingPlan.premium:
        return SubscriptionPlan.kidlingPremium;
      case KidlingPlan.family:
        return SubscriptionPlan.kidlingFamily;
    }
  }
}

// ========== STUDENT SUBSCRIPTION ==========

class StudentSubscription extends Subscription {
  final StudentPlan studentPlan;
  final List<String> accessibleCourses;
  final bool includesQuizzes;
  final bool includesProgressTracking;
  final int maxDevices;
  final bool parentalControls;

  static const Map<StudentPlan, double> studentPrices = {
    StudentPlan.trial: 0.0,
    StudentPlan.basic: 500.0, // Monthly
    StudentPlan.premium: 1200.0, // Monthly
    StudentPlan.family: 3000.0, // Monthly (up to 3 students)
  };

  static const Map<StudentPlan, int> studentDurations = {
    StudentPlan.trial: 30,
    StudentPlan.basic: 30,
    StudentPlan.premium: 30,
    StudentPlan.family: 30,
  };

  StudentSubscription({
    required String id,
    required this.studentPlan,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amount,
    required PaymentStatus paymentStatus,
    required String transactionId,
    DateTime? lastRenewalDate,
    bool autoRenew = false,
    this.accessibleCourses = const [],
    this.includesQuizzes = true,
    this.includesProgressTracking = true,
    this.maxDevices = 2,
    this.parentalControls = false,
  }) : super(
    id: id,
    plan: Subscription.convertStudentPlan(studentPlan),
    startDate: startDate,
    expiryDate: expiryDate,
    amount: amount,
    paymentStatus: paymentStatus,
    transactionId: transactionId,
    lastRenewalDate: lastRenewalDate,
    autoRenew: autoRenew,
  );

  factory StudentSubscription.create({
    required StudentPlan plan, 
    String? transactionId,
    DateTime? customStartDate,
  }) {
    final now = customStartDate ?? DateTime.now();
    final duration = studentDurations[plan] ?? 0;
    final expiryDate = now.add(Duration(days: duration));

    return StudentSubscription(
      id: 'student_sub_${DateTime.now().millisecondsSinceEpoch}',
      studentPlan: plan,
      startDate: now,
      expiryDate: expiryDate,
      amount: studentPrices[plan] ?? 0.0,
      paymentStatus: plan == StudentPlan.trial
          ? PaymentStatus.completed
          : PaymentStatus.pending,
      transactionId: transactionId ?? 'student_txn_${DateTime.now().millisecondsSinceEpoch}',
      autoRenew: plan != StudentPlan.trial,
      includesQuizzes: plan != StudentPlan.basic,
      includesProgressTracking: plan != StudentPlan.basic,
      maxDevices: plan == StudentPlan.premium ? 5 : (plan == StudentPlan.family ? 10 : 2),
      parentalControls: plan == StudentPlan.premium || plan == StudentPlan.family,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    base.addAll({
      'studentPlan': studentPlan.name,
      'accessibleCourses': accessibleCourses,
      'includesQuizzes': includesQuizzes,
      'includesProgressTracking': includesProgressTracking,
      'maxDevices': maxDevices,
      'parentalControls': parentalControls,
    });
    return base;
  }

  factory StudentSubscription.fromMap(Map<String, dynamic> map) {
    return StudentSubscription(
      id: map['id'],
      studentPlan: StudentPlan.values.firstWhere(
        (e) => e.name == (map['studentPlan'] ?? 'trial'),
        orElse: () => StudentPlan.trial,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transactionId'],
      lastRenewalDate: map['lastRenewalDate'] != null
          ? (map['lastRenewalDate'] as Timestamp).toDate()
          : null,
      autoRenew: map['autoRenew'] ?? false,
      accessibleCourses: List<String>.from(map['accessibleCourses'] ?? []),
      includesQuizzes: map['includesQuizzes'] ?? true,
      includesProgressTracking: map['includesProgressTracking'] ?? true,
      maxDevices: map['maxDevices'] ?? 2,
      parentalControls: map['parentalControls'] ?? false,
    );
  }

  @override
  StudentSubscription renew({String? newTransactionId}) {
    final newExpiryDate = expiryDate.add(Duration(days: studentDurations[studentPlan] ?? 30));

    return StudentSubscription(
      id: 'student_renew_${DateTime.now().millisecondsSinceEpoch}',
      studentPlan: studentPlan,
      startDate: startDate,
      expiryDate: newExpiryDate,
      amount: amount,
      paymentStatus: paymentStatus,
      transactionId: newTransactionId ?? 'student_renew_txn_${DateTime.now().millisecondsSinceEpoch}',
      lastRenewalDate: DateTime.now(),
      autoRenew: autoRenew,
      accessibleCourses: accessibleCourses,
      includesQuizzes: includesQuizzes,
      includesProgressTracking: includesProgressTracking,
      maxDevices: maxDevices,
      parentalControls: parentalControls,
    );
  }

  bool get includesAllCourses => studentPlan == StudentPlan.premium || studentPlan == StudentPlan.family;
  String get studentPlanDescription => _getStudentPlanDescription(studentPlan);

  static String _getStudentPlanDescription(StudentPlan plan) {
    switch (plan) {
      case StudentPlan.trial:
        return '30-day Free Trial';
      case StudentPlan.basic:
        return 'Student Basic (₦500/month)';
      case StudentPlan.premium:
        return 'Student Premium (₦1,200/month)';
      case StudentPlan.family:
        return 'Family Plan (₦3,000/month)';
    }
  }
}

// ========== TEACHER SUBSCRIPTION ==========

class TeacherSubscription extends Subscription {
  final TeacherPlan teacherPlan;
  final int maxStudents;
  final bool includesAnalytics;
  final bool includesResourceSharing;
  final bool includesCommunityAccess;
  final int storageGB;

  static const Map<TeacherPlan, double> teacherPrices = {
    TeacherPlan.trial: 0.0,
    TeacherPlan.basic: 1500.0, // Monthly
    TeacherPlan.pro: 3500.0, // Monthly
    TeacherPlan.school: 10000.0, // Monthly (school-wide)
  };

  TeacherSubscription({
    required String id,
    required this.teacherPlan,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amount,
    required PaymentStatus paymentStatus,
    required String transactionId,
    DateTime? lastRenewalDate,
    bool autoRenew = false,
    this.maxStudents = 50,
    this.includesAnalytics = false,
    this.includesResourceSharing = false,
    this.includesCommunityAccess = false,
    this.storageGB = 5,
  }) : super(
    id: id,
    plan: Subscription.convertTeacherPlan(teacherPlan),
    startDate: startDate,
    expiryDate: expiryDate,
    amount: amount,
    paymentStatus: paymentStatus,
    transactionId: transactionId,
    lastRenewalDate: lastRenewalDate,
    autoRenew: autoRenew,
  );

  factory TeacherSubscription.create({
    required TeacherPlan plan, 
    String? transactionId,
    DateTime? customStartDate,
  }) {
    final now = customStartDate ?? DateTime.now();
    final expiryDate = now.add(const Duration(days: 30));

    return TeacherSubscription(
      id: 'teacher_sub_${DateTime.now().millisecondsSinceEpoch}',
      teacherPlan: plan,
      startDate: now,
      expiryDate: expiryDate,
      amount: teacherPrices[plan] ?? 0.0,
      paymentStatus: plan == TeacherPlan.trial
          ? PaymentStatus.completed
          : PaymentStatus.pending,
      transactionId: transactionId ?? 'teacher_txn_${DateTime.now().millisecondsSinceEpoch}',
      autoRenew: plan != TeacherPlan.trial,
      maxStudents: plan == TeacherPlan.basic ? 100 : 
                   (plan == TeacherPlan.pro ? 500 : 2000),
      includesAnalytics: plan != TeacherPlan.basic,
      includesResourceSharing: plan != TeacherPlan.basic,
      includesCommunityAccess: plan != TeacherPlan.basic,
      storageGB: plan == TeacherPlan.basic ? 10 : 
                 (plan == TeacherPlan.pro ? 50 : 200),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    base.addAll({
      'teacherPlan': teacherPlan.name,
      'maxStudents': maxStudents,
      'includesAnalytics': includesAnalytics,
      'includesResourceSharing': includesResourceSharing,
      'includesCommunityAccess': includesCommunityAccess,
      'storageGB': storageGB,
    });
    return base;
  }

  factory TeacherSubscription.fromMap(Map<String, dynamic> map) {
    return TeacherSubscription(
      id: map['id'],
      teacherPlan: TeacherPlan.values.firstWhere(
        (e) => e.name == (map['teacherPlan'] ?? 'trial'),
        orElse: () => TeacherPlan.trial,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transactionId'],
      lastRenewalDate: map['lastRenewalDate'] != null
          ? (map['lastRenewalDate'] as Timestamp).toDate()
          : null,
      autoRenew: map['autoRenew'] ?? false,
      maxStudents: map['maxStudents'] ?? 50,
      includesAnalytics: map['includesAnalytics'] ?? false,
      includesResourceSharing: map['includesResourceSharing'] ?? false,
      includesCommunityAccess: map['includesCommunityAccess'] ?? false,
      storageGB: map['storageGB'] ?? 5,
    );
  }

  @override
  TeacherSubscription renew({String? newTransactionId}) {
    final newExpiryDate = expiryDate.add(const Duration(days: 30));

    return TeacherSubscription(
      id: 'teacher_renew_${DateTime.now().millisecondsSinceEpoch}',
      teacherPlan: teacherPlan,
      startDate: startDate,
      expiryDate: newExpiryDate,
      amount: amount,
      paymentStatus: paymentStatus,
      transactionId: newTransactionId ?? 'teacher_renew_txn_${DateTime.now().millisecondsSinceEpoch}',
      lastRenewalDate: DateTime.now(),
      autoRenew: autoRenew,
      maxStudents: maxStudents,
      includesAnalytics: includesAnalytics,
      includesResourceSharing: includesResourceSharing,
      includesCommunityAccess: includesCommunityAccess,
      storageGB: storageGB,
    );
  }

  bool get canCreateUnlimitedResources => teacherPlan == TeacherPlan.pro || teacherPlan == TeacherPlan.school;
  String get teacherPlanDescription => _getTeacherPlanDescription(teacherPlan);

  static String _getTeacherPlanDescription(TeacherPlan plan) {
    switch (plan) {
      case TeacherPlan.trial:
        return '30-day Free Trial';
      case TeacherPlan.basic:
        return 'Teacher Basic (₦1,500/month)';
      case TeacherPlan.pro:
        return 'Teacher Pro (₦3,500/month)';
      case TeacherPlan.school:
        return 'School License (₦10,000/month)';
    }
  }
}

// ========== SCHOOL SUBSCRIPTION ==========

class SchoolSubscription extends Subscription {
  final SchoolPlan schoolPlan;
  final int maxStudents;
  final int maxTeachers;
  final bool includesAnalytics;
  final bool includesParentPortal;
  final bool includesFinanceModule;
  final bool includesAttendanceSystem;
  final int supportHours;

  static const Map<SchoolPlan, double> schoolPrices = {
    SchoolPlan.trial: 0.0,
    SchoolPlan.basic: 25000.0, // Annual
    SchoolPlan.advanced: 50000.0, // Annual
    SchoolPlan.enterprise: 100000.0, // Annual
  };

  SchoolSubscription({
    required String id,
    required this.schoolPlan,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amount,
    required PaymentStatus paymentStatus,
    required String transactionId,
    DateTime? lastRenewalDate,
    bool autoRenew = false,
    this.maxStudents = 500,
    this.maxTeachers = 30,
    this.includesAnalytics = false,
    this.includesParentPortal = false,
    this.includesFinanceModule = false,
    this.includesAttendanceSystem = false,
    this.supportHours = 8,
  }) : super(
    id: id,
    plan: Subscription.convertSchoolPlan(schoolPlan),
    startDate: startDate,
    expiryDate: expiryDate,
    amount: amount,
    paymentStatus: paymentStatus,
    transactionId: transactionId,
    lastRenewalDate: lastRenewalDate,
    autoRenew: autoRenew,
  );

  factory SchoolSubscription.create({
    required SchoolPlan plan, 
    String? transactionId,
    DateTime? customStartDate,
  }) {
    final now = customStartDate ?? DateTime.now();
    final expiryDate = now.add(const Duration(days: 365)); // Annual subscriptions

    return SchoolSubscription(
      id: 'school_sub_${DateTime.now().millisecondsSinceEpoch}',
      schoolPlan: plan,
      startDate: now,
      expiryDate: expiryDate,
      amount: schoolPrices[plan] ?? 0.0,
      paymentStatus: plan == SchoolPlan.trial
          ? PaymentStatus.completed
          : PaymentStatus.pending,
      transactionId: transactionId ?? 'school_txn_${DateTime.now().millisecondsSinceEpoch}',
      autoRenew: plan != SchoolPlan.trial,
      maxStudents: plan == SchoolPlan.basic ? 1000 : 
                   (plan == SchoolPlan.advanced ? 5000 : 10000),
      maxTeachers: plan == SchoolPlan.basic ? 50 : 
                   (plan == SchoolPlan.advanced ? 200 : 500),
      includesAnalytics: plan != SchoolPlan.basic,
      includesParentPortal: plan != SchoolPlan.basic,
      includesFinanceModule: plan == SchoolPlan.advanced || plan == SchoolPlan.enterprise,
      includesAttendanceSystem: plan != SchoolPlan.basic,
      supportHours: plan == SchoolPlan.basic ? 40 : 
                    (plan == SchoolPlan.advanced ? 80 : 160),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    base.addAll({
      'schoolPlan': schoolPlan.name,
      'maxStudents': maxStudents,
      'maxTeachers': maxTeachers,
      'includesAnalytics': includesAnalytics,
      'includesParentPortal': includesParentPortal,
      'includesFinanceModule': includesFinanceModule,
      'includesAttendanceSystem': includesAttendanceSystem,
      'supportHours': supportHours,
    });
    return base;
  }

  factory SchoolSubscription.fromMap(Map<String, dynamic> map) {
    return SchoolSubscription(
      id: map['id'],
      schoolPlan: SchoolPlan.values.firstWhere(
        (e) => e.name == (map['schoolPlan'] ?? 'trial'),
        orElse: () => SchoolPlan.trial,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transactionId'],
      lastRenewalDate: map['lastRenewalDate'] != null
          ? (map['lastRenewalDate'] as Timestamp).toDate()
          : null,
      autoRenew: map['autoRenew'] ?? false,
      maxStudents: map['maxStudents'] ?? 500,
      maxTeachers: map['maxTeachers'] ?? 30,
      includesAnalytics: map['includesAnalytics'] ?? false,
      includesParentPortal: map['includesParentPortal'] ?? false,
      includesFinanceModule: map['includesFinanceModule'] ?? false,
      includesAttendanceSystem: map['includesAttendanceSystem'] ?? false,
      supportHours: map['supportHours'] ?? 8,
    );
  }

  @override
  SchoolSubscription renew({String? newTransactionId}) {
    final newExpiryDate = expiryDate.add(const Duration(days: 365));

    return SchoolSubscription(
      id: 'school_renew_${DateTime.now().millisecondsSinceEpoch}',
      schoolPlan: schoolPlan,
      startDate: startDate,
      expiryDate: newExpiryDate,
      amount: amount,
      paymentStatus: paymentStatus,
      transactionId: newTransactionId ?? 'school_renew_txn_${DateTime.now().millisecondsSinceEpoch}',
      lastRenewalDate: DateTime.now(),
      autoRenew: autoRenew,
      maxStudents: maxStudents,
      maxTeachers: maxTeachers,
      includesAnalytics: includesAnalytics,
      includesParentPortal: includesParentPortal,
      includesFinanceModule: includesFinanceModule,
      includesAttendanceSystem: includesAttendanceSystem,
      supportHours: supportHours,
    );
  }

  bool get hasUnlimitedStorage => schoolPlan == SchoolPlan.enterprise;
  String get schoolPlanDescription => _getSchoolPlanDescription(schoolPlan);

  static String _getSchoolPlanDescription(SchoolPlan plan) {
    switch (plan) {
      case SchoolPlan.trial:
        return '30-day Free Trial';
      case SchoolPlan.basic:
        return 'School Basic (₦25,000/year)';
      case SchoolPlan.advanced:
        return 'School Advanced (₦50,000/year)';
      case SchoolPlan.enterprise:
        return 'School Enterprise (₦100,000/year)';
    }
  }
}

// ========== PARENT SUBSCRIPTION ==========

class ParentSubscription extends Subscription {
  final ParentPlan parentPlan;
  final int maxChildren;
  final bool includesRealTimeTracking;
  final bool includesAcademicReports;
  final bool includesCommunicationPortal;
  final bool includesFeePayment;

  static const Map<ParentPlan, double> parentPrices = {
    ParentPlan.free: 0.0,
    ParentPlan.premium: 500.0, // Monthly
  };

  ParentSubscription({
    required String id,
    required this.parentPlan,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amount,
    required PaymentStatus paymentStatus,
    required String transactionId,
    DateTime? lastRenewalDate,
    bool autoRenew = false,
    this.maxChildren = 3,
    this.includesRealTimeTracking = false,
    this.includesAcademicReports = false,
    this.includesCommunicationPortal = false,
    this.includesFeePayment = false,
  }) : super(
    id: id,
    plan: Subscription.convertParentPlan(parentPlan),
    startDate: startDate,
    expiryDate: expiryDate,
    amount: amount,
    paymentStatus: paymentStatus,
    transactionId: transactionId,
    lastRenewalDate: lastRenewalDate,
    autoRenew: autoRenew,
  );

  factory ParentSubscription.create({
    required ParentPlan plan, 
    String? transactionId,
    DateTime? customStartDate,
  }) {
    final now = customStartDate ?? DateTime.now();
    final expiryDate = now.add(const Duration(days: 30));

    return ParentSubscription(
      id: 'parent_sub_${DateTime.now().millisecondsSinceEpoch}',
      parentPlan: plan,
      startDate: now,
      expiryDate: expiryDate,
      amount: parentPrices[plan] ?? 0.0,
      paymentStatus: plan == ParentPlan.free
          ? PaymentStatus.completed
          : PaymentStatus.pending,
      transactionId: transactionId ?? 'parent_txn_${DateTime.now().millisecondsSinceEpoch}',
      autoRenew: plan != ParentPlan.free,
      maxChildren: plan == ParentPlan.free ? 1 : 5,
      includesRealTimeTracking: plan == ParentPlan.premium,
      includesAcademicReports: plan == ParentPlan.premium,
      includesCommunicationPortal: plan == ParentPlan.premium,
      includesFeePayment: plan == ParentPlan.premium,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    base.addAll({
      'parentPlan': parentPlan.name,
      'maxChildren': maxChildren,
      'includesRealTimeTracking': includesRealTimeTracking,
      'includesAcademicReports': includesAcademicReports,
      'includesCommunicationPortal': includesCommunicationPortal,
      'includesFeePayment': includesFeePayment,
    });
    return base;
  }

  factory ParentSubscription.fromMap(Map<String, dynamic> map) {
    return ParentSubscription(
      id: map['id'],
      parentPlan: ParentPlan.values.firstWhere(
        (e) => e.name == (map['parentPlan'] ?? 'free'),
        orElse: () => ParentPlan.free,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transactionId'],
      lastRenewalDate: map['lastRenewalDate'] != null
          ? (map['lastRenewalDate'] as Timestamp).toDate()
          : null,
      autoRenew: map['autoRenew'] ?? false,
      maxChildren: map['maxChildren'] ?? 3,
      includesRealTimeTracking: map['includesRealTimeTracking'] ?? false,
      includesAcademicReports: map['includesAcademicReports'] ?? false,
      includesCommunicationPortal: map['includesCommunicationPortal'] ?? false,
      includesFeePayment: map['includesFeePayment'] ?? false,
    );
  }

  @override
  ParentSubscription renew({String? newTransactionId}) {
    final newExpiryDate = expiryDate.add(const Duration(days: 30));

    return ParentSubscription(
      id: 'parent_renew_${DateTime.now().millisecondsSinceEpoch}',
      parentPlan: parentPlan,
      startDate: startDate,
      expiryDate: newExpiryDate,
      amount: amount,
      paymentStatus: paymentStatus,
      transactionId: newTransactionId ?? 'parent_renew_txn_${DateTime.now().millisecondsSinceEpoch}',
      lastRenewalDate: DateTime.now(),
      autoRenew: autoRenew,
      maxChildren: maxChildren,
      includesRealTimeTracking: includesRealTimeTracking,
      includesAcademicReports: includesAcademicReports,
      includesCommunicationPortal: includesCommunicationPortal,
      includesFeePayment: includesFeePayment,
    );
  }

  bool get hasAdvancedFeatures => parentPlan == ParentPlan.premium;
  String get parentPlanDescription => _getParentPlanDescription(parentPlan);

  static String _getParentPlanDescription(ParentPlan plan) {
    switch (plan) {
      case ParentPlan.free:
        return 'Free Plan (1 child)';
      case ParentPlan.premium:
        return 'Parent Premium (₦500/month, up to 5 children)';
    }
  }
}

// ========== KIDLING SUBSCRIPTION ==========

class KidlingSubscription extends Subscription {
  final KidlingPlan kidlingPlan;
  final int maxChildren;
  final bool includesAllActivities;
  final bool includesProgressReports;
  final bool includesParentalControls;
  final bool includesOfflineAccess;
  final int dailyActivityLimit;

  static const Map<KidlingPlan, double> kidlingPrices = {
    KidlingPlan.free: 0.0,
    KidlingPlan.premium: 300.0, // Monthly
    KidlingPlan.family: 600.0, // Monthly (up to 3 children)
  };

  static const Map<KidlingPlan, int> kidlingDurations = {
    KidlingPlan.free: 30,
    KidlingPlan.premium: 30,
    KidlingPlan.family: 30,
  };

  KidlingSubscription({
    required String id,
    required this.kidlingPlan,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amount,
    required PaymentStatus paymentStatus,
    required String transactionId,
    DateTime? lastRenewalDate,
    bool autoRenew = false,
    this.maxChildren = 1,
    this.includesAllActivities = false,
    this.includesProgressReports = false,
    this.includesParentalControls = false,
    this.includesOfflineAccess = false,
    this.dailyActivityLimit = 3,
  }) : super(
    id: id,
    plan: Subscription.convertKidlingPlan(kidlingPlan),
    startDate: startDate,
    expiryDate: expiryDate,
    amount: amount,
    paymentStatus: paymentStatus,
    transactionId: transactionId,
    lastRenewalDate: lastRenewalDate,
    autoRenew: autoRenew,
  );

  factory KidlingSubscription.create({
    required KidlingPlan plan, 
    String? transactionId,
    DateTime? customStartDate,
  }) {
    final now = customStartDate ?? DateTime.now();
    final duration = kidlingDurations[plan] ?? 0;
    final expiryDate = now.add(Duration(days: duration));

    return KidlingSubscription(
      id: 'kidling_sub_${DateTime.now().millisecondsSinceEpoch}',
      kidlingPlan: plan,
      startDate: now,
      expiryDate: expiryDate,
      amount: kidlingPrices[plan] ?? 0.0,
      paymentStatus: plan == KidlingPlan.free
          ? PaymentStatus.completed
          : PaymentStatus.pending,
      transactionId: transactionId ?? 'kidling_txn_${DateTime.now().millisecondsSinceEpoch}',
      autoRenew: plan != KidlingPlan.free,
      maxChildren: plan == KidlingPlan.free ? 1 : (plan == KidlingPlan.premium ? 1 : 3),
      includesAllActivities: plan != KidlingPlan.free,
      includesProgressReports: plan != KidlingPlan.free,
      includesParentalControls: plan != KidlingPlan.free,
      includesOfflineAccess: plan == KidlingPlan.premium || plan == KidlingPlan.family,
      dailyActivityLimit: plan == KidlingPlan.free ? 3 : (plan == KidlingPlan.premium ? 10 : 30),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    base.addAll({
      'kidlingPlan': kidlingPlan.name,
      'maxChildren': maxChildren,
      'includesAllActivities': includesAllActivities,
      'includesProgressReports': includesProgressReports,
      'includesParentalControls': includesParentalControls,
      'includesOfflineAccess': includesOfflineAccess,
      'dailyActivityLimit': dailyActivityLimit,
    });
    return base;
  }

  factory KidlingSubscription.fromMap(Map<String, dynamic> map) {
    return KidlingSubscription(
      id: map['id'],
      kidlingPlan: KidlingPlan.values.firstWhere(
        (e) => e.name == (map['kidlingPlan'] ?? 'free'),
        orElse: () => KidlingPlan.free,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: map['transactionId'],
      lastRenewalDate: map['lastRenewalDate'] != null
          ? (map['lastRenewalDate'] as Timestamp).toDate()
          : null,
      autoRenew: map['autoRenew'] ?? false,
      maxChildren: map['maxChildren'] ?? 1,
      includesAllActivities: map['includesAllActivities'] ?? false,
      includesProgressReports: map['includesProgressReports'] ?? false,
      includesParentalControls: map['includesParentalControls'] ?? false,
      includesOfflineAccess: map['includesOfflineAccess'] ?? false,
      dailyActivityLimit: map['dailyActivityLimit'] ?? 3,
    );
  }

  @override
  KidlingSubscription renew({String? newTransactionId}) {
    final newExpiryDate = expiryDate.add(Duration(days: kidlingDurations[kidlingPlan] ?? 30));

    return KidlingSubscription(
      id: 'kidling_renew_${DateTime.now().millisecondsSinceEpoch}',
      kidlingPlan: kidlingPlan,
      startDate: startDate,
      expiryDate: newExpiryDate,
      amount: amount,
      paymentStatus: paymentStatus,
      transactionId: newTransactionId ?? 'kidling_renew_txn_${DateTime.now().millisecondsSinceEpoch}',
      lastRenewalDate: DateTime.now(),
      autoRenew: autoRenew,
      maxChildren: maxChildren,
      includesAllActivities: includesAllActivities,
      includesProgressReports: includesProgressReports,
      includesParentalControls: includesParentalControls,
      includesOfflineAccess: includesOfflineAccess,
      dailyActivityLimit: dailyActivityLimit,
    );
  }

  bool get hasPremiumFeatures => kidlingPlan != KidlingPlan.free;
  String get kidlingPlanDescription => _getKidlingPlanDescription(kidlingPlan);

  static String _getKidlingPlanDescription(KidlingPlan plan) {
    switch (plan) {
      case KidlingPlan.free:
        return 'Kidling Free (3 activities/day)';
      case KidlingPlan.premium:
        return 'Kidling Premium (₦300/month, unlimited activities)';
      case KidlingPlan.family:
        return 'Kidling Family (₦600/month, up to 3 children)';
    }
  }
}

// ========== CORE USER CLASSES ==========

abstract class BaseUser {
  final String uid;
  final String email;
  final String name;
  final UserType userType;
  final Platform platform;
  final DateTime createdAt;
  final UserStatus status;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final Map<String, dynamic>? metadata;

  BaseUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    required this.platform,
    required this.createdAt,
    this.status = UserStatus.active,
    this.profileImageUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.metadata,
  });

  Map<String, dynamic> toMap();
  
  String get displayName => name;
  bool get isActive => status == UserStatus.active;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isDeleted => status == UserStatus.deleted;
  
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    return now.year - dateOfBirth!.year - 
      ((now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) ? 1 : 0);
  }
}

// ========== STUDENT USER ==========

class StudentUser extends BaseUser {
  final int? classGrade;
  final String? schoolName;
  final String? educationCategory;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final String? studentId;
  final List<String> enrolledCourses;
  final Map<String, double> courseProgress; // courseId -> progress percentage
  final int totalStudyTime; // in minutes
  final int quizScores;
  final int completedLessons;
  final StudentSubscription? currentSubscription;

  StudentUser({
    required String uid,
    required String email,
    required String name,
    required Platform platform,
    required DateTime createdAt,
    UserStatus status = UserStatus.active,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    Map<String, dynamic>? metadata,
    this.classGrade,
    this.schoolName,
    this.educationCategory,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.studentId,
    this.enrolledCourses = const [],
    this.courseProgress = const {},
    this.totalStudyTime = 0,
    this.quizScores = 0,
    this.completedLessons = 0,
    this.currentSubscription,
  }) : super(
    uid: uid,
    email: email,
    name: name,
    userType: UserType.student,
    platform: platform,
    createdAt: createdAt,
    status: status,
    profileImageUrl: profileImageUrl,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    gender: gender,
    address: address,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType.name,
      'platform': platform.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'address': address,
      'metadata': metadata,
      // Student-specific
      'classGrade': classGrade,
      'schoolName': schoolName,
      'educationCategory': educationCategory,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'studentId': studentId,
      'enrolledCourses': enrolledCourses,
      'courseProgress': courseProgress,
      'totalStudyTime': totalStudyTime,
      'quizScores': quizScores,
      'completedLessons': completedLessons,
      'currentSubscription': currentSubscription?.toMap(),
    };
  }

  factory StudentUser.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  
  return StudentUser(
    uid: data['uid'] ?? doc.id,
    email: data['email'] ?? '',
    name: data['name'] ?? '',
    platform: Platform.values.firstWhere(
      (e) => e.name == (data['platform'] ?? 'istudyapp'),
      orElse: () => Platform.istudyapp,
    ),
    createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    status: UserStatus.values.firstWhere(
      (e) => e.name == (data['status'] ?? 'active'),
      orElse: () => UserStatus.active,
    ),
    profileImageUrl: data['profileImageUrl'],
    phoneNumber: data['phoneNumber'],
    dateOfBirth: data['dateOfBirth'] != null 
        ? (data['dateOfBirth'] as Timestamp).toDate()
        : null,
    gender: data['gender'],
    address: data['address'],
    metadata: data['metadata'] != null 
        ? Map<String, dynamic>.from(data['metadata'])
        : null,
    // Student-specific
    classGrade: data['classGrade'],
    schoolName: data['schoolName'],
    educationCategory: data['educationCategory'],
    parentName: data['parentName'],
    parentPhone: data['parentPhone'],
    parentEmail: data['parentEmail'],
    studentId: data['studentId'],
    enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
    courseProgress: (data['courseProgress'] != null)
        ? Map<String, double>.from(
            data['courseProgress'].map((key, value) => 
              MapEntry(key, value.toDouble())
            )
          )
        : {},
    totalStudyTime: data['totalStudyTime'] ?? 0,
    quizScores: data['quizScores'] ?? 0,
    completedLessons: data['completedLessons'] ?? 0,
    currentSubscription: data['currentSubscription'] != null
        ? StudentSubscription.fromMap(
            Map<String, dynamic>.from(data['currentSubscription'])
          )
        : null,
  );
}
factory StudentUser.fromFirestoreQueryDoc(QueryDocumentSnapshot doc) {
  return StudentUser.fromFirestore(doc);
}
static List<StudentUser> fromFirestoreList(List<QueryDocumentSnapshot> docs) {
  return docs.map((doc) => StudentUser.fromFirestoreQueryDoc(doc)).toList();
}

  factory StudentUser.fromMap(Map<String, dynamic> map) {
    return StudentUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      platform: Platform.values.firstWhere(
        (e) => e.name == (map['platform'] ?? 'istudyapp'),
        orElse: () => Platform.istudyapp,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: map['gender'],
      address: map['address'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      // Student-specific
      classGrade: map['classGrade'],
      schoolName: map['schoolName'],
      educationCategory: map['educationCategory'],
      parentName: map['parentName'],
      parentPhone: map['parentPhone'],
      parentEmail: map['parentEmail'],
      studentId: map['studentId'],
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      courseProgress: Map<String, double>.from(map['courseProgress'] ?? {}),
      totalStudyTime: map['totalStudyTime'] ?? 0,
      quizScores: map['quizScores'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      currentSubscription: map['currentSubscription'] != null
          ? StudentSubscription.fromMap(map['currentSubscription'])
          : null,
    );
  }

  // Helper methods
  double get overallProgress {
    if (enrolledCourses.isEmpty) return 0.0;
    final total = courseProgress.values.fold(0.0, (sum, progress) => sum + progress);
    return total / enrolledCourses.length;
  }

  int get averageQuizScore {
    return quizScores;
  }

  String get gradeLevel {
    if (classGrade == null) return 'Not specified';
    return educationCategory == 'Basic Education' 
        ? 'Basic $classGrade'
        : 'SS $classGrade';
  }

  bool get hasActiveSubscription {
    if (currentSubscription == null) return false;
    return currentSubscription!.isActive && !currentSubscription!.hasExpired;
  }

  bool get isOnFreeTrial {
    if (currentSubscription == null) return false;
    return currentSubscription!.studentPlan == StudentPlan.trial && 
           !currentSubscription!.hasExpired;
  }
}

// ========== TEACHER USER ==========

class TeacherUser extends BaseUser {
  final String? qualification;
  final String? subjectSpecialization;
  final String? yearsOfExperience;
  final String? emergencyContact;
  final String? teacherId;
  final String? schoolName;
  final String? schoolAddress;
  final String? schoolPhone;
  final String? schoolEmail;
  final List<String> createdResources;
  final List<String> joinedCommunities;
  final int totalStudents;
  final TeacherSubscription? currentSubscription;

  TeacherUser({
    required String uid,
    required String email,
    required String name,
    required Platform platform,
    required DateTime createdAt,
    UserStatus status = UserStatus.active,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    Map<String, dynamic>? metadata,
    this.qualification,
    this.subjectSpecialization,
    this.yearsOfExperience,
    this.emergencyContact,
    this.teacherId,
    this.schoolName,
    this.schoolAddress,
    this.schoolPhone,
    this.schoolEmail,
    this.createdResources = const [],
    this.joinedCommunities = const [],
    this.totalStudents = 0,
    this.currentSubscription,
  }) : super(
    uid: uid,
    email: email,
    name: name,
    userType: UserType.teacher,
    platform: platform,
    createdAt: createdAt,
    status: status,
    profileImageUrl: profileImageUrl,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    gender: gender,
    address: address,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType.name,
      'platform': platform.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'address': address,
      'metadata': metadata,
      // Teacher-specific
      'qualification': qualification,
      'subjectSpecialization': subjectSpecialization,
      'yearsOfExperience': yearsOfExperience,
      'emergencyContact': emergencyContact,
      'teacherId': teacherId,
      'schoolName': schoolName,
      'schoolAddress': schoolAddress,
      'schoolPhone': schoolPhone,
      'schoolEmail': schoolEmail,
      'createdResources': createdResources,
      'joinedCommunities': joinedCommunities,
      'totalStudents': totalStudents,
      'currentSubscription': currentSubscription?.toMap(),
    };
  }

  factory TeacherUser.fromMap(Map<String, dynamic> map) {
    return TeacherUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      platform: Platform.values.firstWhere(
        (e) => e.name == (map['platform'] ?? 'teachly'),
        orElse: () => Platform.teachly,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: map['gender'],
      address: map['address'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      // Teacher-specific
      qualification: map['qualification'],
      subjectSpecialization: map['subjectSpecialization'],
      yearsOfExperience: map['yearsOfExperience'],
      emergencyContact: map['emergencyContact'],
      teacherId: map['teacherId'],
      schoolName: map['schoolName'],
      schoolAddress: map['schoolAddress'],
      schoolPhone: map['schoolPhone'],
      schoolEmail: map['schoolEmail'],
      createdResources: List<String>.from(map['createdResources'] ?? []),
      joinedCommunities: List<String>.from(map['joinedCommunities'] ?? []),
      totalStudents: map['totalStudents'] ?? 0,
      currentSubscription: map['currentSubscription'] != null
          ? TeacherSubscription.fromMap(map['currentSubscription'])
          : null,
    );
  }

  bool get hasActiveSubscription => currentSubscription?.isActive ?? false;
  bool get isVerifiedTeacher => qualification != null && qualification!.isNotEmpty;
}

// ========== SCHOOL ADMIN USER ==========

class SchoolAdminUser extends BaseUser {
  final String? schoolCode;
  final String? schoolName;
  final String? schoolAddress;
  final String? schoolPhone;
  final String? schoolEmail;
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final String? adminPosition;
  final SchoolSubscription? currentSubscription;

  SchoolAdminUser({
    required String uid,
    required String email,
    required String name,
    required Platform platform,
    required DateTime createdAt,
    UserStatus status = UserStatus.active,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    Map<String, dynamic>? metadata,
    this.schoolCode,
    this.schoolName,
    this.schoolAddress,
    this.schoolPhone,
    this.schoolEmail,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalClasses = 0,
    this.adminPosition,
    this.currentSubscription,
  }) : super(
    uid: uid,
    email: email,
    name: name,
    userType: UserType.schoolAdmin,
    platform: platform,
    createdAt: createdAt,
    status: status,
    profileImageUrl: profileImageUrl,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    gender: gender,
    address: address,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType.name,
      'platform': platform.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'address': address,
      'metadata': metadata,
      // School Admin-specific
      'schoolCode': schoolCode,
      'schoolName': schoolName,
      'schoolAddress': schoolAddress,
      'schoolPhone': schoolPhone,
      'schoolEmail': schoolEmail,
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalClasses': totalClasses,
      'adminPosition': adminPosition,
      'currentSubscription': currentSubscription?.toMap(),
    };
  }

  factory SchoolAdminUser.fromMap(Map<String, dynamic> map) {
    return SchoolAdminUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      platform: Platform.values.firstWhere(
        (e) => e.name == (map['platform'] ?? 'automatedSchool'),
        orElse: () => Platform.automatedSchool,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: map['gender'],
      address: map['address'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      // School Admin-specific
      schoolCode: map['schoolCode'],
      schoolName: map['schoolName'],
      schoolAddress: map['schoolAddress'],
      schoolPhone: map['schoolPhone'],
      schoolEmail: map['schoolEmail'],
      totalStudents: map['totalStudents'] ?? 0,
      totalTeachers: map['totalTeachers'] ?? 0,
      totalClasses: map['totalClasses'] ?? 0,
      adminPosition: map['adminPosition'],
      currentSubscription: map['currentSubscription'] != null
          ? SchoolSubscription.fromMap(map['currentSubscription'])
          : null,
    );
  }

  bool get hasActiveSubscription => currentSubscription?.isActive ?? false;
  double get schoolCapacityUtilization {
    if (totalClasses == 0) return 0.0;
    return (totalStudents / (totalClasses * 30)) * 100; // Assuming 30 students per class
  }
}

// ========== PARENT USER ==========

class ParentUser extends BaseUser {
  final String? relationship;
  final String? studentName;
  final String? studentId;
  final String? studentClass;
  final String? schoolName;
  final List<String> children; // List of student IDs
  final List<String> notifications;
  final ParentSubscription? currentSubscription;
  final KidlingSubscription? kidlingSubscription;

  ParentUser({
    required String uid,
    required String email,
    required String name,
    required Platform platform,
    required DateTime createdAt,
    UserStatus status = UserStatus.active,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    Map<String, dynamic>? metadata,
    this.relationship,
    this.studentName,
    this.studentId,
    this.studentClass,
    this.schoolName,
    this.children = const [],
    this.notifications = const [],
    this.currentSubscription,
    this.kidlingSubscription,
  }) : super(
    uid: uid,
    email: email,
    name: name,
    userType: UserType.parent,
    platform: platform,
    createdAt: createdAt,
    status: status,
    profileImageUrl: profileImageUrl,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    gender: gender,
    address: address,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType.name,
      'platform': platform.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'address': address,
      'metadata': metadata,
      // Parent-specific
      'relationship': relationship,
      'studentName': studentName,
      'studentId': studentId,
      'studentClass': studentClass,
      'schoolName': schoolName,
      'children': children,
      'notifications': notifications,
      'currentSubscription': currentSubscription?.toMap(),
      'kidlingSubscription': kidlingSubscription?.toMap(),
    };
  }

  factory ParentUser.fromMap(Map<String, dynamic> map) {
    return ParentUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      platform: Platform.values.firstWhere(
        (e) => e.name == (map['platform'] ?? 'parentsPortal'),
        orElse: () => Platform.parentsPortal,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: map['gender'],
      address: map['address'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      // Parent-specific
      relationship: map['relationship'],
      studentName: map['studentName'],
      studentId: map['studentId'],
      studentClass: map['studentClass'],
      schoolName: map['schoolName'],
      children: List<String>.from(map['children'] ?? []),
      notifications: List<String>.from(map['notifications'] ?? []),
      currentSubscription: map['currentSubscription'] != null
          ? ParentSubscription.fromMap(map['currentSubscription'])
          : null,
      kidlingSubscription: map['kidlingSubscription'] != null
          ? KidlingSubscription.fromMap(map['kidlingSubscription'])
          : null,
    );
  }

  bool get hasActiveSubscription {
    if (platform == Platform.kidling) {
      return kidlingSubscription?.isActive ?? false;
    }
    return currentSubscription?.isActive ?? false;
  }
  
  bool get hasMultipleChildren => children.length > 1;
  String get primaryChildInfo => '$studentName - $studentClass';
  
  // Kidling-specific getters
  bool get isKidlingParent => platform == Platform.kidling;
  String? get childName => metadata?['childName'];
  int? get childAge => metadata?['childAge'];
  String? get childGender => metadata?['childGender'];
  String? get learningInterest => metadata?['learningInterest'];
  String? get preferredLearningTime => metadata?['preferredLearningTime'];
}

// ========== HELPER FUNCTIONS ==========

extension PlatformExtension on Platform {
  String get displayName {
    switch (this) {
      case Platform.istudyapp:
        return 'iStudyApp';
      case Platform.teachly:
        return 'Teachly';
      case Platform.automatedSchool:
        return 'Automated School';
      case Platform.parentsPortal:
        return 'Parents Portal';
      case Platform.kidling:
        return 'Kidling';
    }
  }
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.student:
        return 'Student';
      case UserType.kidling:
        return 'Kidling';
      case UserType.teacher:
        return 'Teacher';
      case UserType.schoolAdmin:
        return 'School Administrator';
      case UserType.parent:
        return 'Parent';
    }
  }
}

// Factory function to create appropriate user based on type
BaseUser createUserFromMap(Map<String, dynamic> map) {
  final userTypeString = map['userType'] as String? ?? 'student';
  final userType = UserType.values.firstWhere(
    (e) => e.name == userTypeString,
    orElse: () => UserType.student,
  );

  switch (userType) {
    case UserType.student:
      return StudentUser.fromMap(map);
    case UserType.teacher:
      return TeacherUser.fromMap(map);
    case UserType.schoolAdmin:
      return SchoolAdminUser.fromMap(map);
    case UserType.parent:
      return ParentUser.fromMap(map);
    case UserType.kidling:
      return ParentUser.fromMap(map);
  }
}

// Factory function to create subscription based on user type
Subscription createSubscriptionForUserType(UserType userType, Map<String, dynamic> map) {
  switch (userType) {
    case UserType.student:
      return StudentSubscription.fromMap(map);
    case UserType.teacher:
      return TeacherSubscription.fromMap(map);
    case UserType.schoolAdmin:
      return SchoolSubscription.fromMap(map);
      case UserType.kidling:
      return KidlingSubscription.fromMap(map);
    case UserType.parent:
      return ParentSubscription.fromMap(map);
  }
}