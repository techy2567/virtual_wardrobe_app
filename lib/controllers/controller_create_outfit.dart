import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ControllerCreateOutfit extends GetxController {
  // State variables
  var outfitImage = Rx<File?>(null);

  var selectedWeatherIndex = (-1).obs;
  var selectedCategoryIndex = (-1).obs;
  var selectedClothingTypeIndex = (-1).obs;
  var selectedFilterIndex = (-1).obs;

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

  // Filtered items
  RxList<Map<String, dynamic>> filteredItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredItems.assignAll(dummyItems);
    filteredClothingTypes.assignAll(clothingTypes);
  }

  void setOutfitImage(File file) => outfitImage.value = file;

  void selectWeather(int index) => selectedWeatherIndex.value = index;
  void selectCategory(int index) => selectedCategoryIndex.value = index;
  void selectClothingType(int index) => selectedClothingTypeIndex.value = index;

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

  void filterItems(int index) {
    selectedFilterIndex.value = index;
    // Example: filter logic (replace with real logic)
    if (index == 0) {
      filteredItems.assignAll(dummyItems);
    } else {
      filteredItems.assignAll(dummyItems.where((item) => item['title'].toString().contains(itemFilters[index].split(' ')[0])));
    }
  }

  void addItemToOutfit() {
    // TODO: Implement add item logic
    Get.snackbar('Add Item', 'Add item to outfit functionality coming soon!');
  }

  void addCustomCategory() {
    // TODO: Implement add custom category logic
    Get.snackbar('Add Category', 'Add custom category functionality coming soon!');
  }

  Future<bool> saveOutfit() async {
    // TODO: Implement save outfit logic (validation, upload, etc.)
    if (outfitImage.value == null) {
      Get.snackbar('Validation', 'Please upload an outfit image.');
      return false;
    }
    if (selectedWeatherIndex.value == -1) {
      Get.snackbar('Validation', 'Please select a weather option.');
      return false;
    }
    if (selectedCategoryIndex.value == -1) {
      Get.snackbar('Validation', 'Please select a category.');
      return false;
    }
    if (selectedClothingTypeIndex.value == -1) {
      Get.snackbar('Validation', 'Please select a clothing type.');
      return false;
    }
    // Simulate save
    await Future.delayed(const Duration(seconds: 1));
    Get.snackbar('Success', 'Outfit saved successfully!');
    return true;
  }
}