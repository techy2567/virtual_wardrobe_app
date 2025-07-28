import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/models/user_model.dart';
import 'package:virtual_wardrobe_app/screens/auth/signin_screen.dart';
import 'package:virtual_wardrobe_app/screens/admin_dashboard_screen.dart';

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

  var selectedGender = 'Male'.obs; // Observable for selected gender
  final List<String> genderOptions = ['Male', 'Female', 'Others'];
  
  // Admin state
  RxBool isAdmin = false.obs;
  
  // Getters
  User? get user => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null || isAdmin.value; // Include admin state

  void setSelectedGender(String? newValue) {
    selectedGender.value = newValue??'Male';
  }

  @override
  void onReady() {
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _handleAuthChanged);
    super.onReady();
  }

  // Check if credentials are admin
  bool _isAdminCredentials(String email, String password) {
    return email == 'admin@vwapp.com' && password == '123@vwa';
  }

  // Admin-specific sign in method that bypasses Firebase completely
  Future<void> adminSignIn(String email, String password) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      // Check admin credentials without Firebase
      if (_isAdminCredentials(email, password)) {
        isAdmin.value = true;
        isLoading(false);
        Get.offAll(() => AdminDashboardScreen());
        return;
      } else {
        errorMessage.value = 'Invalid admin credentials';
        isAdmin.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Admin login failed';
      isAdmin.value = false;
    } finally {
      isLoading(false);
    }
  }

  // Updated handler for auth changes: check email verification & navigate accordingly
  void _handleAuthChanged(User? user) async {
    // If admin is logged in, don't change anything
    if (isAdmin.value) {
      return;
    }
    
    // Handle regular user auth changes
    if (user == null) {
      Get.offAll(() => SignInScreen());
    } else {
      final currentUser = _auth.currentUser;
      try {
        await currentUser?.reload(); // Safely reload user
      } catch (e) {
        print('User reload failed: $e');
      }
      Get.offAll(() => HomeScreen()); // Always go to HomeScreen
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
    required String gender,
  }) async {
    try {
      isLoading(true);
      errorMessage(null);

      // Gender must be selected (controller-level check)
      if (gender == null || gender.isEmpty) {
        errorMessage.value = 'Please select your gender';
        Get.snackbar('Error', 'Please select your gender');
        isLoading(false);
        return;
      }

      print('[DEBUG] Starting registration for email: '
          ' [32m$email [0m, name:  [32m$name [0m');

      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('[DEBUG] Firebase user created: UID =  [32m [1m [4m [7m${cred.user?.uid} [0m');

      // Ensure uid and gender are never null
      final uid = cred.user!.uid;
      final gender1 = selectedGender.value ?? "Not specified";

      // Save user data to Firestore
      final userModel = UserModel(
        id: uid,
        email: email,
        name: name,
        gender: gender1, // <-- Save gender with fallback
        createdAt: DateTime.now(),
      );

      print('[DEBUG] Attempting to write user to Firestore: '
          'uid= [32m$uid [0m, data= [34m${userModel.toMap()} [0m');

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userModel.toMap());

      print('[DEBUG] User successfully written to Firestore!');

      // Log out the user and navigate to SignInScreen after successful registration
      await _auth.signOut();
      _firebaseUser.value = null;
      Get.offAll(() => SignInScreen());
    } on FirebaseAuthException catch (e) {
      print('[ERROR] FirebaseAuthException during registration:  [31m${e.code} [0m, message:  [31m${e.message} [0m');
      errorMessage(e.message ?? 'Registration failed');
      rethrow;
    } catch (e) {
      print('[ERROR] Exception during registration:  [31m$e [0m');
      errorMessage('Registration failed: $e');
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

  Future<void> signIn(String email, String password) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      
      // Only handle Firebase Auth login for regular users
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _firebaseUser.value = credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _firebaseUser.value = null;
    isAdmin.value = false;
  }

  // Add logout method for compatibility with existing code
  Future<void> logout() async {
    await signOut();
  }

  RxString successMessage = ''.obs;

  void clearForgetAuthState() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    selectedGender.value = genderOptions.first;
    errorMessage.value = '';
    successMessage.value = '';
    isLoading.value = false;
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
