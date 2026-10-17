import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

enum NigerianPosition {
  classTeacher('Class Teacher', Icons.class_rounded, 1),
  subjectTeacher('Subject Teacher', Icons.book_rounded, 1),
  headOfDepartment('Head of Department', Icons.leaderboard_rounded, 2),
  vicePrincipal('Vice Principal', Icons.supervisor_account_rounded, 3),
  principal('Principal', Icons.school_rounded, 4),
  bursar('Bursar', Icons.attach_money_rounded, 2),
  librarian('Librarian', Icons.library_books_rounded, 1),
  counselor('Counselor', Icons.psychology_rounded, 1),
  sportsCoach('Sports Coach', Icons.sports_rounded, 1),
  labTechnician('Lab Technician', Icons.science_rounded, 1);

  final String title;
  final IconData icon;
  final int authorityLevel;

  const NigerianPosition(this.title, this.icon, this.authorityLevel);
}
