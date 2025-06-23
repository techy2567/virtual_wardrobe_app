import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/controllers/controller_user_details.dart';
import 'package:virtual_wardrobe_app/controllers/auth_controller.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ControllerUserDetails controllerUserDetails = Get.find<ControllerUserDetails>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.lightBlueAccent,
                      backgroundImage: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Material(
                        color: colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            // TODO: Handle profile photo update
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(7.0),
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => TextFormField(
                    initialValue: controllerUserDetails.userName.value,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    readOnly: true,
                  )),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: controllerUserDetails.userGender.value.isNotEmpty ? controllerUserDetails.userGender.value : null,
                    items: (controllerUserDetails.genderOptions ?? ['Male', 'Female', 'Others'])
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // TODO: Handle gender change logic
                    },
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.transgender),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '+92 123 4567890',
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: 'user@email.com',
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final _oldPasswordController = TextEditingController();
                        final _newPasswordController = TextEditingController();
                        final _confirmPasswordController = TextEditingController();
                        final AuthController authController = Get.find<AuthController>();
                        final _formKey = GlobalKey<FormState>();
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text('Change Password'),
                              content: Form(
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: _oldPasswordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Old Password',
                                          prefixIcon: Icon(Icons.lock_outline),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter your old password';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _newPasswordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'New Password',
                                          prefixIcon: Icon(Icons.lock),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter a new password';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Confirm New Password',
                                          prefixIcon: Icon(Icons.lock),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Confirm your new password';
                                          }
                                          if (value != _newPasswordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                Obx(() => ElevatedButton(
                                  onPressed: authController.isLoading.value
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            await authController.changePassword(
                                              oldPassword: _oldPasswordController.text,
                                              newPassword: _newPasswordController.text,
                                            );
                                            if (authController.errorMessage.value == '' || authController.errorMessage.value == null) {
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        },
                                  child: authController.isLoading.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Change Password'),
                                )),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 