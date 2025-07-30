import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UICustomizationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<Color> primaryColor = Color(0xFF0E163C).obs;
  final Rx<Color> backgroundColor = Color(0xFFFFF8E1).obs;
  final Rx<Color> surfaceColor = Color(0xFFFFF8E1).obs;
  final RxString appTitle = 'Virtual Wardrobe App'.obs;
  final RxBool isLoading = false.obs;

  // Helper method to safely convert dynamic value to Color
  Color _safeColorFromDynamic(dynamic value, Color defaultValue) {
    try {
      if (value == null) return defaultValue;
      
      // Handle different types of color values
      if (value is int) {
        return Color(value);
      } else if (value is String) {
        // Try to parse hex string
        if (value.startsWith('#')) {
          return Color(int.parse(value.substring(1), radix: 16));
        } else {
          return Color(int.parse(value));
        }
      } else if (value is double) {
        return Color(value.toInt());
      }
      
      return defaultValue;
    } catch (e) {
      print('Error converting color value: $value, error: $e');
      return defaultValue;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
    // Listen for real-time updates
    _firestore.collection('settings').doc('ui_customization').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        try {
          primaryColor.value = _safeColorFromDynamic(data['primaryColor'], Color(0xFF0E163C));
          backgroundColor.value = _safeColorFromDynamic(data['backgroundColor'], Color(0xFFFFF8E1));
          surfaceColor.value = _safeColorFromDynamic(data['surfaceColor'], Color(0xFFFFF8E1));
          appTitle.value = data['appTitle'] ?? 'Virtual Wardrobe App';
        } catch (e) {
          print('Error parsing color values: $e');
          // Set default values if parsing fails
          primaryColor.value = Color(0xFF0E163C);
          backgroundColor.value = Color(0xFFFFF8E1);
          surfaceColor.value = Color(0xFFFFF8E1);
        }
      }
    });
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('settings').doc('ui_customization').get();
      if (doc.exists) {
        final data = doc.data()!;
        try {
          primaryColor.value = _safeColorFromDynamic(data['primaryColor'], Color(0xFF0E163C));
          backgroundColor.value = _safeColorFromDynamic(data['backgroundColor'], Color(0xFFFFF8E1));
          surfaceColor.value = _safeColorFromDynamic(data['surfaceColor'], Color(0xFFFFF8E1));
          appTitle.value = data['appTitle'] ?? 'Virtual Wardrobe App';
        } catch (e) {
          print('Error parsing color values: $e');
          // Set default values if parsing fails
          primaryColor.value = Color(0xFF0E163C);
          backgroundColor.value = Color(0xFFFFF8E1);
          surfaceColor.value = Color(0xFFFFF8E1);
        }
      } else {
        // Initialize with default values if document doesn't exist
        await _firestore.collection('settings').doc('ui_customization').set({
          'primaryColor': 0xFF0E163C,
          'backgroundColor': 0xFFFFF8E1,
          'surfaceColor': 0xFFFFF8E1,
          'appTitle': 'Virtual Wardrobe App',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error fetching UI settings: $e');
      Get.snackbar('Error', 'Failed to load UI settings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateColors({required Color primary, required Color background, required Color surface}) async {
    isLoading.value = true;
    try {
      // Ensure we're storing the color value as an integer
      final primaryValue = primary.value;
      final backgroundValue = background.value;
      final surfaceValue = surface.value;
      
      print('Saving colors - Primary: $primaryValue, Background: $backgroundValue, Surface: $surfaceValue');
      
      await _firestore.collection('settings').doc('ui_customization').set({
        'primaryColor': primaryValue,
        'backgroundColor': backgroundValue,
        'surfaceColor': surfaceValue,
        'appTitle': appTitle.value,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Update local values
      primaryColor.value = primary;
      backgroundColor.value = background;
      surfaceColor.value = surface;
      
      Get.snackbar('Success', 'Colors updated successfully');
    } catch (e) {
      print('Error updating colors: $e');
      Get.snackbar('Error', 'Failed to update colors: $e');
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
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Update local value
      appTitle.value = title;
      
      Get.snackbar('Success', 'App title updated successfully');
    } catch (e) {
      print('Error updating app title: $e');
      Get.snackbar('Error', 'Failed to update app title');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetToDefaults() async {
    isLoading.value = true;
    try {
      await _firestore.collection('settings').doc('ui_customization').set({
        'primaryColor': 0xFF0E163C,
        'backgroundColor': 0xFFFFF8E1,
        'surfaceColor': 0xFFFFF8E1,
        'appTitle': 'Virtual Wardrobe App',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update local values
      primaryColor.value = Color(0xFF0E163C);
      backgroundColor.value = Color(0xFFFFF8E1);
      surfaceColor.value = Color(0xFFFFF8E1);
      appTitle.value = 'Virtual Wardrobe App';
      
      Get.snackbar('Success', 'Reset to default settings');
    } catch (e) {
      print('Error resetting to defaults: $e');
      Get.snackbar('Error', 'Failed to reset settings');
    } finally {
      isLoading.value = false;
    }
  }
} 