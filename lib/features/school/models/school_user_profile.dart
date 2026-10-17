import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/models/nigerian_class.dart';
import 'package:isapp/features/school/models/nigerian_position.dart';
import 'package:isapp/features/school/models/school_department.dart';

class SchoolUserProfile {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final UserType userType;

  // School-specific data
  final String? schoolId;
  final String? schoolName;
  final String? schoolCode;

  // Role-based data
  final NigerianClass? studentClass;
  final SchoolDepartment? teacherDepartment;
  final NigerianPosition? staffPosition;
  final String? employeeId;
  final String? studentId;
  final String? parentGuardianId;

  // Academic data
  final List<String> assignedSubjects;
  final List<String> enrolledSubjects;
  final Map<String, String> classResponsibilities;
  final bool isClassCaptain;
  final bool isPrefect;
  final String? prefectPosition;

  // Parent-specific
  final List<String> childrenIds;
  final List<String> childrenNames;
  final String? relationshipToChild;

  // Administrative
  final DateTime? joinedDate;
  final DateTime? enrollmentDate;
  final bool isActive;
  final bool isVerified;
  final Map<String, dynamic> privileges;

  // Additional info
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? medicalInfo;

  SchoolUserProfile({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userType,
    this.schoolId,
    this.schoolName,
    this.schoolCode,
    this.studentClass,
    this.teacherDepartment,
    this.staffPosition,
    this.employeeId,
    this.studentId,
    this.parentGuardianId,
    this.assignedSubjects = const [],
    this.enrolledSubjects = const [],
    this.classResponsibilities = const {},
    this.isClassCaptain = false,
    this.isPrefect = false,
    this.prefectPosition,
    this.childrenIds = const [],
    this.childrenNames = const [],
    this.relationshipToChild,
    this.joinedDate,
    this.enrollmentDate,
    this.isActive = true,
    this.isVerified = false,
    this.privileges = const {},
    this.profileImageUrl,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.medicalInfo,
  });

  factory SchoolUserProfile.fromFirestore(Map<String, dynamic> data) {
    return SchoolUserProfile(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.name == (data['userType'] ?? 'student'),
        orElse: () => UserType.student,
      ),
      schoolId: data['schoolId'],
      schoolName: data['schoolName'],
      schoolCode: data['schoolCode'],
      studentClass: data['studentClass'] != null
          ? NigerianClass.values.firstWhere(
              (e) => e.displayName == data['studentClass'],
              orElse: () => NigerianClass.primary1,
            )
          : null,
      teacherDepartment: data['teacherDepartment'] != null
          ? SchoolDepartment.values.firstWhere(
              (e) => e.name == data['teacherDepartment'],
              orElse: () => SchoolDepartment.sciences,
            )
          : null,
      staffPosition: data['staffPosition'] != null
          ? NigerianPosition.values.firstWhere(
              (e) => e.title == data['staffPosition'],
              orElse: () => NigerianPosition.subjectTeacher,
            )
          : null,
      employeeId: data['employeeId'],
      studentId: data['studentId'],
      parentGuardianId: data['parentGuardianId'],
      assignedSubjects: List<String>.from(data['assignedSubjects'] ?? []),
      enrolledSubjects: List<String>.from(data['enrolledSubjects'] ?? []),
      classResponsibilities: Map<String, String>.from(
        data['classResponsibilities'] ?? {},
      ),
      isClassCaptain: data['isClassCaptain'] ?? false,
      isPrefect: data['isPrefect'] ?? false,
      prefectPosition: data['prefectPosition'],
      childrenIds: List<String>.from(data['childrenIds'] ?? []),
      childrenNames: List<String>.from(data['childrenNames'] ?? []),
      relationshipToChild: data['relationshipToChild'],
      joinedDate: data['joinedDate'] != null
          ? (data['joinedDate'] as Timestamp).toDate()
          : null,
      enrollmentDate: data['enrollmentDate'] != null
          ? (data['enrollmentDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      privileges: Map<String, dynamic>.from(data['privileges'] ?? {}),
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: data['gender'],
      bloodGroup: data['bloodGroup'],
      medicalInfo: data['medicalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userType': userType.name,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'schoolCode': schoolCode,
      'studentClass': studentClass?.displayName,
      'teacherDepartment': teacherDepartment?.name,
      'staffPosition': staffPosition?.title,
      'employeeId': employeeId,
      'studentId': studentId,
      'parentGuardianId': parentGuardianId,
      'assignedSubjects': assignedSubjects,
      'enrolledSubjects': enrolledSubjects,
      'classResponsibilities': classResponsibilities,
      'isClassCaptain': isClassCaptain,
      'isPrefect': isPrefect,
      'prefectPosition': prefectPosition,
      'childrenIds': childrenIds,
      'childrenNames': childrenNames,
      'relationshipToChild': relationshipToChild,
      'joinedDate': joinedDate != null ? Timestamp.fromDate(joinedDate!) : null,
      'enrollmentDate': enrollmentDate != null
          ? Timestamp.fromDate(enrollmentDate!)
          : null,
      'isActive': isActive,
      'isVerified': isVerified,
      'privileges': privileges,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'medicalInfo': medicalInfo,
      'updatedAt': Timestamp.now(),
    };
  }

  bool get isTeacher => userType == UserType.teacher;
  bool get isStudent => userType == UserType.student;
  bool get isParent => userType == UserType.parent;
  bool get isSchoolAdmin => userType == UserType.schoolAdmin;

  String get displayRole {
    if (isTeacher)
      return '${staffPosition?.title ?? "Teacher"} - ${teacherDepartment?.name ?? "Department"}';
    if (isStudent) return 'Student - ${studentClass?.displayName ?? "Class"}';
    if (isParent)
      return 'Parent${relationshipToChild != null ? " ($relationshipToChild)" : ""}';
    return 'School Admin';
  }

  bool get canManageStudents =>
      isSchoolAdmin || (isTeacher && staffPosition!.authorityLevel >= 2);

  bool get canAssignGrades => isTeacher;
  bool get canViewReports => isTeacher || isParent || isSchoolAdmin;
}
