import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';

class Question {
  final String id;
  final String text;
  final String type; // 'multiple_choice', 'true_false', 'short_answer', 'essay'
  final List<String> options;
  final List<int> correctOptions;
  final String? correctAnswer;
  final int points;
  final String? explanation;
  final Map<String, dynamic> metadata;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.correctOptions = const [],
    this.correctAnswer,
    this.points = 1,
    this.explanation,
    this.metadata = const {},
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'multiple_choice',
      options: List<String>.from(map['options'] ?? []),
      correctOptions: List<int>.from(map['correctOptions'] ?? []),
      correctAnswer: map['correctAnswer'],
      points: map['points'] ?? 1,
      explanation: map['explanation'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type,
      'options': options,
      'correctOptions': correctOptions,
      'correctAnswer': correctAnswer,
      'points': points,
      'explanation': explanation,
      'metadata': metadata,
    };
  }

  bool get hasMultipleAnswers => correctOptions.length > 1;
  bool get isMultipleChoice => type == 'multiple_choice';
  bool get isTrueFalse => type == 'true_false';
}
