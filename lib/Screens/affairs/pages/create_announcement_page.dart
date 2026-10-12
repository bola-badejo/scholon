import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Screens/affairs/controller/affairs_controller.dart';

class CreateAnnouncementPage extends StatelessWidget {
  CreateAnnouncementPage({super.key});

  final AffairsController controller = Get.find();
  final List<String> targetOptions = [
  'All Users',
  'All Students',
  'Basic 1-3',
  'Basic 4-6',
  'Basic 7-9',
  'Senior Secondary',
  'SSS 1',
  'SSS 2',
  'SSS 3',
  'All Parents',
  'All Teachers',
  'Academic Staff',
  'Non-Academic Staff',
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Announcement',
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
            _buildTitleField(),
            const SizedBox(height: 20),
            
            // Content
            _buildContentField(),
            const SizedBox(height: 20),
            
            // Urgent Toggle
            _buildUrgentToggle(),
            const SizedBox(height: 20),
            
            // Target Audience
            _buildTargetSection(),
            const SizedBox(height: 30),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.announcementTitleController,
          decoration: InputDecoration(
            hintText: 'Enter announcement title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.purple, width: 2),
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

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.announcementContentController,
            decoration: InputDecoration(
              hintText: 'Write your announcement here...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 16),
            maxLines: 8,
            minLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentToggle() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(
                value: controller.isUrgentAnnouncement.value,
                onChanged: (value) {
                  controller.isUrgentAnnouncement.value = value;
                },
                activeColor: Colors.red,
                activeTrackColor: Colors.red.shade200,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mark as Urgent',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              if (controller.isUrgentAnnouncement.value)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_rounded, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'High Priority',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (controller.isUrgentAnnouncement.value)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                'Urgent announcements will be highlighted and sent as priority notifications',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTargetSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Target Audience',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(
        'Select who should receive this announcement',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: targetOptions.map((target) {
          final isSelected = controller.announcementTargets.contains(target);
          
          return FilterChip(
            label: Text(target),
            selected: isSelected,
            onSelected: (selected) {
              if (target == 'All Users') {
                // Clear all and select only "All Users"
                controller.announcementTargets.clear();
                controller.announcementTargets.add('All Users');
              } else {
                // Remove "All Users" if selecting specific targets
                controller.announcementTargets.remove('All Users');
                
                if (selected) {
                  controller.announcementTargets.add(target);
                } else {
                  controller.announcementTargets.remove(target);
                }
                
                // If no specific targets selected, default to "All Users"
                if (controller.announcementTargets.isEmpty) {
                  controller.announcementTargets.add('All Users');
                }
              }
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: Colors.purple.shade100,
            labelStyle: TextStyle(
              color: isSelected ? Colors.purple : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }).toList(),
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
            final isLoading = controller.isLoadingAnnouncements.value;
            final hasTitle = controller.announcementTitleController.text.isNotEmpty;
            final hasContent = controller.announcementContentController.text.isNotEmpty;
            
            return ElevatedButton(
              onPressed: (isLoading || !hasTitle || !hasContent) 
                  ? null 
                  : () => _createAnnouncement(),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isUrgentAnnouncement.value 
                    ? Colors.red.shade800 
                    : Colors.purple.shade800,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.isUrgentAnnouncement.value 
                              ? Icons.warning_rounded 
                              : Icons.announcement_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.isUrgentAnnouncement.value 
                              ? 'Post Urgent' 
                              : 'Post',
                        ),
                      ],
                    ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _createAnnouncement() async {
    try {
      final announcementId = await controller.createAnnouncement();
      Get.back();
      Get.snackbar(
        'Success',
        'Announcement posted successfully',
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