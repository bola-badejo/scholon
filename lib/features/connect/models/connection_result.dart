import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

// ========== RESULT CLASSES ==========
class ConnectionResult {
  final bool success;
  final String? error;
  final String? connectionId;

  ConnectionResult._({this.success = false, this.error, this.connectionId});

  factory ConnectionResult.success([String? connectionId]) {
    return ConnectionResult._(success: true, connectionId: connectionId);
  }

  factory ConnectionResult.error(String error) {
    return ConnectionResult._(error: error);
  }
}
