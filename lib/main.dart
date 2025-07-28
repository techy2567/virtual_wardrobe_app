import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/firebase_options.dart';
import 'package:virtual_wardrobe_app/screens/auth/forgot_password_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signup_screen.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_login_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_dashboard_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_organization_crud_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_tailor_crud_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_ui_customization_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_user_management_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/controller_weather.dart';
import 'package:virtual_wardrobe_app/controllers/ui_customization_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.setLanguageCode('en');
  // Register AuthController globally
  currentUser = await FirebaseAuth.instance.currentUser;
  Get.put(AuthController());
  Get.put(WeatherController());
  runApp(MyApp());
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      // Check if admin is logged in
      if (authController.isAdmin.value) {
        return AdminDashboardScreen();
      }
      
      // Check if regular user is logged in
      if (authController.isLoggedIn) {
        return HomeScreen();
      }
      
      return SignInScreen();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color darkNavy = Color(0xFF0E163C);
  static const Color lightBeige = Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    final uiController = Get.put(UICustomizationController());
    return Obx(() => GetMaterialApp(
      title: uiController.appTitle.value,
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/login', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordScreen()),
        GetPage(name: '/admin-login', page: () => AdminLoginScreen()),
        GetPage(name: '/admin-dashboard', page: () => AdminDashboardScreen()),
        GetPage(name: '/admin-organizations', page: () => AdminOrganizationCrudScreen()),
        GetPage(name: '/admin-tailors', page: () => AdminTailorCrudScreen()),
        GetPage(name: '/admin-ui-customization', page: () => AdminUICustomizationScreen()),
        GetPage(name: '/admin-users', page: () => AdminUserManagementScreen()),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: uiController.primaryColor.value,
          background: uiController.backgroundColor.value,
          surface: uiController.surfaceColor.value,
        ),
        scaffoldBackgroundColor: uiController.backgroundColor.value,
        appBarTheme: AppBarTheme(
          backgroundColor: uiController.primaryColor.value,
          foregroundColor: uiController.backgroundColor.value,
        ),
      ),
      home: Root(),
    ));
  }
}
