import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

class GroupResult {
  final bool success;
  final String? error;
  final String? groupId;

  GroupResult._({this.success = false, this.error, this.groupId});

  factory GroupResult.success([String? groupId]) {
    return GroupResult._(success: true, groupId: groupId);
  }

  factory GroupResult.error(String error) {
    return GroupResult._(error: error);
  }
}
