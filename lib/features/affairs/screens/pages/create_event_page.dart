import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';
import 'package:isapp/data/library/nigerian_schools_data.dart';

class CreateEventPage extends StatelessWidget {
  CreateEventPage({super.key});

  final AffairsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule Event',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildTitleField(context),
            const SizedBox(height: 20),
            
            // Description
            _buildDescriptionField(),
            const SizedBox(height: 20),
            
            // Date & Time
            _buildDateTimeSection(context),
            const SizedBox(height: 20),
            
            // Registration
            _buildRegistrationSection(),
            const SizedBox(height: 20),
            
            // Reminder
            _buildReminderSection(),
            const SizedBox(height: 20),
            
            // Location
            _buildLocationField(),
            const SizedBox(height: 30),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Title',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.eventTitleController,
          decoration: InputDecoration(
            hintText: 'Enter event title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
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

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.eventDescriptionController,
            decoration: InputDecoration(
              hintText: 'Describe your event...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 16),
            maxLines: 5,
            minLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final date = controller.selectedEventDate.value;
                return OutlinedButton.icon(
                  onPressed: () => _selectDate(),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    date != null 
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'Select Date',
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                );
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final time = controller.selectedEventTime.value;
                return OutlinedButton.icon(
                  onPressed: () => _selectTime(),
                  icon: const Icon(Icons.access_time_rounded),
                  label: Text(
                    time != null 
                        ? time.format(context)
                        : 'Select Time',
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegistrationSection() {
    return Obx(() {
      final requiresRegistration = controller.requiresRegistration.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: requiresRegistration,
                onChanged: (value) {
                  controller.requiresRegistration.value = value ?? false;
                },
                activeColor: Colors.green,
              ),
              const Text(
                'Requires Registration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (requiresRegistration) ...[
            const SizedBox(height: 12),
            const Text(
              'Maximum Attendees',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Slider(
              value: controller.maxAttendees.value.toDouble(),
              min: 10,
              max: 500,
              divisions: 49,
              label: '${controller.maxAttendees.value}',
              onChanged: (value) {
                controller.maxAttendees.value = value.toInt();
              },
              activeColor: Colors.green,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  '${controller.maxAttendees.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '500',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildReminderSection() {
    return Obx(() {
      final reminderDate = controller.selectedReminderDate.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reminder',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectReminderDate(),
                  icon: const Icon(Icons.notifications_rounded),
                  label: Text(
                    reminderDate != null 
                        ? DateFormat('MMM dd, yyyy').format(reminderDate)
                        : 'Set Reminder (Optional)',
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
              if (reminderDate != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => controller.selectedReminderDate.value = null,
                  icon: const Icon(Icons.clear_rounded, color: Colors.red),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _buildLocationField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Location',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: 'School Hall, Field, or specific location',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
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

Widget _buildCategoryField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Event Category',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: 'Select category',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: NigerianSchoolData.eventCategories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          // Store selected category
        },
      ),
    ],
  );
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
            final isLoading = controller.isLoadingEvents.value;
            return ElevatedButton(
              onPressed: isLoading ? null : () => _createEvent(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
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
                        Icon(Icons.event_available_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Schedule'),
                      ],
                    ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      controller.selectedEventDate.value = pickedDate;
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      controller.selectedEventTime.value = pickedTime;
    }
  }

  Future<void> _selectReminderDate() async {
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      controller.selectedReminderDate.value = pickedDate;
    }
  }

  Future<void> _createEvent() async {
    try {
      final eventId = await controller.createEvent();
      Get.back();
      Get.snackbar(
        'Success',
        'Event scheduled successfully',
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