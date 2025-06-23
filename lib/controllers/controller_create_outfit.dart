import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:virtual_wardrobe_app/models/outfit_model.dart';
import 'package:uuid/uuid.dart';

class ControllerCreateOutfit extends GetxController {
  // State variables
  var outfitImage = Rx<File?>(null);
  var isLoading = false.obs;

  // Value-based selection
  RxString selectedWeather = ''.obs;
  RxString selectedCategory = ''.obs;
  RxString selectedClothingType = ''.obs;
  RxString selectedSeason = ''.obs;

  // New fields for OutfitModel
  RxString title = ''.obs;
  RxString description = ''.obs;
  RxBool isDonated = false.obs;

  // Clothing types
  RxList<String> clothingTypes = <String>[
    'Shirt', 'Pant', 'Frock', 'Skirt', 'Shorts', 'Dress', 'Jacket', 'Sweater', 'Coat', 'Blazer',
    'T-shirt', 'Top', 'Jeans', 'Leggings', 'Suit', 'Saree', 'Kurta', 'Dupatta', 'Scarf', 'Hoodie',
    'Cardigan', 'Waistcoat', 'Tracksuit', 'Dungarees', 'Overalls', 'Capri', 'Chinos', 'Polo', 'Tank Top',
    'Gown', 'Lehenga', 'Sherwani', 'Pajamas', 'Salwar', 'Culottes', 'Jumpsuit', 'Poncho', 'Raincoat',
    'Swimsuit', 'Bikini', 'Tunic', 'Kimono', 'Camisole', 'Blouse', 'Vest', 'Other',
  ].obs;
  RxString clothingTypeSearch = ''.obs;
  RxList<String> filteredClothingTypes = <String>[].obs;

  // Dummy data (should be replaced with real data)
  RxList<String> itemFilters = <String>['All (12)', 'Classic (14)', 'Sport (24)'].obs;
  RxList<Map<String, dynamic>> dummyItems = <Map<String, dynamic>>[
    { 'imageUrl': 'https://via.placeholder.com/100/A9A9A9', 'title': 'Brown Jacket' },
    { 'imageUrl': 'https://via.placeholder.com/100/D3D3D3', 'title': 'Camel Shirt' },
  ].obs;
  RxList<Map<String, dynamic>> weatherOptions = <Map<String, dynamic>>[
    {'range': '-30° to -20°', 'condition': 'Extra cold'},
    {'range': '-20° to -10°', 'condition': 'Very cold'},
    {'range': '-10° to 0°', 'condition': 'Cold'},
    {'range': '0° to +10°', 'condition': 'Chilly'},
    {'range': '+10° to +20°', 'condition': 'Warm'},
    {'range': '+20° to +30°', 'condition': 'Hot'},
  ].obs;
  RxList<String> categoryOptions = <String>['Classic', 'Sport', 'Casual', 'Festive', 'Home', 'Outside'].obs;
  RxList<String> seasonOptions = <String>['Winter', 'Summer', 'Spring', 'Autumn'].obs;

  // Filtered items
  RxList<Map<String, dynamic>> filteredItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredItems.assignAll(dummyItems);
    filteredClothingTypes.assignAll(clothingTypes);
  }

  void setOutfitImage(File file) => outfitImage.value = file;

  void selectWeather(String value) => selectedWeather.value = value;
  void selectCategory(String value) => selectedCategory.value = value;
  void selectClothingType(String value) => selectedClothingType.value = value;
  void selectSeason(String value) => selectedSeason.value = value;
  void toggleDonated(bool value) => isDonated.value = value;

  void updateClothingTypeSearch(String query) {
    clothingTypeSearch.value = query;
    if (query.isEmpty) {
      filteredClothingTypes.assignAll(clothingTypes);
    } else {
      filteredClothingTypes.assignAll(
        clothingTypes.where((type) => type.toLowerCase().contains(query.toLowerCase())),
      );
    }
  }

  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imageId = const Uuid().v4();
      final ext = imageFile.path.split('.').last;
      final localPath = '${dir.path}/$imageId.$ext';
      await imageFile.copy(localPath);
      return '$imageId.$ext';
    } catch (e) {
      return null;
    }
  }

  static Future<File?> getImageFileByIdStatic(String imageId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$imageId');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<bool> saveOutfit() async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      // Validate fields
      if (outfitImage.value == null) {
        Get.snackbar('Validation', 'Please upload an outfit image.');
        isLoading.value = false;
        return false;
      }
      if (selectedWeather.value.isEmpty) {
        Get.snackbar('Validation', 'Please select a weather option.');
        isLoading.value = false;
        return false;
      }
      if (selectedCategory.value.isEmpty) {
        Get.snackbar('Validation', 'Please select a category.');
        isLoading.value = false;
        return false;
      }
      if (selectedClothingType.value.isEmpty) {
        Get.snackbar('Validation', 'Please select a clothing type.');
        isLoading.value = false;
        return false;
      }
      if (title.value.trim().isEmpty) {
        Get.snackbar('Validation', 'Please enter a title.');
        isLoading.value = false;
        return false;
      }
      if (selectedSeason.value.isEmpty) {
        Get.snackbar('Validation', 'Please select a season.');
        isLoading.value = false;
        return false;
      }

      // Check internet connection
      // (You can use connectivity_plus here if available)
      // If not connected, show error and return

      // Save image locally with timestamp id
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String? imageId = '';
         try{
           imageId = await _saveImageLocally(outfitImage.value!);

         }catch(e) {
           Get.snackbar('Error', 'Failed to save image locally: $e');
           isLoading.value = false;
           return false;
         }
      if (imageId == null) {
        Get.snackbar('Error', 'Failed to save image locally.');
        isLoading.value = false;
        return false;
      }

      // Get user id
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not logged in.');
        isLoading.value = false;
        return false;
      }

      // Prepare outfit model
      final outfit = OutfitModel(
        id: timestamp.toString(),
        userId: user.uid,
        title: title.value.trim(),
        description: description.value.trim(),
        imageId: imageId,
        categories: [selectedCategory.value],
        clothingType: selectedClothingType.value,
        weatherRange: selectedWeather.value,
        season: selectedSeason.value,
        isFavorite: false,
        isDonated: isDonated.value,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('outfits')
          .doc(outfit.id)
          .set(outfit.toJson());

      Get.snackbar('Success', 'Outfit created successfully!');
      isLoading.value = false;
      return true;
    } on FirebaseException catch (e) {
      Get.snackbar('Firebase Error', e.message ?? 'An error occurred.');
      isLoading.value = false;
      return false;
    } on SocketException {
      Get.snackbar('No Internet', 'Please check your internet connection.');
      isLoading.value = false;
      return false;
    } on TimeoutException {
      Get.snackbar('Timeout', 'The request timed out. Please try again.');
      isLoading.value = false;
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.');
      isLoading.value = false;
      return false;
    }
  }
}