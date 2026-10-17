
import 'package:get/get.dart';

import 'package:isapp/core/widgets/not_found.dart';
import 'package:isapp/features/auth/bindings/auth_binding.dart';
import 'package:isapp/features/auth/screens/forgot_password.dart';
import 'package:isapp/features/auth/screens/sign_in.dart';
import 'package:isapp/features/auth/screens/subscription_faq.dart';
import 'package:isapp/features/auth/screens/subscription_page.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/games/screens/spelling_bee/home.dart';
import 'package:isapp/features/games/screens/sudoku.dart';
import 'package:isapp/features/games/screens/tic_tac_toe.dart';
import 'package:isapp/features/home/screens/home_page.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/controllers/home_controller.dart';
import 'package:isapp/features/kidling/controllers/progress_controller.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/screens/activity_page.dart';
import 'package:isapp/features/kidling/screens/categories_activities_page.dart';
import 'package:isapp/features/kidling/screens/kidling_homescreen.dart';
import 'package:isapp/features/kidling/screens/stats_page.dart';
import 'package:isapp/features/notes/bindings/notes_binding.dart';
import 'package:isapp/features/notes/screens/editor_view.dart';
import 'package:isapp/features/notes/screens/notes_list.dart';
import 'package:isapp/features/onboarding/screens/platform_selection_screen.dart';
import 'package:isapp/features/onboarding/screens/splash_screen.dart';
import 'package:isapp/features/onboarding/screens/sponsors_screen.dart';
import 'package:isapp/features/policy/screens/policy.dart';
import 'package:isapp/features/profile/screens/profile_page.dart';
import 'package:isapp/features/study_guide/study_guide.dart';
import 'package:isapp/features/teachly/bindings/learning_center_binding.dart';
import 'package:isapp/features/teachly/screens/learning_center_screen.dart';
import 'package:isapp/features/teachly/screens/search_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const initial = '/';

  static final List<GetPage> pages = [
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
      name: '/study-guide',
      page: () => const StudyGuideScreen(),
      binding: StudyGuideBinding(),
    ),
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
  ];
}
