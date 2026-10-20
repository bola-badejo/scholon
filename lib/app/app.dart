import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/app/routes/app_routes.dart';
import 'package:isapp/app/theme/app_theme.dart';
import 'package:isapp/features/onboarding/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scholon',
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.pages,
      theme: AppTheme.light,
      home: const SplashScreen(),
      navigatorObservers: [
        if (kDebugMode)
          GetObserver((routing) => debugPrint('Route -> ${routing?.current}')),
      ],
    );
  }
}
