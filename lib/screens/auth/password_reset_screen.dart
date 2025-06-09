import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class PasswordResetScreen extends StatelessWidget {
  PasswordResetScreen({Key? key}) : super(key: key);

  final AuthController controller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.background,
      ),
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Enter your email address to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.primary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 40),

                // Show error or success message
                if (controller.errorMessage.value?.isNotEmpty ?? false)
                  Text(
                    controller.errorMessage.value!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),

                if (controller.successMessage.value.isNotEmpty)
                  Text(
                    controller.successMessage.value,
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),

                if ((controller.errorMessage.value?.isNotEmpty ?? false) || controller.successMessage.value.isNotEmpty)
                  const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Send Reset Link'),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    controller.clearForgetAuthState();
                    Get.back();
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
