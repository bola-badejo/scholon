import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../Models/courses.dart';
import '../../../../Utils/constants.dart';
import 'controllers/quiz_controller.dart';

class TestBody extends StatelessWidget {
  final List<Question> questions;

  const TestBody({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    final QuizController quizController = Get.put(QuizController(initialQuestions: questions));

    // Update controller if the widget receives new questions later
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (quizController.questions.length != questions.length ||
          !_listsEqual(quizController.questions, questions)) {
        quizController.setQuestions(questions);
      }
    });

    return Obx(() {
      // Guard against empty questions
      if (quizController.questions.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No questions available.'),
          ),
        );
      }

      final question = quizController.questions[quizController.currentIndex.value];
      final selectedIdx = quizController.selectedAnswers[quizController.currentIndex.value];

      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (quizController.currentIndex.value + 1) / quizController.questions.length,
              minHeight: 10.0,
            ),
            // Header with question count and countdown timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${quizController.currentIndex.value + 1} of ${quizController.questions.length}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: subColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/svg/clock.svg"),
                        const SizedBox(width: 5),
                        Obx(() => Text(
                              _formatTime(quizController.remainingSeconds.value),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable question area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      question.question,
                      maxLines: null,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    // Options
                    ...List.generate(question.options.length, (index) {
                      final option = question.options[index];
                      final isSelected = selectedIdx == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () => quizController.selectAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.blue.shade100 : null,
                            side: isSelected ? const BorderSide(color: Colors.blue, width: 2) : null,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${String.fromCharCode(65 + index)}. $option', // A, B, C, ...
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Fixed bottom buttons
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (quizController.currentIndex.value > 0)
                    ElevatedButton(
                      onPressed: quizController.previousQuestion,
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),
                  // Next / Submit button
                  if (quizController.currentIndex.value < quizController.questions.length - 1)
                    ElevatedButton(
                      onPressed: quizController.nextQuestion,
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: quizController.submitQuiz,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper to format seconds as MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Helper to compare two question lists
  bool _listsEqual(List<Question> a, List<Question> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}