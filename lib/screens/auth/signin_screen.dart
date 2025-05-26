import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/screens/auth/forgot_password_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_controller.dart'; // Import the controller
import 'package:virtual_wardrobe_app/screens/home_screen.dart'; // Import HomeScreen

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final SigninController controller = Get.put(SigninController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.background,
      ),
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: controller.emailController, // Link to controller
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.passwordController, // Link to controller
                decoration: InputDecoration(
                  labelText: 'Password',
                   prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary.withOpacity(0.6)),
                   border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                   // Call controller's signIn method (optional: move navigation inside controller)
                   controller.signIn();
                   // Navigate to HomeScreen and remove previous routes
                   Get.offAll(() => const HomeScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, // Button background color
                  foregroundColor: colorScheme.background, // Button text color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Sign In'),
              ),
               const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to ForgotPasswordScreen using GetX
                   Get.to(() => const ForgotPasswordScreen());
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: colorScheme.primary.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 