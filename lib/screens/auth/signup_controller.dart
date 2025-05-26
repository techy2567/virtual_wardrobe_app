import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignupController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var selectedGender = Rx<String?>(null); // Observable for selected gender
  final List<String> genderOptions = ['Male', 'Female', 'Others'];

  // Dispose controllers when the controller is closed
  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void setSelectedGender(String? newValue) {
    selectedGender.value = newValue;
  }

  void signUp() {
    // TODO: Implement sign up logic using controller values
    print('Full Name: ${fullNameController.text}');
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');
    print('Confirm Password: ${confirmPasswordController.text}');
    print('Selected Gender: ${selectedGender.value}');
    // Example: Call an authentication service
    // AuthService.instance.signUp(emailController.text, passwordController.text, ...);
  }
} 