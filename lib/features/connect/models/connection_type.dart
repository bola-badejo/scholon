import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

enum ConnectionType {
  parent('Parent', Icons.family_restroom, Colors.deepOrange),
  teacher('Teacher', Icons.school, Colors.blue),
  school('School', Icons.business, Colors.green),
  student('Student', Icons.person, Colors.purple),
  classmate('Classmate', Icons.groups, Colors.teal),
  course('Course', Icons.menu_book, Colors.indigo),
  job('Job', Icons.work, Colors.amber),
  kidling('Kidling', Icons.work, Colors.red);

  final String displayName;
  final IconData icon;
  final Color color;

  const ConnectionType(this.displayName, this.icon, this.color);
}
