import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:virtual_wardrobe_app/layouts/weather_card.dart';

import '../screens/myoutfits_screen.dart';
import '../screens/outfit_details_screen.dart';
import '../screens/weekly_challenge_screen.dart';
import '../widgets/item_card.dart';
import '../widgets/outfit_card.dart';
import '../widgets/section_title.dart';

class LayoutHome extends StatelessWidget {
   LayoutHome({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Dummy data for demonstration
    final List<Map<String, dynamic>> dummyOutfits = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FF0000', // Placeholder image URL
        'title': 'Casual',
        'colors': [Colors.brown, Colors.grey, Colors.blueGrey, Colors.black, Colors.blue],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/00FF00', // Placeholder image URL
        'title': 'Classic',
        'colors': [Colors.brown, Colors.blueGrey, Colors.green, Colors.brown, Colors.amber],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/0000FF', // Placeholder image URL
        'title': 'Sporty',
        'colors': [Colors.red, Colors.white, Colors.black],
      },
    ];

    final List<Map<String, dynamic>> dummyItems = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FFFF00', // Placeholder image URL
        'title': 'Orange Cardigan',
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/FFA500', // Placeholder image URL
        'title': 'Colorful Sweater',
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/800080', // Placeholder image URL
        'title': 'Purple Jacket',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Outfits Calendar',
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold), // Dark navy color
        ),
        backgroundColor: colorScheme.background, // Light beige background
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.primary), // Arrow icon
            onPressed: () {
              // TODO: Implement navigation to Calendar screen
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.surface, // Light beige background for the whole screen
      body: LayoutBuilder(
          builder:(context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                              height: 205,
                              child: const WeatherCard()),
                          const SizedBox(height: 24.0),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.8),
                                  colorScheme.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // TODO: Navigate to weekly challenge screen
                                  Get.to(() => const WeeklyChallengeScreen());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Weekly Challenge',
                                              style: TextStyle(
                                                color: colorScheme.onPrimary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Create 5 sustainable outfits this week!',
                                              style: TextStyle(
                                                color: colorScheme.onPrimary.withOpacity(0.9),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: colorScheme.onPrimary.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.emoji_events,
                                          color: colorScheme.onPrimary,
                                          size: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          SectionTitle(
                            key: Key('myOutfitsTitle'),
                            title: 'My Outfits',
                            onAddPressed: () {
                              // TODO: Implement add outfit logic
                            },
                            onViewAllPressed: () {
                              // TODO: Implement view all outfits navigation
                            },
                          ),
                          const SizedBox(height: 16.0),
                          SizedBox(
                            height: 200, // Adjust height as needed
                            width:Get.width,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dummyOutfits.length,
                              itemBuilder: (context, index) {
                                final outfit = dummyOutfits[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to MyOutfitsScreen when outfit card is tapped
                                    Get.to(() => const MyOutfitsScreen());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0), // Spacing between cards
                                    child: OutfitCard(
                                      imageUrl: outfit['imageUrl'],
                                      title: outfit['title'],
                                      colors: outfit['colors'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          SectionTitle(
                            key: Key('itemsTitle'),
                            title: 'Items',
                            onAddPressed: () {
                              // TODO: Implement add item logic
                            },
                            onViewAllPressed: () {
                              // TODO: Implement view all items navigation
                            },
                          ),
                          const SizedBox(height: 16.0),
                          SizedBox(
                            height: 190, // Adjust height as needed, slightly smaller than outfits
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dummyItems.length,
                              itemBuilder: (context, index) {
                                final item = dummyItems[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to OutfitDetailsScreen when the item is tapped
                                    Get.to(() => const OutfitDetailsScreen());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: SizedBox(
                                      width: 120,
                                      child: ItemCard(
                                        imageUrl: item['imageUrl'],
                                        title: item['title'],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24.0), // Spacing before bottom nav (optional depending on layout)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}
