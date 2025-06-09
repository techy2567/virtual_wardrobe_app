import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/widgets/info_card.dart'; // Import InfoCard and ColorInfoCard
import 'package:virtual_wardrobe_app/widgets/section_title.dart'; // Import SectionTitle
// ignore: unused_import
import 'package:virtual_wardrobe_app/widgets/item_card.dart'; // Import ItemCard
import 'package:virtual_wardrobe_app/screens/donation_screen.dart'; // Import DonationScreen
import 'package:virtual_wardrobe_app/screens/tailor_screen.dart';

class OutfitDetailsScreen extends StatelessWidget {
  const OutfitDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

     // Dummy data for a single outfit for demonstration
    final Map<String, dynamic> dummyOutfitDetails = {
      'imageUrl': 'https://via.placeholder.com/400x300/CCCCCC', // Placeholder image URL (adjusted size)
      'price': '\$113.00',
      'weather': '+10° to -10°',
      'category': 'Casual',
      'colors': [Colors.grey, Colors.blueGrey, Colors.black, Colors.blueGrey.shade100],
      'usedItems': [
        {
          'imageUrl': 'https://via.placeholder.com/100/808080', // Placeholder (adjusted size)
          'title': 'Coat',
        },
        {
          'imageUrl': 'https://via.placeholder.com/100/A9A9A9', // Placeholder (adjusted size)
          'title': 'Sweater',
        },
         {
          'imageUrl': 'https://via.placeholder.com/100/D3D3D3', // Placeholder (adjusted size)
          'title': 'Jeans',
        },
         {
          'imageUrl': 'https://via.placeholder.com/100/FFFFFF', // Placeholder (adjusted size)
          'title': 'Shoes',
        },
      ],
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary), // Back arrow
          onPressed: () {
            Get.back(); // Navigate back using GetX
          },
        ),
        title: Text(
          'Outfit', // Title from image
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold), // Dark navy color
        ),
        backgroundColor: colorScheme.background, // Light beige background
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.primary), // Edit icon
            onPressed: () {
              // TODO: Implement edit outfit logic
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.background, // Light beige background for the whole screen
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Main Outfit Image Section
              Card(
                 elevation: 2.0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16.0),
                 ),
                 clipBehavior: Clip.antiAlias,
                child: Image.network(
                  dummyOutfitDetails['imageUrl'],
                  fit: BoxFit.cover,
                  height: 300, // Adjust height as needed to match image reference
                  width: double.infinity,
                   errorBuilder: (context, error, stackTrace) => Container(
                     color: colorScheme.surface,
                     child: Icon(Icons.broken_image, color: colorScheme.primary.withOpacity(0.6)),
                   ),
                   loadingBuilder: (context, child, loadingProgress) {
                     if (loadingProgress == null) return child;
                     return Center(
                       child: CircularProgressIndicator(
                         value: loadingProgress.expectedTotalBytes != null
                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                             : null,
                       ),
                     );
                   },
                ),
              ),
              const SizedBox(height: 24.0),

              // Information Section
              SectionTitle(title: 'Information'),
              const SizedBox(height: 16.0),
              GridView.count(
                shrinkWrap: true, // Use shrinkWrap in Column to avoid unbounded height
                physics: NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.8, // Adjust aspect ratio of info cards to match image
                children: [
                  InfoCard(label: 'Price', value: dummyOutfitDetails['price']),
                  InfoCard(label: 'Weather', value: dummyOutfitDetails['weather']),
                  InfoCard(label: 'Category', value: dummyOutfitDetails['category']),
                  ColorInfoCard(label: 'Colors', colors: dummyOutfitDetails['colors']),
                ],
              ),
              const SizedBox(height: 24.0),

              // Used Items Section
              // SectionTitle(title: 'Used Items ',trailingText: '${dummyOutfitDetails['usedItems'].length}',), // Include item count
              // const SizedBox(height: 16.0),
              //  SizedBox(
              //    height: 140, // Adjust height as needed for item cards
              //    child: ListView.builder(
              //      scrollDirection: Axis.horizontal,
              //      itemCount: dummyOutfitDetails['usedItems'].length,
              //      itemBuilder: (context, index) {
              //        final item = dummyOutfitDetails['usedItems'][index];
              //        return Padding(
              //          padding: const EdgeInsets.only(right: 16.0), // Spacing between cards
              //          child: SizedBox(
              //            width: 100, // Explicit width for item card to match image
              //            child: ItemCard(
              //              imageUrl: item['imageUrl'],
              //              title: item['title'],
              //            ),
              //          ),
              //        );
              //      },
              //    ),
              //  ),
               // Donation Section
               SectionTitle(title: 'Donation'),
               const SizedBox(height: 16.0),
               ElevatedButton(
                 onPressed: () {
                   Get.to(() => const DonationScreen());
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: colorScheme.primary,
                   foregroundColor: colorScheme.background,
                   minimumSize: const Size(double.infinity, 48.0), // Full width button
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12.0),
                   ),
                   elevation: 2.0,
                 ),
                 child: const Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.volunteer_activism),
                     SizedBox(width: 8.0),
                     Text(
                       'Donate Clothes',
                       style: TextStyle(
                         fontSize: 16.0,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ],
                 ),
               ),
               SectionTitle(title: 'Find Tailor'),
               const SizedBox(height: 16.0),
               ElevatedButton(
                 onPressed: () {
                   Get.to(() => const TailorScreen());
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: colorScheme.primary,
                   foregroundColor: colorScheme.background,
                   minimumSize: const Size(double.infinity, 48.0), // Full width button
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12.0),
                   ),
                   elevation: 2.0,
                 ),
                 child: const Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.content_cut),
                     SizedBox(width: 8.0),
                     Text(
                       'Find a Tailor',
                       style: TextStyle(
                         fontSize: 16.0,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 24.0), // Spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
} 