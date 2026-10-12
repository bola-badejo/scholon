import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isapp/Screens/affairs/controller/affairs_controller.dart';

class CreatePollPage extends StatelessWidget {
  CreatePollPage({super.key});

  final AffairsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Poll',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          GetBuilder<AffairsController>(
            builder: (controller) {
              if (controller.pollOptionControllers.length >= 2) {
                return IconButton(
                  onPressed: () => _clearAll(),
                  icon: const Icon(Icons.clear_all_rounded),
                  tooltip: 'Clear all',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            _buildQuestionField(),
            const SizedBox(height: 20),

            // Options
            _buildOptionsSection(),
            const SizedBox(height: 20),

            // Settings
            _buildSettingsSection(),
            const SizedBox(height: 20),

            // End Date
            _buildEndDateSection(),
            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Poll Question',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.pollQuestionController,
          decoration: InputDecoration(
            hintText: 'What would you like to ask?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
  return GetBuilder<AffairsController>(
    builder: (controller) {
      final options = controller.pollOptionControllers;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${options.length}/10',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          ...List.generate(options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: options[index],
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (options.length > 2) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => controller.removePollOption(index),
                      icon: const Icon(Icons.remove_circle_rounded, color: Colors.red),
                    ),
                  ],
                ],
              ),
            );
          }),
          
          if (options.length < 10)
            OutlinedButton.icon(
              onPressed: () => controller.addPollOption(),
              icon: const Icon(Icons.add_circle_rounded),
              label: const Text('Add Option'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ), 
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
            ),
        ],
      );
    },
  );
}

  Widget _buildSettingsSection() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: controller.isMultiChoicePoll.value,
                onChanged: (value) {
                  controller.isMultiChoicePoll.value = value ?? false;
                },
                activeColor: Colors.orange,
              ),
              const Expanded(
                child: Text(
                  'Allow multiple choices',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildEndDateSection() {
    return Obx(() {
      final endDate = controller.pollEndDate.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poll End Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectEndDate(),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    endDate != null
                        ? DateFormat('MMM dd, yyyy').format(endDate)
                        : 'Select End Date (Optional)',
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (endDate != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => controller.pollEndDate.value = null,
                  icon: const Icon(Icons.clear_rounded, color: Colors.red),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final isLoading = controller.isLoadingPolls.value;
            final hasEnoughOptions =
                controller.pollOptionControllers.length >= 2;
            final hasQuestion =
                controller.pollQuestionController.text.isNotEmpty;

            return ElevatedButton(
              onPressed: (isLoading || !hasEnoughOptions || !hasQuestion)
                  ? null
                  : () => _createPoll(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.poll_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Create Poll'),
                      ],
                    ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.pollEndDate.value = pickedDate;
    }
  }

  void _clearAll() {
  Get.dialog(
    AlertDialog(
      title: const Text('Clear All'),
      content: const Text('Are you sure you want to clear all options?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            // Clear all poll option controllers
            for (var ctrl in controller.pollOptionControllers) {
              ctrl.dispose();
            }
            controller.pollOptionControllers.clear();
            controller.pollQuestionController.clear();
            // If using the Rx property approach:
            // controller.pollOptionCount.value = 0;
            controller.update(); // Force UI update
          },
          child: const Text(
            'Clear All',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _createPoll() async {
    try {
      final pollId = await controller.createPoll();
      Get.back();
      Get.snackbar(
        'Success',
        'Poll created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
