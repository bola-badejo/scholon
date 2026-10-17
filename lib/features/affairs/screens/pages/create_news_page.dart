import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';

class CreateNewsPage extends StatelessWidget {
  CreateNewsPage({super.key});

  final AffairsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create News Post',
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
          IconButton(
            onPressed: () => _saveAsDraft(),
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save as draft',
          ),
        ],
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
            
            // Images
            _buildImageSection(),
            const SizedBox(height: 20),
            
            // Tags
            _buildTagsSection(),
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
          controller: controller.newsTitleController,
          decoration: InputDecoration(
            hintText: 'Enter news title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(fontSize: 16),
          maxLines: 2,
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
            controller: controller.newsContentController,
            decoration: InputDecoration(
              hintText: 'Write your news content here...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 16),
            maxLines: 10,
            minLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Obx(() {
      final images = controller.selectedImages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (images.isNotEmpty)
                Text(
                  '${images.length} selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(images[index] as dynamic),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => controller.pickImages(),
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('Add Images'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTagsSection() {
    final tags = ['School', 'Academic', 'Sports', 'Events', 'General'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return FilterChip(
              label: Text(tag),
              selected: false,
              onSelected: (selected) {},
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.blue.shade100,
              labelStyle: const TextStyle(fontSize: 14),
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
            final isLoading = controller.isLoadingNews.value;
            return ElevatedButton(
              onPressed: isLoading ? null : () => _createNewsPost(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
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
                        Icon(Icons.publish_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Publish'),
                      ],
                    ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _createNewsPost() async {
    try {
      final newsId = await controller.createNewsPost();
      Get.back();
      Get.snackbar(
        'Success',
        'News post published successfully',
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

  void _saveAsDraft() {
    Get.snackbar(
      'Draft Saved',
      'News post saved as draft',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}