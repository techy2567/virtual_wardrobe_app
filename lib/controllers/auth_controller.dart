import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/password_reset_screen.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_screen.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // Rx Variables
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final fullNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var selectedGender = Rx<String?>(null); // Observable for selected gender
  final List<String> genderOptions = ['Male', 'Female', 'Others'];
  // Getters
  User? get user => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null && _firebaseUser.value!.emailVerified;

  void setSelectedGender(String? newValue) {
    selectedGender.value = newValue;
  }

  @override
  void onReady() {
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _handleAuthChanged);
    super.onReady();
  }

  // Updated handler for auth changes: check email verification & navigate accordingly
  void _handleAuthChanged(User? user) async {
    if (user == null) {
      Get.offAll(() => SignInScreen());
    } else {
      final currentUser = _auth.currentUser;
      try {
        await currentUser?.reload(); // Safely reload user
      } catch (e) {
        print('User reload failed: $e');
      }
      if (currentUser != null && !currentUser.emailVerified) {
        Get.offAll(() => PasswordResetScreen());
      } else {
        Get.offAll(() => HomeScreen()); // Always go to HomeScreen if verified
      }
    }
  }

  Future<void> updateUserData({
    required String name,
    String? gender,
  }) async {
    if (_firebaseUser.value == null) {
      errorMessage.value = 'No logged-in user';
      return;
    }

    final uid = _firebaseUser.value!.uid;

    try {
      isLoading(true);
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'gender': gender,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      errorMessage.value = 'Failed to update profile';
    } finally {
      isLoading(false);
    }
  }

  RxString emailError = ''.obs;

  Future<void> sendPasswordResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.isEmail) {
      emailError.value = 'Please enter a valid email';
      return;
    }

    try {
      isLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading(false);
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value = 'No user found for that email.';
        break;
      case 'invalid-email':
        errorMessage.value = 'The email address is not valid.';
        break;
      case 'too-many-requests':
        errorMessage.value = 'Too many requests. Please try again later.';
        break;
      default:
        errorMessage.value = 'An unknown error occurred. Please try again.';
    }
  }

  // Removed previous _setInitialScreen, replaced by _handleAuthChanged

  // ----------------- Auth Methods -----------------
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading(true);
      errorMessage(null);

      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification after registration
      await cred.user?.sendEmailVerification();

      // Save user data to Firestore
      final userModel = UserModel(
        id: cred.user?.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(cred.user?.uid)
          .set(userModel.toMap());

      _firebaseUser.value = cred.user; // Only update state
      // Navigation is handled by _handleAuthChanged
    } on FirebaseAuthException catch (e) {
      errorMessage(e.message ?? 'Registration failed');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void clearAuthState() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    selectedGender.value = genderOptions.first;
    errorMessage.value = '';
    isLoading.value = false;
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading(true);
      errorMessage(null);

      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser.value = cred.user; // Only update state
      // Navigation is handled by _handleAuthChanged
    } on FirebaseAuthException catch (e) {
      errorMessage(e.message ?? 'Login failed');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _firebaseUser.value = null;
    } catch (e) {
      errorMessage('Logout failed');
      rethrow;
    }
  }

  RxString successMessage = ''.obs;

  void sendResetLink() async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        errorMessage.value = 'Please enter your email';
      } else {
        await _auth.sendPasswordResetEmail(email: email);
        successMessage.value = 'Reset link sent to $email';
      }
    } catch (e) {
      errorMessage.value = 'Failed to send reset link. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void clearForgetAuthState() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    selectedGender.value = genderOptions.first;
    errorMessage.value = '';
    successMessage.value = '';
    isLoading.value = false;
  }

  // New: Resend Email Verification
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
        successMessage.value = 'Verification email sent.';
      } else {
        errorMessage.value = 'User is already verified or not logged in.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to send verification email. Please try again.';
    }
  }

  // New: Reload user to refresh email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      _firebaseUser.value = _auth.currentUser;
    } catch (e) {
      errorMessage.value = 'Failed to reload user data.';
    }
  }

  // ----------------- Helper Methods -----------------
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      errorMessage('Failed to fetch user data');
      return null;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        errorMessage.value = 'No logged-in user.';
        return;
      }
      // Re-authenticate
      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
      // Update password
      await user.updatePassword(newPassword);
      Get.snackbar('Success', 'Password changed successfully.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        errorMessage.value = 'Old password is incorrect.';
      } else if (e.code == 'weak-password') {
        errorMessage.value = 'The new password is too weak.';
      } else {
        errorMessage.value = e.message ?? 'Failed to change password.';
      }
      Get.snackbar('Error', errorMessage.value!);
    } catch (e) {
      errorMessage.value = 'Failed to change password.';
      Get.snackbar('Error', errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }
}
