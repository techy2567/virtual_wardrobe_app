import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:virtual_wardrobe_app/controllers/controller_user_details.dart';
import '../screens/privacy_screen.dart';
import '../screens/terms_policies_screen.dart';
import '../screens/help_support_screen.dart';
import '../screens/auth/signin_screen.dart';
import 'package:virtual_wardrobe_app/controllers/auth_controller.dart';
import '../screens/update_profile_screen.dart';
import '../screens/about_screen.dart';

class LayoutProfile extends StatefulWidget {
   LayoutProfile({super.key});

  @override
  State<LayoutProfile> createState() => _LayoutProfileState();
}

class _LayoutProfileState extends State<LayoutProfile> {
  File? _localProfileImage;

  bool _loadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadLocalProfileImage();
  }

  Future<void> _loadLocalProfileImage() async {
    final controllerUserDetails = Get.put(ControllerUserDetails());
    final photoUrl = controllerUserDetails.photoUrl.value;
    if (photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$photoUrl');
      if (await file.exists()) {
        setState(() {
          _localProfileImage = file;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ControllerUserDetails controllerUserDetails = Get.put(
        ControllerUserDetails());
    controllerUserDetails.fetchUserData();
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: colorScheme.primaryContainer,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo with Edit Icon
              Center(
                child: Obx(() {
                  final controllerUserDetails = Get.find<ControllerUserDetails>();
                  final photoUrl = controllerUserDetails.photoUrl.value;
                  Widget avatar;
                  if (photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
                    // Local file
                    return FutureBuilder<Directory>(
                      future: getApplicationDocumentsDirectory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          final file = File('${snapshot.data!.path}/$photoUrl');
                          if (file.existsSync()) {
                            return CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.lightBlueAccent,
                              backgroundImage: FileImage(file),
                            );
                          }
                        }
                        return const CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.lightBlueAccent,
                          child: Icon(Icons.person, size: 54, color: Colors.white),
                        );
                      },
                    );
                  } else if (photoUrl.isNotEmpty) {
                    avatar = CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.lightBlueAccent,
                      backgroundImage: NetworkImage(photoUrl),
                    );
                  } else {
                    avatar = const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.lightBlueAccent,
                      child: Icon(Icons.person, size: 54, color: Colors.white),
                    );
                  }
                  return avatar;
                }),
              ),
              const SizedBox(height: 18),
              // Name, Gender, Phone, Email
              Center(
                child: Column(
                  children: [
                    Obx(() =>
                        Text(
                          controllerUserDetails.userName.value,
                          style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(height: 4),
                    Obx(() =>
                        Text(
                          controllerUserDetails.userGender.value,
                          style: textTheme.bodyMedium?.copyWith(color: Colors
                              .grey[700]),
                        )),
                    // const SizedBox(height: 4),
                    // Obx(() => Text(
                    //   controllerUserDetails.userPhone.value.isNotEmpty
                    //       ? controllerUserDetails.userPhone.value
                    //       : '-',
                    //   style: textTheme.bodyMedium?.copyWith(
                    //       color: Colors.grey[700]),
                    // )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controllerUserDetails.userEmail.value.isNotEmpty
                          ? controllerUserDetails.userEmail.value
                          : '',
                      style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700]),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Get.to(() => const UpdateProfileScreen());
                    setState(() {
                      _localProfileImage = null;
                    });
                    await _loadLocalProfileImage();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Options Section
              Text('Account', style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text('Settings'),
              //   onTap: () {
              //     // TODO: Navigate to settings
              //   },
              //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              // ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy'),
                onTap: () {
                  Get.to(() => const PrivacyScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ListTile(
                leading: const Icon(Icons.policy),
                title: const Text('Terms & Policies'),
                onTap: () {
                  Get.to(() => const TermsPoliciesScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {
                  Get.to(() => const HelpSupportScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Get.to(() => const AboutScreen());
                },
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),

              // const SizedBox(height: 8),
              // Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                    'Logout', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text(
                              'Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    final AuthController authController = Get.find<
                        AuthController>();
                    await authController.logout();
                    Get.offAll(() => const SignInScreen());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
