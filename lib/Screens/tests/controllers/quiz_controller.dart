import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Models/courses.dart';
import '../score_page.dart';

class AttemptedQuestion {
  final Question question;
  final bool passed;
  final DateTime date;
  final int timeSpentInSeconds;

  AttemptedQuestion({
    required this.question,
    required this.passed,
    required this.date,
    required this.timeSpentInSeconds,
  });
}

class QuizController extends GetxController {
  final RxList<Question> questions = <Question>[].obs;
  var currentIndex = 0.obs;
  var selectedAnswers = <int?>[].obs;

  // Timer related
  final int totalTimeInSeconds = 3600; // 10 minutes
  var remainingSeconds = 3600.obs;
  Timer? _timer;

  QuizController({required List<Question> initialQuestions}) {
    setQuestions(initialQuestions);
  }

  void setQuestions(List<Question> newQuestions) {
    questions.assignAll(newQuestions);
    questions.shuffle(); // randomize order
    selectedAnswers.value = List.generate(questions.length, (_) => null);
    currentIndex.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        _checkWarnings();
      } else {
        timer.cancel();
        submitQuiz(); // auto‑submit when time runs out
      }
    });
  }

  void _checkWarnings() {
    final secs = remainingSeconds.value;
    if (secs == 300) {
      Get.snackbar('Time Warning', '5 minutes remaining',
          snackPosition: SnackPosition.BOTTOM);
    } else if (secs == 60) {
      Get.snackbar('Time Warning', '1 minute remaining',
          snackPosition: SnackPosition.BOTTOM);
    } else if (secs == 30) {
      Get.snackbar('Time Warning', '30 seconds remaining',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void selectAnswer(int optionIndex) {
    if (questions.isNotEmpty && currentIndex.value < questions.length) {
      selectedAnswers[currentIndex.value] = optionIndex;
      // Auto‑advance if not last question
      if (currentIndex.value < questions.length - 1) {
        nextQuestion();
      }
    }
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  void submitQuiz() {
    _timer?.cancel(); // stop the timer
    int correctCount = 0;
    final attempted = <AttemptedQuestion>[];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedIndex = selectedAnswers[i];
      final isCorrect = selectedIndex != null &&
          question.options[selectedIndex] == question.correctAnswer;

      if (isCorrect) correctCount++;
      attempted.add(AttemptedQuestion(
        question: question,
        passed: isCorrect,
        date: DateTime.now(),
        timeSpentInSeconds: totalTimeInSeconds - remainingSeconds.value, // approximate
      ));
    }

    Get.off(() => ScorePage(
          score: correctCount,
          failedQuestions: attempted.where((q) => !q.passed).toList(),
        ));
  }
}