import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

class GameDetail {
  final String emojiImage;
  final String description;
  final Color color;
  final String image;
  final String name;
  final String instructor;
  final int time;
  final String route;

  GameDetail({
    required this.emojiImage,
    required this.description,
    required this.color,
    required this.image,
    required this.name,
    required this.instructor,
    required this.time,
    required this.route,
  });
}
