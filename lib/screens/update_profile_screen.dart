import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/controllers/controller_user_details.dart';
import 'package:virtual_wardrobe_app/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  File? _localProfileImage;
  bool _loadingImage = false;
  late TextEditingController _nameController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final controllerUserDetails = Get.find<ControllerUserDetails>();
    _nameController = TextEditingController(text: controllerUserDetails.userName.value);
    _selectedGender = controllerUserDetails.userGender.value.isNotEmpty
        ? controllerUserDetails.userGender.value
        : null;
    _loadLocalProfileImage();
  }

  Future<void> _loadLocalProfileImage() async {
    final controllerUserDetails = Get.find<ControllerUserDetails>();
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

  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = imageFile.path.split('.').last;
      final imageId = 'profile_$timestamp.$ext';
      final localPath = '${dir.path}/$imageId';
      final savedFile = await imageFile.copy(localPath);
      if (await savedFile.exists()) {
        return imageId;
      } else {
        return null;
      }
    } catch (e) {
      Get.snackbar('Image Save Error', 'Failed to save image locally.');
      return null;
    }
  }

  Future<void> _pickProfileImage() async {
    setState(() { _loadingImage = true; });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      // Optionally: check file size/type here
      final imageId = await _saveImageLocally(file);
      if (imageId != null) {
        final controllerUserDetails = Get.find<ControllerUserDetails>();
        await controllerUserDetails.updateProfile(
          name: _nameController.text,
          gender: _selectedGender ?? '',
          phone: controllerUserDetails.userPhone.value,
          photoUrlUpdate: imageId,
        );
        setState(() {
          _localProfileImage = File('${(file.parent.parent).path}/$imageId');
        });
        Get.snackbar('Success', 'Profile photo updated!');
      }
    }
    setState(() { _loadingImage = false; });
  }

  Future<void> _saveProfile() async {
    final controllerUserDetails = Get.find<ControllerUserDetails>();
    await controllerUserDetails.updateProfile(
      name: _nameController.text,
      gender: _selectedGender ?? '',
      phone: controllerUserDetails.userPhone.value,
      photoUrlUpdate: controllerUserDetails.photoUrl.value,
    );
    Get.back();
    Get.snackbar('Success', 'Profile updated!');
  }

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
                    Obx(() {
                      final controllerUserDetails = Get.find<ControllerUserDetails>();
                      final photoUrl = controllerUserDetails.photoUrl.value;
                      if (_localProfileImage != null) {
                        return CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.lightBlueAccent,
                          backgroundImage: FileImage(_localProfileImage!),
                        );
                      } else if (photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
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
                        return CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.lightBlueAccent,
                          backgroundImage: NetworkImage(photoUrl),
                        );
                      } else {
                        return const CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.lightBlueAccent,
                          child: Icon(Icons.person, size: 54, color: Colors.white),
                        );
                      }
                    }),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _loadingImage ? null : _pickProfileImage,
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: _loadingImage
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: (controllerUserDetails.genderOptions ?? ['Male', 'Female', 'Others'])
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
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
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   initialValue: '+92 123 4567890',
              //   decoration: const InputDecoration(
              //     labelText: 'Phone Number',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.phone),
              //   ),
              //   readOnly: true,
              // ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '${controllerUserDetails.userEmail.value}',
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
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
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