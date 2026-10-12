import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/controllers/home_controller.dart';
import 'package:isapp/Kidling/controllers/progress_controller.dart';
import 'package:isapp/Kidling/data/data.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/screens/activity_page.dart';
import 'package:isapp/Kidling/screens/categories_activities_page.dart';
import 'package:isapp/Kidling/screens/kidling_homescreen.dart';
import 'package:isapp/Kidling/screens/stats_page.dart';
import 'package:isapp/Learning/study_planner_screen.dart';
import 'package:isapp/Notifications/notifications_controller.dart';
import 'package:isapp/Notifications/notifications_service.dart';
import 'package:isapp/Screens/Profile/profile_page.dart';
import 'package:isapp/Screens/affairs/affairs_binding.dart';
import 'package:isapp/Screens/affairs/controller/affairs_controller.dart';
import 'package:isapp/Screens/affairs/controller/affairs_public_controller.dart';
import 'package:isapp/Screens/authentication/auth_binding.dart';
import 'package:isapp/Screens/authentication/controllers/auth_controller.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Screens/authentication/controllers/subscription_page.dart.dart';
import 'package:isapp/Screens/authentication/forgot_password.dart';
import 'package:isapp/Screens/authentication/sign_in.dart';
import 'package:isapp/Screens/authentication/subscription_faq.dart';
import 'package:isapp/Screens/faculty/faculty.dart';
import 'package:isapp/Screens/games/spelling_bee/home.dart';
import 'package:isapp/Screens/games/sudoku.dart';
import 'package:isapp/Screens/games/tic_tac_toe.dart';
import 'package:isapp/Screens/home/connect.dart';
import 'package:isapp/Screens/home/teachly_pages/teacher_page.dart';
import 'package:isapp/Screens/not_found.dart';
import 'package:isapp/Screens/notes/bindings/notes_binding.dart';
import 'package:isapp/Screens/notes/views/editor_view.dart';
import 'package:isapp/Screens/notes/views/notes_list.dart';
import 'package:isapp/Screens/parents/controller/parent_Controller.dart';
import 'package:isapp/Screens/policy/policy.dart';
import 'package:isapp/TeachlyLearning/data/repo/course_repo.dart';
import 'package:isapp/TeachlyLearning/data/repo/teacher_repo.dart';
import 'package:isapp/TeachlyLearning/learning_center_binding.dart';
import 'package:isapp/TeachlyLearning/learning_center_screen.dart';
import 'package:isapp/TeachlyLearning/search_screen.dart';
import 'package:isapp/TeachlyLearning/services/storage_services.dart';
import 'package:isapp/Utils/connectivity_Service.dart';
import 'package:isapp/platorm_selection_screen.dart';
import 'package:isapp/screens/home/home_page.dart';
import 'package:isapp/sponsors.dart';

