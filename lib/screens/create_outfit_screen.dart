import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/widgets/section_title.dart'; // Assuming SectionTitle is in widgets
import 'package:virtual_wardrobe_app/widgets/item_card.dart'; // Import ItemCard
import 'package:virtual_wardrobe_app/controllers/controller_create_outfit.dart';
import 'package:path_provider/path_provider.dart';
import '../layouts/layout_home.dart';

class CreateOutfitScreen extends StatefulWidget {
   CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  late final ControllerCreateOutfit controller;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ControllerCreateOutfit>()
        ? Get.find<ControllerCreateOutfit>()
        : Get.put(ControllerCreateOutfit());
    searchController = TextEditingController(text: controller.clothingTypeSearch.value);
    controller.clothingTypeSearch.listen((val) {
      if (searchController.text != val) {
        searchController.text = val;
        searchController.selection = TextSelection.fromPosition(TextPosition(offset: val.length));
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() => SizedBox(
          width: Get.width,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    final success = await controller.saveOutfit();
                    if (success) {
                      Get.offAll(() => HomeScreen());
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            child: controller.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Creating...', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  )
                : Text('Create Now', style: TextStyle(color: Colors.white, fontSize: 18)),
          ).marginSymmetric(horizontal: 20))),
      appBar: AppBar(
        leading: IconButton(
          icon:   Icon(Icons.arrow_back_ios),
          color: colorScheme.primary,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Outfit',
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
      ),
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding:   EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Outfit Image Section (single image)
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: colorScheme.surface,
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final file = File(pickedFile.path);
                            final bytes = await file.length();
                            final isPng = pickedFile.path.toLowerCase().endsWith('.png');
                            if (bytes > 1024 * 1024) {
                              Get.snackbar('Image too large', 'Please select an image smaller than 1MB.');
                              return;
                            }
                            if (!isPng) {
                              Get.snackbar('Invalid format', 'Please select a PNG image for best results.');
                              return;
                            }
                            controller.setOutfitImage(file);
                          }
                        } catch (e) {
                          Get.snackbar('Error', 'Failed to pick image.');
                        }
                      },
                      child: Obx(() => Semantics(
                        label: 'Upload outfit image',
                        child: Container(
                          width: double.infinity,
                          height: 280,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: controller.outfitImage.value != null
                              ? Image.file(
                                  controller.outfitImage.value!,
                                  fit: BoxFit.cover,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:   [
                                    Icon(Icons.add_photo_alternate, size: 48),
                                    SizedBox(height: 8),
                                    Text('Tap to upload outfit image', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      )),
                    ),
                  ),
                ),
              ),
                SizedBox(height: 8.0),
                Text(
                'Image requirements: Max size 1MB, PNG format recommended for background removal',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.0),
              // Title Field
              SectionTitle(title: 'Outfit Title'),
              SizedBox(height: 8.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (value) => controller.title.value = value,
              ),
              SizedBox(height: 16.0),
              // Description Field
              SectionTitle(title: 'Description'),
              SizedBox(height: 8.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                maxLines: 2,
                onChanged: (value) => controller.description.value = value,
              ),
              SizedBox(height: 24.0),
              // Select Season Section
              SectionTitle(title: 'Select Season'),
              SizedBox(height: 16.0),
              Obx(() {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: controller.seasonOptions.length,
                  itemBuilder: (context, index) {
                    final season = controller.seasonOptions[index];
                    final isSelected = controller.selectedSeason.value == season;
                    return ElevatedButton(
                      onPressed: () => controller.selectSeason(season),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                        foregroundColor: isSelected ? colorScheme.background : colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                        ),
                        elevation: isSelected ? 2.0 : 0,
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      ),
                      child: Text(season, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                );
              }),
                SizedBox(height: 24.0),
              // Select Weather Section
              SectionTitle(title: 'Select Weather'),
              SizedBox(height: 16.0),
              Obx(() {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: controller.weatherOptions.length,
                  itemBuilder: (context, index) {
                    final option = controller.weatherOptions[index];
                    final value = option['range'] + ' - ' + option['condition'];
                    final isSelected = controller.selectedWeather.value == value;
                    return ElevatedButton(
                      onPressed: () => controller.selectWeather(value),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                        foregroundColor: isSelected ? colorScheme.background : colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                        ),
                        elevation: isSelected ? 2.0 : 0,
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(option['range'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(option['condition'], style: TextStyle(fontSize: 12, color: isSelected ? colorScheme.background.withOpacity(0.8) : colorScheme.primary.withOpacity(0.7))),
                        ],
                      ),
                    );
                  },
                );
              }),
              SizedBox(height: 24.0),
              // Select Category Section
              SectionTitle(title: 'Select Category'),
              SizedBox(height: 16.0),
              Obx(() {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: controller.categoryOptions.length,
                  itemBuilder: (context, index) {
                    final category = controller.categoryOptions[index];
                    final isSelected = controller.selectedCategory.value == category;
                    return ElevatedButton(
                      onPressed: () => controller.selectCategory(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                        foregroundColor: isSelected ? colorScheme.background : colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                        ),
                        elevation: isSelected ? 2.0 : 0,
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                      ),
                      child: Text(category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                );
              }),
              // Clothing Type Section
              SectionTitle(title: 'Select Clothing Type'),
                SizedBox(height: 16.0),
              Obx(() => TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search clothing type',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: controller.clothingTypeSearch.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            controller.updateClothingTypeSearch('');
                          },
                        )
                      : SizedBox.shrink(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: (value) {
                  controller.updateClothingTypeSearch(value);
                },
              )),
                SizedBox(height: 16.0),
              Obx(() {
                final filtered = controller.filteredClothingTypes;
                return filtered.isEmpty
                    ? Text('No clothing types found.')
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 3.0,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final type = filtered[index];
                          final isSelected = controller.selectedClothingType.value == type;
                          return ElevatedButton(
                            onPressed: () {
                              controller.selectClothingType(type);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                              foregroundColor: isSelected ? colorScheme.background : colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                              ),
                              elevation: isSelected ? 2.0 : 0,
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            ),
                            child: Text(type, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          );
                        },
                      );
              }),

              SizedBox(height: 24.0),
              // Donated Switch
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Mark as Donated', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              //     Obx(() => Switch(
              //           value: controller.isDonated.value,
              //           onChanged: controller.toggleDonated,
              //         )),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = imageFile.path.split('.').last;
      final imageId = '$timestamp.$ext';
      final localPath = '${dir.path}/$imageId';
      // Debug log
      print('Saving image to: ' + localPath);
      final savedFile = await imageFile.copy(localPath);
      if (await savedFile.exists()) {
        return imageId;
      } else {
        print('File not saved at: ' + localPath);
        return null;
      }
    } catch (e) {
      print('Error saving image locally: $e');
      Get.snackbar('Image Save Error', 'Failed to save image locally. Please check storage permissions.');
      return null;
    }
  }
}