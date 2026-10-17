import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

enum ConnectionStatus {
  pending('Pending', Colors.orange, Icons.pending_actions_rounded),
  accepted('Connected', Colors.green, Icons.check_circle_rounded),
  rejected('Rejected', Colors.red, Icons.cancel_rounded),
  blocked('Blocked', Colors.grey, Icons.block_rounded);

  final String displayName;
  final Color color;
  final IconData icon;

  const ConnectionStatus(this.displayName, this.color, this.icon);
}
