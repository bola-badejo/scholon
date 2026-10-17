import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

enum SchoolDepartment {
  // Core Departments
  sciences('Sciences', Icons.science_rounded, Colors.blue),
  artsHumanities('Arts & Humanities', Icons.palette_rounded, Colors.purple),
  commercial('Commercial', Icons.business_rounded, Colors.green),
  technical('Technical', Icons.build_rounded, Colors.orange),
  languages('Languages', Icons.language_rounded, Colors.red),

  // Administrative
  administration(
    'Administration',
    Icons.admin_panel_settings_rounded,
    Colors.teal,
  ),
  guidance('Guidance & Counseling', Icons.psychology_rounded, Colors.pink),
  sports('Sports & PE', Icons.sports_rounded, Colors.amber),
  library('Library', Icons.library_books_rounded, Colors.brown);

  final String name;
  final IconData icon;
  final Color color;

  const SchoolDepartment(this.name, this.icon, this.color);
}
