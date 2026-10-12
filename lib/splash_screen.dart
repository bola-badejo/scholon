// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:isapp/Screens/authentication/controllers.dart/authentication_controller.dart';
// import 'package:isapp/Utils/colors.dart';
// import 'package:isapp/platorm_selection_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       Get.offAll(() => const PlatformSelectionScreen());
//     });
//   }

// void _checkUserAndNavigate() async {
//   await Future.delayed(const Duration(seconds: 3));
  
//   final authService = Get.find<AuthService>();
  
//   if (authService.currentUser.value != null) {
//     final userPlatform = authService.currentUser.value!.platform;
//     switch (userPlatform) {
//       case 'istudyapp':
//         Get.offAllNamed('/istudyapp-home');
//         break;
//       case 'teachly':
//         Get.offAllNamed('/teachly-home');
//         break;
//       case 'automated_school':
//         Get.offAllNamed('/automated-school-home');
//         break;
//       case 'parents_portal':
//         Get.offAllNamed('/parents-home');
//         break;
//       default:
//         Get.offAll(() => const PlatformSelectionScreen());
//     }
//   } else {
//     // New user, show platform selection
//     Get.offAll(() => const PlatformSelectionScreen());
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bool isSmallScreen = screenHeight < 600;
//     final bool isTablet = screenWidth > 600 && screenWidth < 1200;
//     final bool isDesktop = screenWidth >= 1200;

//     return Scaffold(
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Stack(
//               fit: StackFit.expand,
//               children: [
//                 // Background Image Layer
//                 Image.asset(
//                   "assets/image.png",
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),

//                 // White Overlay with Curved Bottom
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   height: constraints.maxHeight * (isSmallScreen ? 0.65 : isTablet ? 0.60 : 0.55),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         bottomRight: Radius.circular(isDesktop ? 100 : 70),
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         bottomRight: Radius.circular(isDesktop ? 100 : 70),
//                       ),
//                       child: Image.asset(
//                         "assets/image.png",
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Content Card at Bottom
//                 Positioned(
//                   left: isDesktop ? constraints.maxWidth * 0.1 : 0,
//                   right: isDesktop ? constraints.maxWidth * 0.1 : 0,
//                   bottom: isSmallScreen ? 20 : isTablet ? 40 : 50,
//                   child: Container(
//                     constraints: BoxConstraints(
//                       maxWidth: isDesktop ? 500 : constraints.maxWidth,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: isDesktop 
//                           ? BorderRadius.circular(100)
//                           : BorderRadius.only(
//                               topLeft: Radius.circular(70),
//                             ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(isSmallScreen ? 20.0 : isTablet ? 30.0 : 40.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             "Learning Everywhere",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: isSmallScreen ? 20 : isTablet ? 28 : 32,
//                               color: Colors.black87,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           SizedBox(height: isSmallScreen ? 10 : 20),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                             child: Text(
//                               "Learn with ease..\nWhere ever you are!!",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: isSmallScreen ? 16 : isTablet ? 20 : 22,
//                                 height: 1.5,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: isSmallScreen ? 20 : 30),

//                           // Page Indicators
//                           _buildPageIndicators(isSmallScreen),

//                           SizedBox(height: isSmallScreen ? 20 : 30),

//                           // Get Started Button
//                           SizedBox(
//                             width: isDesktop ? 300 : double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Get.offAll(() => const PlatformSelectionScreen());
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: primaryColor,
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: isSmallScreen ? 12 : isTablet ? 16 : 18,
//                                   horizontal: 30,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
//                                 ),
//                                 elevation: 5,
//                                 shadowColor: primaryColor.withOpacity(0.3),
//                               ),
//                               child: Text(
//                                 "Get Started",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: isSmallScreen ? 16 : isTablet ? 20 : 22,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           // Skip option for smaller screens
//                           if (isSmallScreen) ...[
//                             SizedBox(height: 15),
//                             TextButton(
//                               onPressed: () {
//                                 Get.offAll(() => const PlatformSelectionScreen());
//                               },
//                               child: const Text(
//                                 "Skip",
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Logo/Branding at top (optional)
//                 if (!isSmallScreen)
//                   Positioned(
//                     top: 40,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Text(
//                         "ISAPP",
//                         style: TextStyle(
//                           fontSize: isTablet ? 36 : 42,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPageIndicators(bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: isSmallScreen ? 10 : 12,
//           height: isSmallScreen ? 10 : 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               width: 1.5,
//               color: primaryColor,
//             ),
//           ),
//         ),
//         SizedBox(width: isSmallScreen ? 12 : 16),
//         Container(
//           width: isSmallScreen ? 10 : 12,
//           height: isSmallScreen ? 10 : 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               width: 1.5,
//               color: primaryColor,
//             ),
//           ),
//         ),
//         SizedBox(width: isSmallScreen ? 12 : 16),
//         Container(
//           width: isSmallScreen ? 35 : 45,
//           height: isSmallScreen ? 10 : 12,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: primaryColor,
//           ),
//         ),
//       ],
//     );
//   }
// }