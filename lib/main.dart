import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/controllers/auth_controller.dart';
import 'package:virtual_wardrobe_app/firebase_options.dart';
import 'package:virtual_wardrobe_app/screens/auth/password_reset_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signup_screen.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register AuthController globally
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color darkNavy = Color(0xFF0E163C);
  static const Color lightBeige = Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Virtual Wardrobe App',
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/login', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/verify-email', page: () => PasswordResetScreen()),
        // Add other routes if you have
      ],
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: darkNavy,
          background: lightBeige,
          surface: lightBeige,
        ),

        scaffoldBackgroundColor: lightBeige,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkNavy,
          foregroundColor: lightBeige,
        ),
      ),
      home: const Root(), // Use root widget to decide start screen
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      // While Firebase is loading
      if (authController.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // If user is logged in, show Home
      if (authController.isLoggedIn) {
        return const HomeScreen();
      }

      // Else show Welcome
      return const WelcomeScreen();
    });
  }
}
