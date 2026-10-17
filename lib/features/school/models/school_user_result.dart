import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

class SchoolUserResult {
  final bool success;
  final String? error;
  final String? profileId;

  SchoolUserResult._({this.success = false, this.error, this.profileId});

  factory SchoolUserResult.success([String? profileId]) {
    return SchoolUserResult._(success: true, profileId: profileId);
  }

  factory SchoolUserResult.error(String error) {
    return SchoolUserResult._(error: error);
  }
}
