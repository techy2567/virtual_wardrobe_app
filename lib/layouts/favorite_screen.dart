import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/outfit_details_screen.dart';
import '../widgets/outfit_card.dart';

class FavoriteController extends GetxController {
  RxSet<String> favoriteTitles = <String>{}.obs;
  RxList<Map<String, dynamic>> favoriteOutfits = <Map<String, dynamic>>[ // Dummy data for now
    {
      'imageUrl': 'https://via.placeholder.com/150/FFD700',
      'title': 'Golden Night',
      'colors': [Colors.amber, Colors.black, Colors.white],
    },
    {
      'imageUrl': 'https://via.placeholder.com/150/8A2BE2',
      'title': 'Purple Dream',
      'colors': [Colors.purple, Colors.deepPurple, Colors.white],
    },
    {
      'imageUrl': 'https://via.placeholder.com/150/00CED1',
      'title': 'Aqua Breeze',
      'colors': [Colors.cyan, Colors.teal, Colors.white],
    },
  ].obs;

  void toggleFavorite(String title) {
    if (favoriteTitles.contains(title)) {
      favoriteTitles.remove(title);
    } else {
      favoriteTitles.add(title);
    }
  }
}

class FavoriteScreen extends StatelessWidget {
  FavoriteScreen({Key? key}) : super(key: key);
  final FavoriteController controller = Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Outfits'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      backgroundColor: colorScheme.surface,
      body: Obx(() => controller.favoriteOutfits.isEmpty
          ? Center(child: Text('No favorites yet.', style: TextStyle(color: colorScheme.primary)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: controller.favoriteOutfits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final outfit = controller.favoriteOutfits[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OutfitDetailsScreen(),
                        ),
                      );
                    },
                    child: OutfitCard(
                      imageUrl: outfit['imageUrl'],
                      title: outfit['title'],
                      colors: outfit['colors'],
                      isFavorite: controller.favoriteTitles.contains(outfit['title']),
                      onFavorite: () => controller.toggleFavorite(outfit['title']),
                    ),
                  );
                },
              ),
            )),
    );
  }
} 