import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

class ValidationResult {
  final bool success;
  final String? message;

  ValidationResult._({this.success = false, this.message});

  factory ValidationResult.success() {
    return ValidationResult._(success: true);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(message: message);
  }
}
