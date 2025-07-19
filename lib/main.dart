import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/firebase_options.dart';
import 'package:virtual_wardrobe_app/screens/auth/forgot_password_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signup_screen.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.setLanguageCode('en');
// await FirebaseAuth.instance.signOut();
  // Register AuthController globally
  Get.put(AuthController());

  runApp( MyApp());
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
        GetPage(name: '/forgot-password', page: () => ForgotPasswordScreen()),
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
      home: Root(), // Use root widget to decide start screen
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return FutureBuilder(
      future: Future.delayed( Duration(milliseconds: 300)),
      builder: (_, snapshot) {
        if (authController.isLoading.value || snapshot.connectionState != ConnectionState.done) {
          return  Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (FirebaseAuth.instance.currentUser != null) {
          return  HomeScreen();
        }
        return  SignInScreen();
      },
    );
  }
}
