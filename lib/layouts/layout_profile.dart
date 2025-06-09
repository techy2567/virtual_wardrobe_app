import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/controllers/controller_user_details.dart';

class LayoutProfile extends StatelessWidget {
  const LayoutProfile({super.key});

  @override
  Widget build(BuildContext context) {
    ControllerUserDetails controllerUserDetails = Get.put(
        ControllerUserDetails());
    controllerUserDetails.fetchUserData();
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Photo with Edit Icon
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.lightBlueAccent,
                    backgroundImage: NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            Obx(() {
              return TextFormField(
                // initialValue: '${controllerUserDetails.userName.value}',
                readOnly: true, // Make it read-only
                controller: TextEditingController(
                    text: controllerUserDetails.userName.value),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Gender Field
            Obx(() {
              return TextFormField(
                readOnly: true, // Make it read-only
                controller: TextEditingController(
                    text: controllerUserDetails.userGender.value),
                decoration: const InputDecoration(
                  labelText: 'Gender',

                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.transgender),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Phone Number Field
            TextFormField(
              initialValue: '+92 123 4567890',
              keyboardType: TextInputType.phone,
              readOnly: true, // Make it read-only
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 24),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Handle profile update logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
