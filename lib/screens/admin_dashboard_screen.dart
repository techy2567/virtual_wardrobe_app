import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Obx(() {
      if (!authController.isAdmin.value) {
        // If not admin, redirect to login
        Future.microtask(() => Get.offAllNamed('/login'));
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.background,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await authController.logout();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
        backgroundColor: colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Get.toNamed('/admin-organizations'),
                child: Text('Manage Organizations'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.toNamed('/admin-tailors'),
                child: Text('Manage Tailors'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              // SizedBox(height: 24),
              // ElevatedButton(
              //   onPressed: () => Get.toNamed('/admin-ui-customization'),
              //   child: Text('UI Customization'),
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: Size(double.infinity, 50),
              //   ),
              // ),
              // SizedBox(height: 24),
              // ElevatedButton(
              //   onPressed: () => Get.toNamed('/admin-users'),
              //   child: Text('User Management'),
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: Size(double.infinity, 50),
              //   ),
              // ),
            ],
          ),
        ),
      );
    });
  }
} 