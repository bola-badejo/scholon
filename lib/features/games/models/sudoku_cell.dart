import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SudokuCell {
  final int row;
  final int col;
  int value;
  bool isOriginal;
  bool isCorrect;
  bool hasError;
  bool isHint;

  SudokuCell({
    required this.row,
    required this.col,
    this.value = 0,
    this.isOriginal = false,
    this.isCorrect = false,
    this.hasError = false,
    this.isHint = false,
  });
}
