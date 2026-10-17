import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/teachly/controllers/board_controller.dart';
import 'package:isapp/features/teachly/models/question.dart';
import 'package:isapp/features/teachly/models/teacher_class.dart';

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final BoardController controller = Get.find<BoardController>();
  final _formKey = GlobalKey<FormState>();

  final Rx<DateTime?> selectedDueDate = Rx(null);
  final RxInt passingScore = RxInt(50);
  final RxBool shuffleQuestions = RxBool(true);
  final RxBool shuffleOptions = RxBool(true);
  final RxBool showResults = RxBool(true);
  final RxBool allowRetake = RxBool(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
        actions: [
          IconButton(
            onPressed: _createTest,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Selection
              _buildClassSelector(),
              const SizedBox(height: 20),

              // Test Details
              TextFormField(
                controller: controller.contentTitleController,
                decoration: const InputDecoration(
                  labelText: 'Test Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter test title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.contentDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.contentDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Please enter valid duration';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDueDate,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Obx(
                                () => Text(
                                  selectedDueDate.value == null
                                      ? 'Due Date (Optional)'
                                      : DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(selectedDueDate.value!),
                                  style: TextStyle(
                                    color: selectedDueDate.value == null
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Test Settings
              _buildTestSettings(),
              const SizedBox(height: 30),

              // Questions Section
              _buildQuestionsSection(),
              const SizedBox(height: 30),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _createTest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Test'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    final classes = controller.teacherClasses;
    final selectedClass = controller.selectedClass.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Class',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TeacherClass>(
                value: selectedClass,
                isExpanded: true,
                hint: const Text('Choose a class'),
                items: classes.map((classItem) {
                  return DropdownMenuItem<TeacherClass>(
                    value: classItem,
                    child: Text(classItem.title),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedClass.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSettingSwitch(
          title: 'Shuffle Questions',
          subtitle: 'Questions will appear in random order',
          value: shuffleQuestions.value,
          onChanged: (value) => shuffleQuestions.value = value!,
        ),
        _buildSettingSwitch(
          title: 'Shuffle Options',
          subtitle: 'Multiple choice options will be shuffled',
          value: shuffleOptions.value,
          onChanged: (value) => shuffleOptions.value = value!,
        ),
        _buildSettingSwitch(
          title: 'Show Results',
          subtitle: 'Students can see their score after submission',
          value: showResults.value,
          onChanged: (value) => showResults.value = value!,
        ),
        _buildSettingSwitch(
          title: 'Allow Retake',
          subtitle: 'Students can retake the test',
          value: allowRetake.value,
          onChanged: (value) => allowRetake.value = value!,
        ),
      ],
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Question'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Obx(() {
          final questions = controller.currentQuestions;

          if (questions.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No questions added yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add questions to create your test',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _QuestionCard(
                question: question,
                index: index,
                onEdit: () => _editQuestion(index),
                onDelete: () => _deleteQuestion(index),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      selectedDueDate.value = selected;
    }
  }

  void _addQuestion() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _AddQuestionForm(),
        ),
      ),
    );
  }

  void _editQuestion(int index) {
    final question = controller.currentQuestions[index];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _EditQuestionForm(question: question, index: index),
        ),
      ),
    );
  }

  void _deleteQuestion(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.currentQuestions.removeAt(index);
              Get.back();
              Get.snackbar(
                'Deleted',
                'Question removed',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _createTest() async {
    if (_formKey.currentState!.validate()) {
      final selectedClass = controller.selectedClass.value;
      if (selectedClass == null) {
        Get.snackbar('Error', 'Please select a class');
        return;
      }

      if (controller.currentQuestions.isEmpty) {
        Get.snackbar('Error', 'Please add at least one question');
        return;
      }

      final totalPoints = controller.currentQuestions.fold(
        0,
        (sum, q) => sum + q.points,
      );

      await controller.createTest(
        classId: selectedClass.id,
        title: controller.contentTitleController.text,
        description: controller.contentDescriptionController.text,
        duration: int.parse(controller.contentDurationController.text),
        passingScore: (totalPoints * (passingScore.value / 100)).toInt(),
        questions: controller.currentQuestions.toList(),
        isExam: false,
      );

      // Clear form
      controller.contentTitleController.clear();
      controller.contentDescriptionController.clear();
      controller.contentDurationController.text = '60';
      controller.currentQuestions.clear();

      Get.back();
    }
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      color: Colors.grey,
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(
                      question.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getQuestionTypeLabel(question.type),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getQuestionTypeColor(question.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${question.points} points',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (question.options.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${question.options.length} options',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'true_false':
        return Colors.green;
      case 'short_answer':
        return Colors.orange;
      case 'essay':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'true_false':
        return 'True/False';
      case 'short_answer':
        return 'Short Answer';
      case 'essay':
        return 'Essay';
      default:
        return 'Question';
    }
  }
}

class _AddQuestionForm extends StatefulWidget {
  const _AddQuestionForm();

  @override
  State<_AddQuestionForm> createState() => __AddQuestionFormState();
}

class __AddQuestionFormState extends State<_AddQuestionForm> {
  final BoardController controller = Get.find<BoardController>();
  final RxString questionType = RxString('multiple_choice');

  @override
  void initState() {
    super.initState();
    // Initialize with 4 option controllers for multiple choice
    for (int i = 0; i < 4; i++) {
      controller.optionControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Question',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Question Type
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Question Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _QuestionTypeChip(
                    type: 'multiple_choice',
                    label: 'Multiple Choice',
                    selected: questionType.value == 'multiple_choice',
                    onSelected: (_) => questionType.value = 'multiple_choice',
                  ),
                  _QuestionTypeChip(
                    type: 'true_false',
                    label: 'True/False',
                    selected: questionType.value == 'true_false',
                    onSelected: (_) => questionType.value = 'true_false',
                  ),
                  _QuestionTypeChip(
                    type: 'short_answer',
                    label: 'Short Answer',
                    selected: questionType.value == 'short_answer',
                    onSelected: (_) => questionType.value = 'short_answer',
                  ),
                  _QuestionTypeChip(
                    type: 'essay',
                    label: 'Essay',
                    selected: questionType.value == 'essay',
                    onSelected: (_) => questionType.value = 'essay',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Text
          TextField(
            controller: controller.questionTextController,
            decoration: const InputDecoration(
              labelText: 'Question Text',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Options (for multiple choice)
          Obx(() {
            if (questionType.value == 'multiple_choice') {
              return _buildMultipleChoiceOptions();
            } else if (questionType.value == 'true_false') {
              return _buildTrueFalseOptions();
            } else {
              return _buildTextAnswerField();
            }
          }),
          const SizedBox(height: 20),

          // Points
          TextField(
            controller: controller.questionPointsController,
            decoration: const InputDecoration(
              labelText: 'Points',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Question'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== FIXED _buildMultipleChoiceOptions METHOD ==========

  Widget _buildMultipleChoiceOptions() {
    final controller = Get.find<BoardController>(); // Get the BoardController

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Options (Select the correct one)'),
        const SizedBox(height: 12),

        ...controller.optionControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final optionController = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Obx(
                  () => Radio(
                    value: index,
                    groupValue: controller.selectedCorrectOption.value,
                    onChanged: (value) {
                      controller.selectedCorrectOption.value = value!;
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:
                        optionController, // Use optionController, not controller
                    decoration: InputDecoration(
                      hintText: 'Option ${String.fromCharCode(65 + index)}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                if (controller.optionControllers.length > 2)
                  IconButton(
                    onPressed: () => controller.removeOption(index),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }).toList(),

        TextButton.icon(
          onPressed: () => controller.addOption(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Option'),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select correct answer'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('True'),
                  value: 0,
                  groupValue: controller.selectedCorrectOption.value,
                  onChanged: (value) {
                    controller.selectedCorrectOption.value = value!;
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => RadioListTile(
                  title: const Text('False'),
                  value: 1,
                  groupValue: controller.selectedCorrectOption.value,
                  onChanged: (value) {
                    controller.selectedCorrectOption.value = value!;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextAnswerField() {
    return TextField(
      controller: controller.contentDescriptionController,
      decoration: const InputDecoration(
        labelText: 'Model Answer (for reference)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  void _saveQuestion() {
    if (controller.questionTextController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter question text');
      return;
    }

    if (questionType.value == 'multiple_choice' &&
        controller.optionControllers.any((c) => c.text.isEmpty)) {
      Get.snackbar('Error', 'Please fill all options');
      return;
    }

    controller.addQuestion();
    Get.back();
  }
}

class _EditQuestionForm extends StatefulWidget {
  final Question question;
  final int index;

  const _EditQuestionForm({required this.question, required this.index});

  @override
  State<_EditQuestionForm> createState() => __EditQuestionFormState();
}

class __EditQuestionFormState extends State<_EditQuestionForm> {
  final BoardController controller = Get.find<BoardController>();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing question data
    controller.questionTextController.text = widget.question.text;
    controller.questionPointsController.text = widget.question.points
        .toString();
    controller.selectedQuestionType.value = widget.question.type;

    if (widget.question.type == 'multiple_choice') {
      for (final option in widget.question.options) {
        controller.optionControllers.add(TextEditingController(text: option));
      }
      if (widget.question.correctOptions.isNotEmpty) {
        controller.selectedCorrectOption.value =
            widget.question.correctOptions.first;
      }
    } else if (widget.question.type == 'true_false') {
      controller.selectedCorrectOption.value =
          widget.question.correctAnswer == 'true' ? 0 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AddQuestionForm();
  }

  void _updateQuestion() {
    // Similar to _saveQuestion but updates existing question
    final updatedQuestion = Question(
      id: widget.question.id,
      text: controller.questionTextController.text,
      type: controller.selectedQuestionType.value,
      options: controller.optionControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .toList(),
      correctOptions: controller.selectedQuestionType.value == 'multiple_choice'
          ? [controller.selectedCorrectOption.value]
          : [],
      correctAnswer: controller.selectedQuestionType.value == 'true_false'
          ? (controller.selectedCorrectOption.value == 0 ? 'true' : 'false')
          : null,
      points: int.tryParse(controller.questionPointsController.text) ?? 1,
    );

    controller.currentQuestions[widget.index] = updatedQuestion;
    Get.back();
    Get.snackbar('Updated', 'Question updated successfully');
  }
}

class _QuestionTypeChip extends StatelessWidget {
  final String type;
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _QuestionTypeChip({
    required this.type,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getQuestionTypeColor(type);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : color,
        fontWeight: FontWeight.w500,
      ),
      avatar: selected
          ? Icon(_getQuestionTypeIcon(type), size: 16, color: Colors.white)
          : Icon(_getQuestionTypeIcon(type), size: 16, color: color),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'true_false':
        return Colors.green;
      case 'short_answer':
        return Colors.orange;
      case 'essay':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.checklist_rounded;
      case 'true_false':
        return Icons.swap_horiz_rounded;
      case 'short_answer':
        return Icons.short_text_rounded;
      case 'essay':
        return Icons.subject_rounded;
      default:
        return Icons.question_mark_rounded;
    }
  }
}
