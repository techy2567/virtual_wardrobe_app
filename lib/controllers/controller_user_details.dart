import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ControllerUserDetails extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  RxString selectedGender = ''.obs;
  // Observable user data
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userGender = ''.obs;
  var userPhone = ''.obs;
  var photoUrl = ''.obs;

  // Fetch user data
  Future<void> fetchUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No logged-in user');

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        userName.value = data['name'] ?? '';
        userEmail.value = data['email'] ?? '';
        userGender.value = data['gender'] ?? '';
        userPhone.value = data['phone'] ?? '';
        photoUrl.value = data['photoUrl'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user data: $e');
    }
  }

  // Update profile
  Future<void> updateProfile({
    required String name,
    required String gender,
    required String phone,
    String? photoUrlUpdate,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No logged-in user');

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'gender': gender,
        'phone': phone,
        if (photoUrlUpdate != null) 'photoUrl': photoUrlUpdate,
      });

      // Update local values
      userName.value = name;
      userGender.value = gender;
      userPhone.value = phone;
      if (photoUrlUpdate != null) photoUrl.value = photoUrlUpdate;

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchUserData();
  }
}
