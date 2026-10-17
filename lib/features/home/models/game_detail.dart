import 'package:flutter/material.dart';

class GameDetail {
  String image;
  String emojiImage;
  String name;
  String instructor;
  String description;
  Color color;
  int time;

  GameDetail({
    required this.emojiImage,
    required this.description,
    required this.color,
    required this.image,
    required this.name,
    required this.instructor,
    required this.time,
  });
}
