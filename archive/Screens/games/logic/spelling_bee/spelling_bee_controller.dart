import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SpellingBeeController extends GetxController {
  List<Map<String, dynamic>> words = [];
  RxInt currentIndex = 0.obs;
  RxInt score = 0.obs;
  RxString userAnswer = ''.obs;
  RxInt timeLeft = 60.obs;
  Timer? timer;
  FlutterTts flutterTts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();
  List<String> missedWords = [];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadWords(String level) async {
    String data = await rootBundle.loadString('assets/words.json');
    Map<String, dynamic> jsonResult = json.decode(data);
    words = List<Map<String, dynamic>>.from(jsonResult[level]);
    words.shuffle();
    words = words.take(10).toList();
    startTimer();
  }

  void startTimer() {
    timeLeft.value = 60;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        checkAnswer();
      }
    });
  }

  Future<void> speakWord() async {
    var wordData = words[currentIndex.value];
    await flutterTts.speak("${wordData['word']}. Meaning: ${wordData['meaning']}");
  }

  void checkAnswer() {
    String correctWord = words[currentIndex.value]['word'].toLowerCase();
    if (userAnswer.value.trim().toLowerCase() == correctWord) {
      score.value++;
      audioPlayer.play(AssetSource('sounds/clap.mp3'));
    } else {
      missedWords.add("${words[currentIndex.value]['word']} - ${userAnswer.value}");
      audioPlayer.play(AssetSource('sounds/fail.mp3'));
    }
    nextQuestion();
  }

  void nextQuestion() {
    if (currentIndex.value < words.length - 1) {
      currentIndex.value++;
      userAnswer.value = "";
      startTimer();
      speakWord();
    } else {
      saveHighScore();
      Get.offNamed('/score');
    }
  }

  void saveHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int highScore = prefs.getInt('highScore') ?? 0;
    if (score.value > highScore) {
      await prefs.setInt('highScore', score.value);
    }
  }
}
