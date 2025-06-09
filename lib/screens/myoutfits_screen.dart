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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary), // Back arrow
          onPressed: () {
            Get.back(); // Navigate back using GetX
          },
        ),
        title: Text(
          'My Outfits',
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold), // Dark navy color
        ),
        backgroundColor: colorScheme.background, // Light beige background
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.primary), // Add icon
            onPressed: () {
              // Navigate to CreateOutfitScreen
              Get.to(() => const CreateOutfitScreen());
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.background, // Light beige background for the whole screen
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox( // Container for filter buttons
            height: 120, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: outfitFilters.length,
              itemBuilder: (context, index) {
                final filterText = outfitFilters[index];
                // Basic button styling, can be made a custom widget if reused
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Spacing between buttons
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement filter logic
                      print('Filter tapped: $filterText');
                    },
                    style: ElevatedButton.styleFrom(
                       backgroundColor: index == 0 ? colorScheme.primary : colorScheme.surface, // Highlight 'All' button
                       foregroundColor: index == 0 ? colorScheme.background : colorScheme.primary, // Text color
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // pill shape
                         side: BorderSide(color: colorScheme.primary.withOpacity(0.5)) // Border
                      ),
                      elevation: 0,
                    ),
                    child: Text(filterText),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0), // Spacing between filters and outfit grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 16.0, // Spacing between columns
                mainAxisSpacing: 16.0, // Spacing between rows
                 childAspectRatio: 0.7, // Adjust aspect ratio to fit image and text
              ),
              itemCount: dummyOutfits.length,
              itemBuilder: (context, index) {
                final outfit = dummyOutfits[index];
                return OutfitCard(
                  imageUrl: outfit['imageUrl'],
                  title: outfit['title'],
                  colors: outfit['colors'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 