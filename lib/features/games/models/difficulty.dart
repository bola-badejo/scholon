import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Difficulty {
  easy,
  medium,
  hard;

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
