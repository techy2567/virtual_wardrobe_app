import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/screens/auth/signup_controller.dart'; // Import the controller

// Convert back to StatelessWidget as state is managed by GetX Controller
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final SignupController controller = Get.put(SignupController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
                'Create Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: controller.fullNameController, // Link to controller
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
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
              // const SizedBox(height: 20),
              //  TextField(
              //   controller: controller.confirmPasswordController, // Link to controller
              //   decoration: InputDecoration(
              //     labelText: 'Confirm Password',
              //      prefixIcon: Icon(Icons.lock_reset_outlined, color: colorScheme.primary.withOpacity(0.6)),
              //      border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //       borderSide: BorderSide.none,
              //     ),
              //     filled: true,
              //     fillColor: colorScheme.surface,
              //   ),
              //   obscureText: true,
              // ),
              const SizedBox(height: 20), // Add spacing before gender dropdown
              // Use Obx to observe the selectedGender from the controller
              Obx(() => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.transgender, color: colorScheme.primary.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                value: controller.selectedGender.value, // Use controller's observable value
                hint: const Text('Select Gender'),
                onChanged: controller.setSelectedGender, // Use controller's method
                items: controller.genderOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.signUp, // Call controller's signUp method
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, // Button background color
                  foregroundColor: colorScheme.background, // Button text color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 