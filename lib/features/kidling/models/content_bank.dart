// lib/Kidling/models/content_bank.dart
//
// Hand-written, child-tested style content shared by the lesson builders.
// Activities in Firestore only say WHICH items to teach; the bank knows HOW
// to teach them (colors, example objects, feelings, comfort actions...).

import 'dart:math' as math;
import 'package:flutter/material.dart';

class ColorInfo {
  final String label;
  final Color color;
  final String emoji;
  final String fact;
  const ColorInfo(this.label, this.color, this.emoji, this.fact);
}

class FeelingInfo {
  final String label;
  final String emoji;
  final Color color;
  final List<String> situations;
  final String when;
  final String tip;
  const FeelingInfo(this.label, this.emoji, this.color, this.situations, this.when, this.tip);
}

class HelpScenario {
  final String text;
  final List<String> options; // each "emoji words"
  final int correct;
  const HelpScenario(this.text, this.options, this.correct);
}

class Bank {
  static final math.Random rnd = math.Random();

  static const Map<String, ColorInfo> colors = {
    'red': ColorInfo('Red', Color(0xFFE53935), '🍎', 'An apple can be red.'),
    'blue': ColorInfo('Blue', Color(0xFF1E88E5), '🐳', 'The sea and the sky are blue.'),
    'yellow': ColorInfo('Yellow', Color(0xFFFDD835), '🍌', 'A banana is yellow.'),
    'green': ColorInfo('Green', Color(0xFF43A047), '🐸', 'Frogs and grass are green.'),
    'orange': ColorInfo('Orange', Color(0xFFFB8C00), '🍊', 'An orange is orange!'),
    'purple': ColorInfo('Purple', Color(0xFF8E24AA), '🍇', 'Grapes can be purple.'),
    'pink': ColorInfo('Pink', Color(0xFFEC407A), '🌸', 'Flowers can be pink.'),
    'brown': ColorInfo('Brown', Color(0xFF795548), '🐻', 'Teddy bears are often brown.'),
    'black': ColorInfo('Black', Color(0xFF263238), '🦇', 'The night sky is dark, like black.'),
    'white': ColorInfo('White', Color(0xFFF5F5F5), '⛄', 'Snow is white.'),
  };

  static const Map<String, List<String>> shapes = {
    'circle': ['Circle', '⚽', 'A ball is a circle. It is round.'],
    'square': ['Square', '🪟', 'A square has four equal sides.'],
    'triangle': ['Triangle', '🍕', 'A slice of pizza is a triangle. It has three corners.'],
    'rectangle': ['Rectangle', '🚪', 'A door is a rectangle. It is long.'],
    'star': ['Star', '🌟', 'Stars twinkle in the sky.'],
    'heart': ['Heart', '💖', 'A heart means love.'],
    'oval': ['Oval', '🥚', 'An egg is an oval.'],
    'diamond': ['Diamond', '💎', 'A diamond has four pointy corners.'],
  };

  static const Map<String, FeelingInfo> feelings = {
    'happy': FeelingInfo('Happy', '😊', Color(0xFFFFC93C), ['You got a brand new toy!', 'You are playing with your best friend!'], 'You feel happy when something nice happens.', 'Happy faces have big smiles.'),
    'sad': FeelingInfo('Sad', '😢', Color(0xFF5C9DFF), ['Your ice cream fell on the floor.', 'Your friend is moving far away.'], 'You feel sad when something goes wrong or you miss someone.', 'It is okay to be sad. A hug can help.'),
    'angry': FeelingInfo('Angry', '😠', Color(0xFFFF6B6B), ['Someone took your toy without asking.', 'Your tall tower fell down.'], 'You feel angry when something feels unfair.', 'When you are angry, take three big breaths.'),
    'scared': FeelingInfo('Scared', '😨', Color(0xFFA78BFA), ['It is dark and you hear a loud bang.', 'A big dog barks at you.'], 'You feel scared when you think something might hurt you.', 'When you are scared, tell a grown up.'),
    'surprised': FeelingInfo('Surprised', '😮', Color(0xFFFF9F43), ['Surprise! Your friends say happy birthday!', 'A jack in the box pops up!'], 'You feel surprised when something happens suddenly.', 'Surprised faces have a round open mouth.'),
    'sleepy': FeelingInfo('Sleepy', '😴', Color(0xFF8C8CE6), ['It is bedtime and the moon is out.', 'You played all day and your eyes feel heavy.'], 'You feel sleepy when your body needs rest.', 'Sleepy eyes close, and you yawn.'),
    'excited': FeelingInfo('Excited', '🤩', Color(0xFFFF6FB5), ['Tomorrow you are going to the zoo!', 'The ice cream truck is coming!'], 'You feel excited when something fun is about to happen.', 'Excited faces have sparkly eyes.'),
  };

  static const List<HelpScenario> helping = [
    HelpScenario('Mia is sad. She dropped her ice cream.', ['🤗 Give her a hug', '😆 Laugh at her', '🚶 Walk away'], 0),
    HelpScenario('Leo fell down and hurt his knee.', ['📱 Keep playing', '🤝 Help him up', '🙈 Look away'], 1),
    HelpScenario('A new friend is standing alone at the park.', ['🧸 Ask them to play', '😒 Ignore them', '🏃 Run off'], 0),
    HelpScenario('Sam is angry. His block tower fell down.', ['🧱 Help build it again', '🤭 Tease him', '📺 Go away'], 0),
    HelpScenario('Your little sister is scared of the thunder.', ['🫂 Stay close and cuddle', '😈 Say boo', '🎮 Leave the room'], 0),
  ];

  static const List<String> numberWords = [
    'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
    'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen', 'twenty',
  ];

  static const Map<String, String> objectNames = {
    '🐥': 'chick', '🍎': 'apple', '⭐': 'star', '🍪': 'cookie', '🎈': 'balloon', '🦋': 'butterfly',
    '🐟': 'fish', '🍓': 'strawberry', '🚗': 'car', '🌼': 'flower',
  };

  static const List<List<String>> patternPools = [
    ['🍎', '🍌', '🍇', '🍓'],
    ['🔴', '🔵', '🟡', '🟢'],
    ['🐶', '🐱', '🐸', '🐥'],
    ['🌞', '🌙', '⭐', '☁️'],
    ['🚗', '🚌', '🚲', '✈️'],
  ];

  /// Returns [n] distinct items from [pool] excluding [not], shuffled.
  static List<T> others<T>(List<T> pool, T not, int n) {
    final c = pool.where((e) => e != not).toList()..shuffle(rnd);
    return c.take(n).toList();
  }

  static String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
