import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Screens/tests/test_body.dart';

import '../../../../Models/courses.dart';
import '../../../../Utils/constants.dart';
import '../../../../Widgets/bottom_nav_bar.dart';
import 'controllers/quiz_controller.dart';

class TestPage extends StatelessWidget {
  final List<Question> question;
  final List<Test> test;
  final int index;

  const TestPage({
    super.key,
    required this.question,
    required this.index,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.defaultDialog(
              title: 'Leave Quiz?',
              middleText: 'Are you sure you want to leave? Your progress will be lost.',
              textConfirm: 'Leave',
              textCancel: 'Continue',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.delete<QuizController>();
                Get.back();
                Get.back();
              },
              onCancel: () => Get.back(),
            );
          },
        ),
        title: Text(
          test[index].code,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ),
      body: TestBody(questions: question),
      bottomNavigationBar: const myBottomNavigationBar(),
    );
  }
}