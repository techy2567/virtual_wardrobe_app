import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UICustomizationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Rx<Color> primaryColor = Colors.blue.obs;
  Rx<Color> backgroundColor = Colors.white.obs;
  Rx<Color> surfaceColor = Colors.white.obs;
  RxString appTitle = 'Virtual Wardrobe App'.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('settings').doc('ui_customization').get();
      if (doc.exists) {
        final data = doc.data()!;
        primaryColor.value = Color(data['primaryColor'] ?? 0xFF0E163C);
        backgroundColor.value = Color(data['backgroundColor'] ?? 0xFFFFF8E1);
        surfaceColor.value = Color(data['surfaceColor'] ?? 0xFFFFF8E1);
        appTitle.value = data['appTitle'] ?? 'Virtual Wardrobe App';
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateColors({required Color primary, required Color background, required Color surface}) async {
    isLoading.value = true;
    try {
      await _firestore.collection('settings').doc('ui_customization').set({
        'primaryColor': primary.value,
        'backgroundColor': background.value,
        'surfaceColor': surface.value,
        'appTitle': appTitle.value,
      }, SetOptions(merge: true));
      await fetchSettings();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTexts({required String title}) async {
    isLoading.value = true;
    try {
      await _firestore.collection('settings').doc('ui_customization').set({
        'appTitle': title,
        'primaryColor': primaryColor.value.value,
        'backgroundColor': backgroundColor.value.value,
        'surfaceColor': surfaceColor.value.value,
      }, SetOptions(merge: true));
      await fetchSettings();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
} 