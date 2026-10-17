// affairs_tab_wrapper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/affairs/screens/affairs_page.dart';
import 'package:isapp/features/affairs/controllers/affairs_controller.dart';

class AffairsTabWrapper extends StatelessWidget {
  const AffairsTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AffairsController>(
      init: AffairsController(),
      builder: (controller) {
        // Show loading while initializing
        if (controller.isInitializing.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // If user can't view, show error
        if (!controller.canView.value) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No School Access',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You need to be associated with a school to view affairs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to classroom to connect with school
                        Get.toNamed('/classroom');
                      },
                      child: const Text('Go to Classroom'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // If everything is OK, show the main screen
        return AffairsMainScreen();
      },
    );
  }
}