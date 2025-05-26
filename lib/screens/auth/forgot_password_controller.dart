import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();

  // Dispose controller when the controller is closed
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void sendResetLink() {
    // TODO: Implement forgot password logic using controller value
    print('Reset Email: ${emailController.text}');
    // Example: Call an authentication service
    // AuthService.instance.sendPasswordResetEmail(emailController.text);
  }
} 