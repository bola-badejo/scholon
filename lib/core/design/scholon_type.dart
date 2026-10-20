import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One typographic system for the whole app (Inter, with a serif option for
/// long-form reading). Sizes follow the product spec's starting scale and
/// respect the user's text scaling.
class ScholonType {
  ScholonType._();

  static TextStyle _inter(double size, FontWeight w, {double h = 1.3, double ls = 0, Color? color}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, height: h, letterSpacing: ls, color: color);

  static TextStyle display([Color? c]) => _inter(36, FontWeight.w600, h: 1.12, ls: -0.8, color: c);
  static TextStyle pageTitle([Color? c]) => _inter(28, FontWeight.w600, h: 1.15, ls: -0.5, color: c);
  static TextStyle section([Color? c]) => _inter(21, FontWeight.w600, h: 1.25, ls: -0.2, color: c);
  static TextStyle cardTitle([Color? c]) => _inter(17, FontWeight.w600, h: 1.25, color: c);
  static TextStyle bodyLarge([Color? c]) => _inter(17, FontWeight.w400, h: 1.55, color: c);
  static TextStyle body([Color? c]) => _inter(15, FontWeight.w400, h: 1.5, color: c);
  static TextStyle support([Color? c]) => _inter(13.5, FontWeight.w400, h: 1.4, color: c);
  static TextStyle label([Color? c]) => _inter(12.5, FontWeight.w500, h: 1.25, ls: 0.2, color: c);

  /// Long-form lesson text: wider leading, editorial serif.
  static TextStyle reading({double scale = 1, Color? color}) =>
      GoogleFonts.sourceSerif4(fontSize: 18 * scale, height: 1.7, color: color);

  static TextStyle code({double scale = 1, Color? color}) =>
      GoogleFonts.jetBrainsMono(fontSize: 13.5 * scale, height: 1.5, color: color);
}
