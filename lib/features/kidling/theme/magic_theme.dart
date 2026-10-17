// lib/Kidling/theme/magic_theme.dart
//
// Design tokens for the "Twilight Storybook" look of Kidling.
// Palette: Midnight Violet (sky), Dusk Plum (hills), Peach Glow (horizon),
// Sunbeam (Luma + stars), Mint Sparkle (success), Candy (play).

import 'package:flutter/material.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';

class Magic {
  static const Color midnight = Color(0xFF241552);
  static const Color dusk = Color(0xFF5B2A86);
  static const Color peach = Color(0xFFFFB38A);
  static const Color sun = Color(0xFFFFD66B);
  static const Color mint = Color(0xFF5BE3A8);
  static const Color sky = Color(0xFF5CC8FF);
  static const Color candy = Color(0xFFFF6FB5);
  static const Color cream = Color(0xFFFFF7EC);
  static const Color ink = Color(0xFF2A1F4D);

  /// Top -> bottom colors of the twilight sky.
  static const List<Color> skyColors = [
    Color(0xFF241552),
    Color(0xFF5B2A86),
    Color(0xFFD9558F),
    Color(0xFFFFB38A),
  ];

  /// Optional: bundle "Fredoka" (or "Baloo 2") in pubspec.yaml for the full
  /// effect. If the font is not bundled Flutter silently falls back.
  static const String font = 'Fredoka';

  static TextStyle title([Color c = Colors.white, double s = 30]) => TextStyle(
        fontFamily: font,
        fontSize: s,
        fontWeight: FontWeight.w700,
        color: c,
        height: 1.12,
      );

  static TextStyle body([Color c = Colors.white, double s = 17]) => TextStyle(
        fontFamily: font,
        fontSize: s,
        fontWeight: FontWeight.w500,
        color: c,
        height: 1.25,
      );

  static List<BoxShadow> glow(Color c, {double blur = 24, double a = .5}) => [
        BoxShadow(color: c.withOpacity(a), blurRadius: blur, spreadRadius: 1),
      ];
}

/// One themed "world" per activity category.
class WorldInfo {
  final String name;
  final String emoji;
  final String tagline;
  final String skill; // radar-chart axis this world feeds
  final String parentTip;
  final Color color;
  final Color deep;

  const WorldInfo(this.name, this.emoji, this.tagline, this.skill, this.color,
      this.deep, this.parentTip);

  static WorldInfo of(KidActivityType t) {
    switch (t) {
      case KidActivityType.phonics:
        return const WorldInfo(
            'Letter Land',
            '🔤',
            'Where letters sing!',
            'Literacy',
            Color(0xFF4D96FF),
            Color(0xFF2457C5),
            'Point out the first letter of everyday things: "Spoon starts with sss!"');
      case KidActivityType.colorShape:
        return const WorldInfo(
            'Rainbow Valley',
            '🌈',
            'Colors and shapes everywhere!',
            'Logic',
            Color(0xFFB65CFF),
            Color(0xFF7A2DC4),
            'Play "I spy": "I spy something round and red!" on a walk.');
      case KidActivityType.counting:
        return const WorldInfo(
            'Number Forest',
            '🌳',
            'Count with the woodland friends!',
            'Numeracy',
            Color(0xFF2EC98A),
            Color(0xFF138A5C),
            'Count stairs, spoons and grapes together. Touch each one as you count.');
      case KidActivityType.memory:
        return const WorldInfo(
            'Memory Moon',
            '🌙',
            'Flip, peek and remember!',
            'Memory',
            Color(0xFFFF9F43),
            Color(0xFFC96A12),
            'Put 3 things on a tray, cover them, remove one. What is missing?');
      case KidActivityType.puzzle:
        return const WorldInfo(
            'Puzzle Peak',
            '⛰️',
            'Patterns, pieces and clever thinking!',
            'Logic',
            Color(0xFF1DC9B8),
            Color(0xFF0E8B7E),
            'Make patterns with snacks or blocks: red, blue, red, blue... what is next?');
      case KidActivityType.creativity:
        return const WorldInfo(
            'Art Meadow',
            '🎨',
            'Paint, stamp and imagine!',
            'Creativity',
            Color(0xFFFF6FB5),
            Color(0xFFC73A84),
            'Ask "Tell me about your picture" and listen. Praise effort, not perfection.');
      case KidActivityType.emotion:
        return const WorldInfo(
            'Feelings Beach',
            '🏖️',
            'Understand every feeling!',
            'Feelings',
            Color(0xFFFF7A6B),
            Color(0xFFC9473A),
            'Name feelings in the moment: "You look frustrated. Let us take 3 big breaths."');
      case KidActivityType.music:
        return const WorldInfo(
            'Music Mountain',
            '🎵',
            'Listen, tap and make music!',
            'Creativity',
            Color(0xFF7C83FF),
            Color(0xFF4247C9),
            'Clap a rhythm and have your child copy it. Then swap roles!');
    }
  }
}

/// Level number is the numeric suffix of the activity id (phonics_3 -> 3).
extension ActivityLevel on Activity {
  int get level => int.tryParse(id.split('_').last) ?? 0;
  WorldInfo get world => WorldInfo.of(type);
}
