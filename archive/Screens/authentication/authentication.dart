import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isapp/features/auth/screens/sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      Get.offAll(() => AuthenticationScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Color(0xFFFFDE21), // #FFDE21 background
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                // Lottie Animation - Fixed height
                Container(
                  height: screenHeight * (isSmallScreen ? 0.4 : 0.45),
                  width: screenWidth,
                  child: Lottie.asset(
                    'assets/education.json',
                    fit: BoxFit.cover,
                    animate: true,
                    repeat: true,
                  ),
                ),
                
                // Main Content Area
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 40,
                      vertical: isSmallScreen ? 10 : 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Top Header
                        Text(
                          "LEARN",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isSmallScreen 
                                ? screenWidth * 0.18 
                                : screenWidth * 0.15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 0.9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        // Middle Description
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 30,
                          ),
                          child: Text(
                            "Nigeria's premier learning platform\ncovering Primary to Secondary\nNERDC curriculum with mock exams\nfor JAMB, WAEC & NECO",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isSmallScreen 
                                  ? screenWidth * 0.045 
                                  : screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // Bottom Header
                        Text(
                          "CONQUER",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isSmallScreen 
                                ? screenWidth * 0.18 
                                : screenWidth * 0.15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 0.9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        // Loading Section
                        Column(
                          children: [
                            // Progress Bar
                            Container(
                              width: screenWidth * 0.6,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: screenWidth * 0.6,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Preparing your learning experience...",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: isSmallScreen ? 13 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}