


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller_home.dart';
import '../layouts/layout_favourite.dart';
import '../layouts/layout_home.dart';
import '../layouts/layout_profile.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    // Dummy data for demonstration
    final List<Map<String, dynamic>> dummyOutfits = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FF0000',
        // Placeholder image URL
        'title': 'Casual',
        'colors': [
          Colors.brown,
          Colors.grey,
          Colors.blueGrey,
          Colors.black,
          Colors.blue
        ],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/00FF00',
        // Placeholder image URL
        'title': 'Classic',
        'colors': [
          Colors.brown,
          Colors.blueGrey,
          Colors.green,
          Colors.brown,
          Colors.amber
        ],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/0000FF',
        // Placeholder image URL
        'title': 'Sporty',
        'colors': [Colors.red, Colors.white, Colors.black],
      },
    ];

    final List<Map<String, dynamic>> dummyItems = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FFFF00',
        // Placeholder image URL
        'title': 'Orange Cardigan',
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/FFA500',
        // Placeholder image URL
        'title': 'Colorful Sweater',
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/800080',
        // Placeholder image URL
        'title': 'Purple Jacket',
      },
    ];
    ControllerHome controllerHome = Get.put(ControllerHome());
    List screens = [
      LayoutHome(),
      LayoutFavourite(),
      LayoutProfile(),
    ];
    return Obx(() {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        // Light beige background for the whole screen
        body: screens[controllerHome.selectedIndex.value],
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: controllerHome.selectedIndex.value, // Set initial selected index
          onItemTapped: (index) {
            controllerHome.selectedIndex.value = index;
            // TODO: Implement bottom navigation logic
            print('Tapped on item: $index');
          },
        ),
      );
    });
  }
} 