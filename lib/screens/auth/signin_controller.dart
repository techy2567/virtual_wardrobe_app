import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SigninController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Dispose controllers when the controller is closed
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void signIn() {
    // TODO: Implement sign in logic using controller values
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');
    // Example: Call an authentication service
    // AuthService.instance.signIn(emailController.text, passwordController.text);
  }
} 