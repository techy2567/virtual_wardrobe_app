import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/widgets/outfit_card.dart'; // Import OutfitCard from widgets folder
import 'package:virtual_wardrobe_app/screens/create_outfit_screen.dart'; // Import CreateOutfitScreen

// Removed temporary OutfitCard definition

// Main screen widget
class MyOutfitsScreen extends StatelessWidget {
  const MyOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dummy data for demonstration
    final List<Map<String, dynamic>> dummyOutfits = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FF5733', // Example Placeholder
        'title': 'Casual',
        'colors': [Colors.brown, Colors.grey, Colors.blueGrey, Colors.black, Colors.blue],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/33FF57', // Example Placeholder
        'title': 'Classic',
        'colors': [Colors.brown, Colors.blueGrey, Colors.green, Colors.brown, Colors.amber],
      },
       {
        'imageUrl': 'https://via.placeholder.com/150/3357FF', // Example Placeholder
        'title': 'Sporty',
        'colors': [Colors.red, Colors.white, Colors.black],
      },
       {
        'imageUrl': 'https://via.placeholder.com/150/FFFF33', // Example Placeholder
        'title': 'Holiday',
        'colors': [Colors.red, Colors.green, Colors.white, Colors.yellow],
      },
       {
        'imageUrl': 'https://via.placeholder.com/150/FF33FF', // Example Placeholder
        'title': 'Evening',
        'colors': [Colors.black, Colors.red, Colors.grey],
      },
       {
        'imageUrl': 'https://via.placeholder.com/150/33FFFF', // Example Placeholder
        'title': 'Summer',
        'colors': [Colors.yellow, Colors.blue, Colors.white],
      },
       {
        'imageUrl': 'https://via.placeholder.com/150/FF33FF', // Example Placeholder
        'title': 'Evening',
        'colors': [Colors.black, Colors.red, Colors.grey],
      },
       {
        'imageUrl': 'https://via.placeholder.com/150/33FFFF', // Example Placeholder
        'title': 'Summer',
        'colors': [Colors.yellow, Colors.blue, Colors.white],
      },
    ];

    // Dummy filter options (matches image)
    final List<String> outfitFilters = ['All (12)', 'Classic (14)', 'Sport (24)', 'Holiday (8)', 'Evening (5)', 'Summer (10)'];
    int selectedFilter = 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary), // Back arrow
          onPressed: () => Get.back(), // Navigate back using GetX
        ),
        title: Text(
          'My Outfits',
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold), // Dark navy color
        ),
        backgroundColor: colorScheme.background, // Light beige background
        elevation: 0,
      ),
      backgroundColor: colorScheme.background, // Light beige background for the whole screen
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CreateOutfitScreen()),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.background),
        tooltip: 'Add Outfit',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Filter by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary)),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: outfitFilters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(outfitFilters[index]),
                  selected: index == selectedFilter,
                  onSelected: (_) {
                    // TODO: Implement filter logic
                  },
                  selectedColor: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  labelStyle: TextStyle(
                    color: index == selectedFilter ? colorScheme.background : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: StadiumBorder(side: BorderSide(color: colorScheme.primary.withOpacity(0.3))),
                  elevation: 0,
                );
              },
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: dummyOutfits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style, size: 64, color: colorScheme.primary.withOpacity(0.2)),
                        SizedBox(height: 12),
                        Text('No outfits found', style: TextStyle(fontSize: 18, color: colorScheme.primary.withOpacity(0.7))),
                        SizedBox(height: 8),
                        Text('Tap + to add your first outfit!', style: TextStyle(fontSize: 14, color: colorScheme.primary.withOpacity(0.5))),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: dummyOutfits.length,
                    itemBuilder: (context, index) {
                      final outfit = dummyOutfits[index];
                      return OutfitCard(
                        imageUrl: outfit['imageUrl'],
                        title: outfit['title'],
                        colors: outfit['colors'],
                        onTap: () {
                          // TODO: Navigate to outfit details
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 