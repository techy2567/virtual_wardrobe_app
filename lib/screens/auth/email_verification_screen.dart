import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/controllers/auth_controller.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              const Text(
                'A verification link has been sent to your email address.\nPlease verify your email to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              Obx(() => authController.successMessage.value.isNotEmpty
                  ? Text(authController.successMessage.value, style: const TextStyle(color: Colors.green))
                  : authController.errorMessage.value != null && authController.errorMessage.value!.isNotEmpty
                      ? Text(authController.errorMessage.value!, style: const TextStyle(color: Colors.red))
                      : const SizedBox()),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('I have verified my email'),
                onPressed: () async {
                  await authController.reloadUser();
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Resend Verification Email'),
                onPressed: () async {
                  await authController.sendEmailVerification();
                },
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () async {
                  await authController.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 