import 'package:flutter/material.dart';

/// "Aurora" palette for focused study screens (primary, secondary, teachers).
/// Kidling keeps its own storybook palette.
class Scholar {
  Scholar._();

  static const Color night = Color(0xFF0E1330);
  static const Color indigo = Color(0xFF1C2461);
  static const Color violet = Color(0xFF5B3FD0);
  static const Color aurora = Color(0xFF3DDBC0);
  static const Color sun = Color(0xFFFFC857);
  static const Color coral = Color(0xFFFF7A7A);
  static const Color sky = Color(0xFF5CC8FF);
  static const Color mint = Color(0xFF5BE3A8);
  static const Color lilac = Color(0xFFB388FF);
  static const Color card = Color(0x1AFFFFFF);

  static const LinearGradient backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [night, indigo, Color(0xFF2B1B6B)],
  );

  static TextStyle h1([Color c = Colors.white]) => TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c, height: 1.1);
  static TextStyle h2([Color c = Colors.white]) => TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: c);
  static TextStyle body([Color c = Colors.white70]) => TextStyle(fontSize: 14, color: c, height: 1.3);

  static BoxDecoration glass({double radius = 24, Color? tint}) => BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(.08),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      );
}
