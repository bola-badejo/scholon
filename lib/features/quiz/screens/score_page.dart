import 'package:flutter/material.dart';

import 'package:isapp/core/constants/app_constants.dart';
import 'package:isapp/features/quiz/controllers/quiz_controller.dart';

class ScorePage extends StatelessWidget {
  final int score;
  final List<AttemptedQuestion> failedQuestions;

  ScorePage({required this.score, required this.failedQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Score'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Image.asset('assets/score.gif',
                    ),
                  ),
                  Text(
                    '$score',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 100.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'you scored $score of 10',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Attempted Questions (Failed):',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: failedQuestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(failedQuestions[index].question.question,
                        style: const TextStyle(fontSize: 12.0),),
                    subtitle: Text('Your Answer: ${failedQuestions[index].passed ? 'Correct' : 'Incorrect'}',
                      style: const TextStyle(fontSize: 12.0),),
                    trailing: Text(failedQuestions[index].question.correctAnswer,
                      style: const TextStyle(fontSize: 12.0),),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}