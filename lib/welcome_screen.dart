import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:virtual_wardrobe_app/screens/auth/signup_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the color scheme defined in main.dart
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Your Virtual Wardrobe'),
        // The background color is set in the main.dart theme, foreground color set too
      ),
      body: Center(
        // Center the column in the body
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Your Virtual Wardrobe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // Use primary color (dark navy) for text
              ),
            ),
            const SizedBox(height: 40), // Add spacing between text and buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to SignUpScreen using GetX
                Get.to(() => const SignUpScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Button background color (dark navy)
                foregroundColor: colorScheme.background, // Button text color (light beige)
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20), // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to SignInScreen using GetX
                Get.to(() => const SignInScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Button background color (dark navy)
                foregroundColor: colorScheme.background, // Button text color (light beige)
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
} 