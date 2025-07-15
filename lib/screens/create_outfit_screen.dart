import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/layouts/section_title.dart'; // Assuming SectionTitle is in widgets
import 'package:virtual_wardrobe_app/layouts/item_card.dart'; // Import ItemCard
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
  bool showMoreClothingTypes = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ControllerCreateOutfit>()
        ? Get.find<ControllerCreateOutfit>()
        : Get.put(ControllerCreateOutfit());
    searchController =
        TextEditingController(text: controller.clothingTypeSearch.value);
    controller.clothingTypeSearch.listen((val) {
      if (searchController.text != val) {
        searchController.text = val;
        searchController.selection =
            TextSelection.fromPosition(TextPosition(offset: val.length));
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
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      floatingActionButton: Obx(() =>
          SizedBox(
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
                    Text('Creating...',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                )
                    : Text('Create Now',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ).marginSymmetric(horizontal: 20))),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: colorScheme.primary,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Outfit',
          style: TextStyle(
              color: colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
      ),
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 16.0,right: 16,top: 16.0,bottom: MediaQuery.viewInsetsOf(context).bottom+16),
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
                          final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final file = File(pickedFile.path);
                            final bytes = await file.length();
                            final lowerPath = pickedFile.path.toLowerCase();
                            final isPng = lowerPath.endsWith('.png');
                            final isJpg = lowerPath.endsWith('.jpg');
                            final isJpeg = lowerPath.endsWith('.jpeg');
                            if (bytes > 1024 * 1024) {
                              Get.snackbar('Image too large',
                                  'Please select an image smaller than 1MB.');
                              return;
                            }
                            if (!(isPng || isJpg || isJpeg)) {
                              Get.snackbar('Invalid format',
                                  'Please select a PNG, JPG, or JPEG image. PNG is recommended for background removal.');
                              return;
                            }
                            controller.setOutfitImage(file);
                          }
                        } catch (e) {
                          Get.snackbar('Error', 'Failed to pick image.');
                        }
                      },
                      child: Obx(() =>
                          Semantics(
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
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48),
                                  SizedBox(height: 8),
                                  Text('Tap to upload outfit image',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                'Image requirements: Max size 1MB, PNG, JPG, or JPEG format (PNG recommended for background removal)',
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
              SizedBox(height: 16.0),
              // Gender/Type Selector
              SectionTitle(title: 'Type (Men, Women, Other)'),
              SizedBox(height: 8.0),
              Obx(() =>
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: Text('Men'),
                        selected: controller.selectedGenderType.value == 'Men',
                        onSelected: (selected) {
                          if (selected) controller.selectGenderType('Men');
                        },
                      ),
                      ChoiceChip(
                        label: Text('Women'),
                        selected: controller.selectedGenderType.value ==
                            'Women',
                        onSelected: (selected) {
                          if (selected) controller.selectGenderType('Women');
                        },
                      ),
                      ChoiceChip(
                        label: Text('Other'),
                        selected: controller.selectedGenderType.value ==
                            'Other',
                        onSelected: (selected) {
                          if (selected) controller.selectGenderType('Other');
                        },
                      ),
                    ],
                  )),
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
                    RxBool isSelected = false.obs;
                    isSelected.value =
                        controller.selectedSeason.value == season;
                    return Obx(() {
                      return ElevatedButton(
                        onPressed: () {
                          controller.selectedSeason.value = season;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedSeason.value ==
                              season ? colorScheme
                              .primary : colorScheme.surface,
                          foregroundColor: controller.selectedSeason.value ==
                              season ? colorScheme
                              .surface : colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: colorScheme.primary.withAlpha(
                                    (0.5 * 255).round())),
                          ),
                          elevation: controller.selectedSeason.value == season
                              ? 2.0
                              : 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                        ),
                        child: Text(season, style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    });
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
                    final isSelected = controller.selectedWeather.value ==
                        value;
                    return Obx(() {
                      return ElevatedButton(
                        onPressed: () {
                          controller.selectedWeather.value = value;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedWeather.value ==
                              value
                              ? colorScheme.primary
                              : colorScheme.surface,
                          foregroundColor: controller.selectedWeather.value ==
                              value
                              ? colorScheme.surface
                              : colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: colorScheme.primary.withOpacity(0.5)),
                          ),
                          elevation: controller.selectedWeather.value ==
                              value ? 2.0 : 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(option['range'], style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(option['condition'], style: TextStyle(
                                fontSize: 12,
                                color: controller.selectedWeather.value ==
                                    value ? colorScheme.surface
                                    .withOpacity(0.8) : colorScheme.primary
                                    .withOpacity(0.7))),
                          ],
                        ),
                      );
                    });
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
                    final isSelected = controller.selectedCategory.value ==
                        category;
                    return Obx(() {
                      return ElevatedButton(
                        onPressed: () {
                          controller.selectedCategory.value =
                              category;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedCategory.value ==
                              category
                              ? colorScheme.primary
                              : colorScheme.surface,
                          foregroundColor: controller.selectedCategory.value ==
                              category
                              ? colorScheme.background
                              : colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: colorScheme.primary.withOpacity(0.5)),
                          ),
                          elevation: controller.selectedCategory.value ==
                              category ? 2.0 : 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                        ),
                        child: Text(category, style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    });
                  },
                );
              }),
              // Clothing Type Section
              SectionTitle(title: 'Select Clothing Type'),
              SizedBox(height: 16.0),
              Obx(() =>
                  TextField(
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
                final showAll = showMoreClothingTypes ||
                    controller.clothingTypeSearch.value.isNotEmpty;
                final displayList = showAll ? filtered : filtered
                    .take(7)
                    .toList();
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
                  itemCount: showAll
                      ? displayList.length + 1 // +1 for the minus button
                      : (filtered.length > 7 ? 8 : displayList.length),
                  itemBuilder: (context, index) {
                    if (!showAll && index == 7) {
                      // Show more button as an ElevatedButton with a + icon
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showMoreClothingTypes = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: colorScheme.primary.withOpacity(0.5)),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                        ),
                        child: Icon(Icons.add, color: colorScheme.primary),
                      );
                    }
                    if (showAll && index == displayList.length) {
                      // Show less button as an ElevatedButton with a - icon
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showMoreClothingTypes = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: colorScheme.primary.withOpacity(0.5)),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                        ),
                        child: Icon(Icons.remove, color: colorScheme.primary),
                      );
                    }
                    final type = displayList[index];
                    final isSelected = controller.selectedClothingType.value ==
                        type;
                    return Obx(() {
                      return ElevatedButton(
                        onPressed: () {
                          controller.selectedClothingType.value =
                              type;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedClothingType
                              .value ==
                              type
                              ? colorScheme.primary
                              : colorScheme.surface,
                          foregroundColor: controller.selectedClothingType
                              .value ==
                              type
                              ? colorScheme.surface
                              : colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                                color: colorScheme.primary.withOpacity(0.5)),
                          ),
                          elevation: controller.selectedClothingType.value ==
                              type ? 2.0 : 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12.0),
                        ),
                        child: Text(type, style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    });
                  },
                );
              }),

              SizedBox(height: 50.0),
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
      final timestamp = DateTime
          .now()
          .millisecondsSinceEpoch;
      final ext = imageFile.path
          .split('.')
          .last;
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
      Get.snackbar('Image Save Error',
          'Failed to save image locally. Please check storage permissions.');
      return null;
    }
  }
}