import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // GoogleFonts.config.allowRuntimeFetching = true;
  print('🟢 Step 1: Binding initialized');

  try {
    print('🚀 Initializing Firebase...');
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyC4URS-MQzKQlkXBGAXnkgbVx39R5tsILo',
        appId: '1:118311628878:web:73a65e05b0d9f32c97531f',
        messagingSenderId: '118311628878',
        projectId: 'istudyapp-de440',
        authDomain: 'istudyapp-de440.firebaseapp.com',
        storageBucket: 'istudyapp-de440.firebasestorage.app',
        measurementId: 'G-PKSMZ354EP',
      ),
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('❌ Error type: ${e.runtimeType}');

    if (e is FirebaseException) {
      print('❌ Firebase error code: ${e.code}');
      print('❌ Firebase error message: ${e.message}');
    }

    // Show error screen instead of crashing
    runApp(const FirebaseErrorApp());
    return;
  }
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  try {
    await SeedActivities.seedAllActivities().timeout(Duration(seconds: 5000));
  } catch (e) {
    print('❌ SeedActivities failed: $e');
  }

  Get.put(ConnectivityService(), permanent: true);

  // Initialize GetX controllers BEFORE running the app
  Get.put(AuthService(), permanent: true);
  Get.put(AuthenticationController(), permanent: true);
  Get.put(FacultyController(), permanent: true);
  Get.put(AffairsBinding(), permanent: true);
  Get.put(ConnectController(), permanent: true);
  Get.put(AffairsController(), permanent: true);
  Get.put(AffairsPublicController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(BoardController(), permanent: true);
  Get.put(ParentController(), permanent: true);
  Get.put(AudioAssistantService(), permanent: true);
  Get.put(ActivityController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(ProgressController(), permanent: true);
  Get.put(AudioAssistantService(), permanent: true);

  await initializeServices();

  runApp(const MyApp());

  final notificationService = NotificationService();
  await notificationService.initialize();
}

Future<void> initializeServices() async {
  try {
    await Get.putAsync<StorageService>(() async {
      final service = StorageService();
      await service.onInit().timeout(const Duration(seconds: 5));
      return service;
    }, permanent: true);
  } catch (e) {
    print('❌ StorageService init failed: $e');
    // Continue anyway
  }
  
  Get.put(CourseRepository(), permanent: true);
  Get.put(TeacherRepository(), permanent: true);
  print('All services initialized successfully');
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Firebase Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please check your Firebase web configuration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (kIsWeb) {
                      // html.window.location.reload();
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(
          name: '/platforms',
          page: () => const PlatformSelectionScreen(),
        ),
        GetPage(
          name: '/auth',
          page: () => const AuthenticationScreen(),
          binding: AuthBinding(),
        ),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(name: '/activities', page: () => const StudyPlannerScreen()),
        GetPage(
          name: '/connect',
          page: () => const ConnectScreen(),
          binding: ConnectBinding(),
        ),
        GetPage(
          name: '/learning',
          page: () => const LearningCenterScreen(),
          binding: LearningCenterBinding(),
        ),
        GetPage(
          name: '/subscription-plans',
          page: () => SubscriptionPlansPage(),
        ),
        GetPage(name: '/search', page: () => SearchScreenCourses()),
        GetPage(name: '/spelling-bee', page: () => SpellingHome()),

        GetPage(name: '/sponsors', page: () => SponsorsScreen()),
        GetPage(name: '/tic-tac-toe', page: () => GameScreen()),
        GetPage(name: '/sudoku', page: () => SudokuGame()),
        GetPage(
          name: '/account-settings',
          page: () => UniversalProfileScreen(),
        ),
        GetPage(name: '/privacy-policy', page: () => PrivacyPolicyPage()),
        GetPage(name: '/score-sheet', page: () => UniversalProfileScreen()),
        GetPage(
          name: '/notepad',
          page: () => const NotesListView(),
          binding: NotesBinding(),
        ),
        GetPage(name: '/not-found', page: () => NotFoundPage()),
        GetPage(
          name: '/notes',
          page: () => const NotesListView(),
          binding: NotesBinding(),
        ),
        GetPage(
          name: '/editor',
          page: () => const EditorView(),
          binding: EditorBinding(),
        ),
        GetPage(
          name: '/subscription-faq',
          page: () => const SubscriptionFAQPage(),
        ),
        GetPage(
          name: '/kidling-home',
          page: () => KidlingHomePage(),
          binding: BindingsBuilder(() {
            Get.put(HomeController(), permanent: true);
            Get.put(ActivityController(), permanent: true);
            Get.put(ProgressController(), permanent: true);
            Get.put(AudioAssistantService(), permanent: true);
          }),
        ),
        GetPage(
          name: '/category/:type',
          page: () {
            final type = Get.parameters['type'] ?? 'phonics';
            return CategoryActivitiesPage(categoryType: type);
          },
        ),
        GetPage(
          name: '/stats',
          page: () => const StatsPage(),
          binding: BindingsBuilder(() {
            Get.put(ProgressController());
          }),
        ),
        GetPage(
          name: '/activity',
          page: () {
            final activity = Get.arguments as Activity;
            return ActivityPage(activity: activity);
          },
        ),
      ],
      theme: ThemeData(
        primarySwatch: Colors.amber,
        // fontFamily: GoogleFonts.notoSansAdlam().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
      // Remove initialBinding since we're using Get.put
      home: const SplashScreen(),
      // Add navigation observer for debugging
      navigatorObservers: [
        GetObserver((routing) {
          print('🔗 Route changed to: ${routing?.current}');
        }),
      ],
    );
  }
}

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
    print('🎯 SplashScreen: initState called');

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
      print('✅ Sound played with just_audio');
    } catch (e) {
      print('❌ Error: $e');
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
  //     print('✅ Web audio element initialized');
  //   } catch (e) {
  //     print('❌ Error initializing web audio: $e');
  //   }
  // }
  //
  Future<void> _initializeApp() async {
    print('🎯 SplashScreen: 8 seconds passed, checking auth state');

    try {
      final authService = Get.find<AuthService>();

      if (kDebugMode) {
        // ignore: unnecessary_null_comparison
        print('🎯 SplashScreen: AuthService found: ${authService != null}');
      }

      // Check if user exists
      final user = authService.currentUser.value;
      print('🎯 SplashScreen: Current user: $user');

      if (user != null) {
        print('🎯 SplashScreen: User logged in, checking subscription...');
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
        print('🎯 SplashScreen: No user logged in, going to platform selector');
        Get.offAllNamed('/platforms');
      }
    } catch (e) {
      print('❌ SplashScreen: Error during initialization: $e');
      print('❌ SplashScreen: Going to platform selector as fallback');
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
                      print('❌ Error loading logo: $error');
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
                      print('❌ Error loading tagline: $error');
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
