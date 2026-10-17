import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/kidling/controllers/home_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _loadingAnimation;

  final AudioPlayer _player = AudioPlayer();

  Timer? _appTimer;
  bool _soundPlayed = false;
  // html.AudioElement? _audioElement;

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 SplashScreen: initState called');

    // Initialize web audio element
    if (kIsWeb) {
      // _initializeWebAudio();
    }

    // Initialize animations with 8-second total duration
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Logo appears at 0-1 second
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.125, curve: Curves.easeInOut), // 0-1 sec
      ),
    );

    // Tagline appears at 1-2 seconds
    _taglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.125, 0.25, curve: Curves.easeInOut), // 1-2 sec
      ),
    );

    // Texts appear at bottom at 2-3 seconds
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.25, 0.375, curve: Curves.easeInOut), // 2-3 sec
      ),
    );

    // Loading appears at 3-4 seconds
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.375, 0.5, curve: Curves.easeInOut), // 3-4 sec
      ),
    );

    // Start animations
    _animationController.forward();

    // Listen to animation to play sound at the right moment
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.forward && !_soundPlayed) {
        // Play sound when logo animation starts (after 300ms)
        Future.delayed(const Duration(milliseconds: 300), () {
          _playSound();
          _soundPlayed = true;
        });
      }
    });

    // Start app initialization timer (8 seconds total)
    _appTimer = Timer(const Duration(seconds: 8), () {
      _initializeApp();
    });
  }

  Future<void> _playSound() async {
    try {
      await _player.setAsset('assets/chime.wav');
      await _player.play();
      debugPrint('✅ Sound played with just_audio');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  // void _initializeWebAudio() {
  //   try {
  //     _audioElement = html.AudioElement()
  //       ..src = 'assets/chime.wav'
  //       ..preload = 'auto'
  //       ..volume = 0.7;

  //     // Preload the audio
  //     _audioElement?.load();
  //     debugPrint('✅ Web audio element initialized');
  //   } catch (e) {
  //     debugPrint('❌ Error initializing web audio: $e');
  //   }
  // }
  //
  Future<void> _initializeApp() async {
    debugPrint('🎯 SplashScreen: 8 seconds passed, checking auth state');

    try {
      final authService = Get.find<AuthService>();

      if (kDebugMode) {
        // ignore: unnecessary_null_comparison
        debugPrint('🎯 SplashScreen: AuthService found: ${authService != null}');
      }

      // Check if user exists
      final user = authService.currentUser.value;
      debugPrint('🎯 SplashScreen: Current user: $user');

      if (user != null) {
        debugPrint('🎯 SplashScreen: User logged in, checking subscription...');
        final hasActiveSub = await authService.checkSubscriptionStatus(
          user.uid,
        );

        if (hasActiveSub) {
          print(
            '🎯 SplashScreen: Has active subscription, going to platform selector',
          );
          Get.offAllNamed('/platforms');
        } else {
          print(
            '🎯 SplashScreen: Subscription expired, still going to platform selector',
          );
          Get.offAllNamed('/platforms');
          // Show snackbar on next frame
          Future.delayed(Duration.zero, () {
            Get.snackbar(
              'Subscription Required',
              'Your subscription has expired. Please renew to continue.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          });
        }
      } else {
        debugPrint('🎯 SplashScreen: No user logged in, going to platform selector');
        Get.offAllNamed('/platforms');
      }
    } catch (e) {
      debugPrint('❌ SplashScreen: Error during initialization: $e');
      debugPrint('❌ SplashScreen: Going to platform selector as fallback');
      // Fallback: Go to platform selector
      Get.offAllNamed('/platforms');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _appTimer?.cancel();

    // Clean up web audio
    // if (kIsWeb && _audioElement != null) {
    //   _audioElement?.pause();
    //   _audioElement?.src = '';
    // }

    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0263B3),
      body: Stack(
        children: [
          // Main content in center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with fade-in
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoAnimation.value,
                      child: Transform.scale(
                        scale: 0.9 + (_logoAnimation.value * 0.1),
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/logo.PNG',
                    width: 200,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ Error loading logo: $error');
                      return Container(
                        width: 200,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 104, 181, 244),
                              Color.fromARGB(255, 116, 69, 245),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),

                // Animated Tagline with fade-in
                AnimatedBuilder(
                  animation: _taglineAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _taglineAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 10 - (_taglineAnimation.value * 10)),
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/tagline.PNG',
                    width: 150,
                    height: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ Error loading tagline: $error');
                      return const Text(
                        'School, turned on.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                // Animated Loading Indicator
                AnimatedBuilder(
                  animation: _loadingAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _loadingAnimation.value,
                      child: child,
                    );
                  },
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                ),
              ],
            ),
          ),

          // Texts at bottom of screen
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 - (_textAnimation.value * 20)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // First column: Product info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A product of by:',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Emirate Publishers LLC.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Vertical divider
                    Container(
                      height: 30,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white.withOpacity(0.3),
                    ),

                    // Second column: Content partnership
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content partnership:',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Multiple lines for content partnerships
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olympiad Series',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Practice Series',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'BECE Practice Guide Series',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Debug info
          if (kDebugMode)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Text(
                          'Timer: ${(_animationController.value * 8).toStringAsFixed(1)}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Platform: ${kIsWeb ? 'Web' : 'Mobile'}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sound: ${_soundPlayed ? '✅ Played' : '⏳ Waiting'}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
