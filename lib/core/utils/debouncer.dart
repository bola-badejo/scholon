// lib/Utils/debouncer.dart
import 'dart:async';
import 'dart:ui';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay, required int milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}