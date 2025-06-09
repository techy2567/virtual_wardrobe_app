import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/widgets/section_title.dart'; // Assuming SectionTitle is in widgets
import 'package:virtual_wardrobe_app/widgets/item_card.dart'; // Import ItemCard

class CreateOutfitScreen extends StatefulWidget {
  const CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  // State variables for selected options
  int _selectedWeatherIndex = -1; // -1 means no weather selected
  int _selectedCategoryIndex = -1; // -1 means no category selected

  // Dummy data based on the image
   final List<String> _itemFilters = ['All (12)', 'Classic (14)', 'Sport (24)', /* Add other filters from image if needed */];
   final List<Map<String, dynamic>> _dummyItems = [
      { 'imageUrl': 'https://via.placeholder.com/100/A9A9A9', 'title': 'Brown Jacket' },
      { 'imageUrl': 'https://via.placeholder.com/100/D3D3D3', 'title': 'Camel Shirt' },
      // Add other dummy items as needed
    ];

  final List<Map<String, dynamic>> _weatherOptions = [
    {'range': '-30° to -20°', 'condition': 'Extra cold'},
    {'range': '-20° to -10°', 'condition': 'Very cold'},
    {'range': '-10° to 0°', 'condition': 'Cold'},
    {'range': '0° to +10°', 'condition': 'Chilly'},
    {'range': '+10° to +20°', 'condition': 'Warm'},
    {'range': '+20° to +30°', 'condition': 'Hot'},
  ];

  final List<String> _categoryOptions = ['Classic', 'Sport', 'Casual', 'Festive', 'Home', 'Outside'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary), // Back arrow
          onPressed: () {
            Get.back(); // Navigate back using GetX
          },
        ),
        title: Text(
          'Create Outfit', // Title from image
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold), // Dark navy color
        ),
        backgroundColor: colorScheme.background, // Light beige background
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: colorScheme.primary), // Checkmark icon
            onPressed: () {
              // TODO: Implement save outfit logic
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
                child: Container(
                  height: 400, // Increased height to accommodate multiple images
                  width: double.infinity,
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      // Image upload sections
                      Expanded(
                        child: Row(
                          children: [
                            // Top section
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 32,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Top',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Center section
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 32,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Center',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Bottom section
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 32,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Bottom',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Image requirements text
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Image requirements: Max size 1MB, PNG format recommended for background removal',
                          style: TextStyle(
                            color: colorScheme.primary.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Select Items Section
              SectionTitle(
                title: 'Select Items',
                 trailingText: '(${_dummyItems.length})', // Dynamic count
                onAddPressed: () {
                   // TODO: Implement add item to outfit logic
                 },
              ),
              const SizedBox(height: 16.0),
               // Filter chips
               SizedBox(
                 height: 40.0, // Adjust height for chips
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: _itemFilters.length,
                   itemBuilder: (context, index) {
                     final filterText = _itemFilters[index];
                     // Reuse filter button styling from MyOutfitsScreen
                     return Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 4.0), // Spacing between chips
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
                           padding: const EdgeInsets.symmetric(horizontal: 12.0), // Adjust padding
                         ),
                         child: Text(filterText),
                       ),
                     );
                   },
                 ),
               ),
               const SizedBox(height: 16.0),
               // Horizontal item list
               SizedBox(
                 height: 140, // Adjust height as needed for item cards, matching OutfitDetailsScreen
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: _dummyItems.length,
                   itemBuilder: (context, index) {
                     final item = _dummyItems[index];
                     return Padding(
                       padding: const EdgeInsets.only(right: 16.0), // Spacing between cards
                       child: SizedBox(
                         width: 100, // Explicit width for item card, matching OutfitDetailsScreen
                         child: ItemCard(
                           imageUrl: item['imageUrl'],
                           title: item['title'],
                         ),
                       ),
                     );
                   },
                 ),
               ),
              const SizedBox(height: 24.0),

              // Select Weather Section
              SectionTitle(title: 'Select Weather'),
              const SizedBox(height: 16.0),
               // Weather selection buttons grid
               GridView.builder(
                 shrinkWrap: true, // Use shrinkWrap in Column
                 physics: NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2, // 2 buttons per row
                   crossAxisSpacing: 16.0, // Spacing between columns
                   mainAxisSpacing: 16.0, // Spacing between rows
                   childAspectRatio: 2.5, // Adjust aspect ratio of buttons
                 ),
                 itemCount: _weatherOptions.length,
                 itemBuilder: (context, index) {
                   final option = _weatherOptions[index];
                   final isSelected = _selectedWeatherIndex == index;
                   return ElevatedButton(
                     onPressed: () {
                       setState(() {
                         _selectedWeatherIndex = index;
                       });
                        // TODO: Handle weather selection logic
                     },
                      style: ElevatedButton.styleFrom(
                         backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface, // Highlight selected button
                         foregroundColor: isSelected ? colorScheme.background : colorScheme.primary, // Text color
                         shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                           side: BorderSide(color: colorScheme.primary.withOpacity(0.5)) // Border
                        ),
                        elevation: isSelected ? 2.0 : 0,
                         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Adjust padding
                       ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(
                           option['range'],
                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                         ),
                         Text(
                           option['condition'],
                            style: TextStyle(fontSize: 12, color: isSelected ? colorScheme.background.withOpacity(0.8) : colorScheme.primary.withOpacity(0.7)),
                         ),
                       ],
                     ),
                   );
                 },
               ),
              const SizedBox(height: 24.0),

              // Select Category Section
              SectionTitle(
                title: 'Select Category',
                onAddPressed: () {
                   // TODO: Implement add custom category logic
                 },
              ),
              const SizedBox(height: 16.0),
               // Category selection buttons grid
               GridView.builder(
                 shrinkWrap: true, // Use shrinkWrap in Column
                 physics: NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2, // 2 buttons per row
                   crossAxisSpacing: 16.0, // Spacing between columns
                   mainAxisSpacing: 16.0, // Spacing between rows
                    childAspectRatio: 2.5, // Adjust aspect ratio of buttons
                 ),
                 itemCount: _categoryOptions.length,
                 itemBuilder: (context, index) {
                   final category = _categoryOptions[index];
                    final isSelected = _selectedCategoryIndex == index;
                   return ElevatedButton(
                     onPressed: () {
                       setState(() {
                         _selectedCategoryIndex = index;
                       });
                        // TODO: Handle category selection logic
                     },
                      style: ElevatedButton.styleFrom(
                         backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface, // Highlight selected button
                         foregroundColor: isSelected ? colorScheme.background : colorScheme.primary, // Text color
                         shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                           side: BorderSide(color: colorScheme.primary.withOpacity(0.5)) // Border
                        ),
                        elevation: isSelected ? 2.0 : 0,
                         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Adjust padding
                       ),
                     child: Text(
                       category,
                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                     ),
                   );
                 },
               ),
               const SizedBox(height: 24.0), // Spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
} 