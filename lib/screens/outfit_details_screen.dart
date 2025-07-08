import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/models/outfit_model.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:virtual_wardrobe_app/screens/donation_screen.dart';
import 'package:virtual_wardrobe_app/screens/tailor_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/favorite_provider.dart';
import 'package:virtual_wardrobe_app/controllers/controller_create_outfit.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
import 'package:virtual_wardrobe_app/screens/virtual_tryon_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OutfitDetailsScreen extends StatelessWidget {
  final OutfitModel? outfit;
  const OutfitDetailsScreen({Key? key, this.outfit}) : super(key: key);

  Future<void> _toggleFavorite(BuildContext context, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || outfit == null) return;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourite')
        .doc(outfit!.id);
    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set(outfit!.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    // Fallbacks if outfit is null
    final String title = outfit?.title ?? 'Outfit Title';
    final String description = outfit?.description ?? 'No description available.';
    final String category = outfit?.categories.join(', ') ?? 'N/A';
    final String clothingType = outfit?.clothingType ?? 'N/A';
    final String weather = outfit?.weatherRange ?? 'N/A';
    final String season = outfit?.season ?? 'N/A';
    final String donated = (outfit?.isDonated ?? false) ? 'Yes' : 'No';
    final String created = outfit != null ? dateFormat.format(outfit!.createdAt) : dateFormat.format(DateTime.now());

    final imageProvider = outfit?.imageId != null && outfit?.imageId != ''
        ? FileImage(File(outfit!.imageId)) as ImageProvider
        : AssetImage('assets/images/items/item1.jpeg');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        actions: [
          StreamBuilder<Set<String>>(
            stream: FavoriteProvider().favoriteIdsStream,
            builder: (context, favSnapshot) {
              final favoriteIds = favSnapshot.data ?? <String>{};
              final isFavorite = outfit != null && favoriteIds.contains(outfit!.id);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : colorScheme.primary),
                onPressed: () => _toggleFavorite(context, isFavorite),
                tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ).marginOnly(right: 10);
            },
          ),
          if (outfit != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Outfit',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Outfit'),
                    content: Text('Are you sure you want to delete this outfit? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final success = await ControllerCreateOutfit.deleteOutfit(
                      outfitId: outfit!.id,
                      userId: user.uid,
                      imageId: outfit!.imageId,
                    );
                    if (success) {
                      Get.snackbar('Deleted', 'Outfit deleted successfully.');
                      // Go to HomeScreen and trigger reload
                      Get.offAll(() => HomeScreen(), arguments: {'reload': true});
                    }
                  }
                }
              },
            ),
          // IconButton(
          //   icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
          //   onPressed: () {
          //     // TODO: Implement edit outfit logic
          //   },
          // ),
        ],
      ),                                                                                
      backgroundColor: colorScheme.background,
      body: Stack(
        alignment: Alignment.topCenter, 

        children: [
          // Fullscreen Image with Hero animation
          Hero(
            tag: 'outfit_image_${outfit?.id ?? 'default'}',
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: Get.height*.6,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.background.withOpacity(0.92),
                      ],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Details Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: Offset(0, 0),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.10),
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _InfoChip(label: 'Category', value: category),
                        _InfoChip(label: 'Clothing Type', value: clothingType),
                        _InfoChip(label: 'Weather', value: weather),
                        _InfoChip(label: 'Season', value: season),
                        _InfoChip(label: 'Donated', value: donated),
                        _InfoChip(label: 'Created', value: created),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (outfit == null || (outfit?.isDonated ?? false)) ? null : () async {
                              await Get.to(() => DonationScreen(outfitId: outfit!.id));
                              // Optionally, trigger a UI refresh here if needed
                            },
                            icon: Icon((outfit?.isDonated ?? false) ? Icons.check : Icons.volunteer_activism),
                            label: Text((outfit?.isDonated ?? false) ? 'Donated' : 'Donate Clothes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.background,
                              minimumSize: const Size(double.infinity, 48.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.to(() => const TailorScreen()),
                            icon: Icon(Icons.content_cut),
                            label: Text('Find a Tailor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.background,
                              minimumSize: const Size(double.infinity, 48.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: outfit == null ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VirtualTryOnScreen(
                                    outfitImagePath: outfit!.imageId,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.camera_front),
                            label: Text('Virtual Try-On'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.background,
                              minimumSize: const Size(double.infinity, 48.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text('$label: $value', style: TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
} 