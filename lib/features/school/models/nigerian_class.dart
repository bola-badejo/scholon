import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

enum NigerianClass {
  // Basic Education: Primary 1-6 (ages 6-11)
  primary1('Primary 1', 'Basic', 1, Colors.blue, Icons.child_care_rounded),
  primary2('Primary 2', 'Basic', 2, Colors.blue, Icons.child_care_rounded),
  primary3('Primary 3', 'Basic', 3, Colors.blue, Icons.child_care_rounded),
  primary4('Primary 4', 'Basic', 4, Colors.blue, Icons.child_care_rounded),
  primary5('Primary 5', 'Basic', 5, Colors.blue, Icons.child_care_rounded),
  primary6('Primary 6', 'Basic', 6, Colors.blue, Icons.child_care_rounded),

  // Junior Secondary School: JSS 1-3 (ages 12-14)
  jss1('JSS 1', 'Junior Secondary', 7, Colors.green, Icons.school_rounded),
  jss2('JSS 2', 'Junior Secondary', 8, Colors.green, Icons.school_rounded),
  jss3('JSS 3', 'Junior Secondary', 9, Colors.green, Icons.school_rounded),

  // Senior Secondary School: SSS 1-3 (ages 15-17)
  sss1('SSS 1', 'Senior Secondary', 10, Colors.purple, Icons.school_rounded),
  sss2('SSS 2', 'Senior Secondary', 11, Colors.purple, Icons.school_rounded),
  sss3('SSS 3', 'Senior Secondary', 12, Colors.purple, Icons.school_rounded);

  final String displayName;
  final String level;
  final int grade;
  final Color color;
  final IconData icon;

  const NigerianClass(
    this.displayName,
    this.level,
    this.grade,
    this.color,
    this.icon,
  );

  bool get isPrimary => level == 'Basic';
  bool get isJuniorSecondary => level == 'Junior Secondary';
  bool get isSeniorSecondary => level == 'Senior Secondary';

  String get fullName => '$level $displayName';

  static List<NigerianClass> get primaryClasses =>
      values.where((c) => c.isPrimary).toList();

  static List<NigerianClass> get juniorSecondaryClasses =>
      values.where((c) => c.isJuniorSecondary).toList();

  static List<NigerianClass> get seniorSecondaryClasses =>
      values.where((c) => c.isSeniorSecondary).toList();
}
