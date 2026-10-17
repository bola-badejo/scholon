// lib/Kidling/controllers/audio_assistant_services.dart
//
// Voice (flutter_tts) + synthesized sound effects and musical notes
// (just_audio). No sound asset files are needed: every ding, boing and piano
// note is generated in memory as a tiny WAV, so there is nothing to forget in
// pubspec.yaml.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioAssistantService extends GetxService {
  /// Safe accessor: finds the service or registers it.
  static AudioAssistantService ensure() => Get.isRegistered<AudioAssistantService>()
      ? Get.find<AudioAssistantService>()
      : Get.put(AudioAssistantService(), permanent: true);

  final FlutterTts _tts = FlutterTts();
  final List<AudioPlayer> _pool = List.generate(5, (_) => AudioPlayer());
  int _poolIdx = 0;
  final Map<String, Uint8List> _wavCache = {};
  final math.Random _rnd = math.Random();

  final RxBool isSpeaking = false.obs;
  final RxBool voiceOn = true.obs; // parents can mute voice
  final RxBool soundOn = true.obs; // ...and effects

  int _token = 0; // invalidates running speech sequences

  // C major scale, C4 -> C5
  static const List<double> _scale = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25];
  static const List<String> noteNames = ['Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Ti', 'Do'];

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.3);
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() => isSpeaking.value = true);
      _tts.setCompletionHandler(() => isSpeaking.value = false);
      _tts.setCancelHandler(() => isSpeaking.value = false);
      _tts.setErrorHandler((_) => isSpeaking.value = false);
    } catch (e) {
      // ignore: avoid_print
      print('TTS init error: $e');
    }
  }

  // ------------------------------------------------------------
  //  VOICE
  // ------------------------------------------------------------

  /// Emojis and symbols are removed so the voice never reads them out.
  String _clean(String text) => text
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Speaks [text]. The future completes when the sentence has been spoken.
  Future<void> speak(String text, {bool interrupt = true}) async {
    if (!voiceOn.value) return;
    final clean = _clean(text);
    if (clean.isEmpty) return;
    try {
      if (interrupt) {
        _token++;
        await _tts.stop();
      }
      await _tts.speak(clean).timeout(const Duration(seconds: 25), onTimeout: () => null);
    } catch (e) {
      isSpeaking.value = false;
    }
  }

  Future<void> speakAndWait(String text) => speak(text);

  /// Speaks several lines one after another, abandoning the sequence if
  /// something else starts talking.
  Future<void> speakSequence(List<String> lines, {Duration gap = const Duration(milliseconds: 250)}) async {
    final my = ++_token;
    try {
      await _tts.stop();
    } catch (_) {}
    for (final l in lines) {
      if (my != _token) return;
      final clean = _clean(l);
      if (clean.isEmpty) continue;
      try {
        await _tts.speak(clean).timeout(const Duration(seconds: 25), onTimeout: () => null);
      } catch (_) {
        return;
      }
      await Future.delayed(gap);
    }
  }

  Future<void> stop() async {
    _token++;
    try {
      await _tts.stop();
    } catch (_) {}
    for (final p in _pool) {
      try {
        await p.stop();
      } catch (_) {}
    }
    isSpeaking.value = false;
  }

  void setVolume(double v) {
    try {
      _tts.setVolume(v.clamp(0.0, 1.0));
    } catch (_) {}
  }

  void setSpeechRate(double r) {
    try {
      _tts.setSpeechRate(r.clamp(0.3, 0.7));
    } catch (_) {}
  }

  // ------------------------------------------------------------
  //  WORDS OF ENCOURAGEMENT
  // ------------------------------------------------------------

  static const _praise = [
    'Yay! You got it!',
    'Wow, amazing!',
    'Super job!',
    'You are so clever!',
    'Hooray! That is right!',
    'Fantastic!',
    'You are a star!',
    'Brilliant!',
  ];
  static const _oops = [
    'Oops! Try again.',
    'Almost! You can do it.',
    'Hmm, have another look.',
    'Not quite. Try another one.',
  ];

  String praiseLine() => _praise[_rnd.nextInt(_praise.length)];
  String oopsLine() => _oops[_rnd.nextInt(_oops.length)];

  void praise() => speak(praiseLine());
  void oops() => speak(oopsLine());
  void encourage() => speak('You are doing great, sweetie!');
  void celebrate() => speak('Hooray! You did it!');
  void welcomeActivity(String name) => speak('Let us play $name!');
  void sayGoodbye() => speak('Bye bye! Come back soon!');

  void giveHint(String activityType, int attemptCount) {
    const hints = {
      'phonics': ['Listen to the sound.', 'Which letter is this?', 'Say it out loud!'],
      'counting': ['Count each one.', 'Point as you count.', 'What comes next?'],
      'colorShape': ['Look at the color.', 'Find something similar.', 'You know this!'],
      'memory': ['Where was that card?', 'Look at all the cards.', 'You have a great memory!'],
      'puzzle': ['Look at the pieces.', 'Try moving this one.', 'Getting closer!'],
      'creativity': ['Use your imagination!', 'Any color you like!', 'There are no mistakes in art!'],
      'emotion': ['How would you feel?', 'Look at the faces.', 'Which one matches?'],
      'music': ['Tap to hear it!', 'Try another one.', 'Listen to the music!'],
    };
    final h = hints[activityType] ?? ['Take your time!', 'You can do it!', 'Try again!'];
    speak(h[attemptCount % h.length]);
  }

  // ------------------------------------------------------------
  //  SOUND EFFECTS & NOTES (synthesized)
  // ------------------------------------------------------------

  Uint8List _wav(double freq, int ms, double vol, {bool bell = true}) {
    final key = '${freq.round()}_${ms}_${(vol * 100).round()}_$bell';
    final cached = _wavCache[key];
    if (cached != null) return cached;

    const sr = 22050;
    final n = sr * ms ~/ 1000;
    final data = ByteData(44 + n * 2);
    void tag(int o, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    tag(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    tag(8, 'WAVE');
    tag(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sr, Endian.little);
    data.setUint32(28, sr * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    tag(36, 'data');
    data.setUint32(40, n * 2, Endian.little);

    final secs = ms / 1000;
    for (var i = 0; i < n; i++) {
      final t = i / sr;
      final attack = math.min(1.0, i / (sr * 0.006));
      final decay = bell ? math.exp(-4.2 * t / secs) : math.exp(-1.6 * t / secs);
      final tail = math.min(1.0, (n - i) / (sr * 0.02));
      final s = math.sin(2 * math.pi * freq * t) +
          .38 * math.sin(2 * math.pi * freq * 2 * t) +
          .14 * math.sin(2 * math.pi * freq * 3 * t);
      data.setInt16(44 + i * 2, (s * attack * decay * tail * vol * 17000).round(), Endian.little);
    }
    final bytes = data.buffer.asUint8List();
    _wavCache[key] = bytes;
    return bytes;
  }

  Future<void> _play(double freq, int ms, {double vol = .6, bool bell = true}) async {
    if (!soundOn.value) return;
    try {
      final p = _pool[_poolIdx++ % _pool.length];
      await p.setAudioSource(_BytesSource(_wav(freq, ms, vol, bell: bell)));
      await p.setVolume(1.0);
      unawaited(p.play());
    } catch (_) {}
  }

  /// Musical note: [degree] 0..7 on the C-major scale.
  Future<void> playNote(int degree, {int ms = 650}) => _play(_scale[degree.clamp(0, 7)], ms, vol: .7);

  /// Raw frequency, used for pitch games.
  Future<void> playFrequency(double hz, {int ms = 700}) => _play(hz, ms, vol: .7);

  /// Sound effect names: tap, correct, wrong, star, complete, flip, pop
  Future<void> playSfx(String name) async {
    switch (name) {
      case 'tap':
        await _play(880, 70, vol: .3);
        break;
      case 'flip':
        await _play(620, 90, vol: .35);
        break;
      case 'pop':
        await _play(1040, 110, vol: .4);
        break;
      case 'wrong':
        await _play(196, 260, vol: .35, bell: false);
        break;
      case 'correct':
        await _play(659.25, 130, vol: .5);
        await Future.delayed(const Duration(milliseconds: 90));
        await _play(987.77, 260, vol: .5);
        break;
      case 'star':
        await _play(1318.5, 140, vol: .45);
        await Future.delayed(const Duration(milliseconds: 90));
        await _play(1975.5, 320, vol: .4);
        break;
      case 'complete':
        for (final f in [523.25, 659.25, 783.99, 1046.5]) {
          await _play(f, 360, vol: .5);
          await Future.delayed(const Duration(milliseconds: 130));
        }
        break;
      default:
        await _play(740, 90, vol: .3);
    }
  }

  void light() => HapticFeedback.lightImpact();
  void medium() => HapticFeedback.mediumImpact();

  @override
  void onClose() {
    try {
      _tts.stop();
    } catch (_) {}
    for (final p in _pool) {
      p.dispose();
    }
    super.onClose();
  }
}

class _BytesSource extends StreamAudioSource {
  final Uint8List bytes;
  _BytesSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}
