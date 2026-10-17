import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

enum UserOnlineStatus {
  online('Online', Colors.green),
  offline('Offline', Colors.grey),
  busy('Busy', Colors.orange),
  studying('Studying', Colors.blue);

  final String displayName;
  final Color color;

  const UserOnlineStatus(this.displayName, this.color);
}
