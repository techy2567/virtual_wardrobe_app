import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:virtual_wardrobe_app/controllers/virtual_try_on_controller.dart';
import 'package:virtual_wardrobe_app/models/outfit_model.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:virtual_wardrobe_app/screens/donation_screen.dart';
import 'package:virtual_wardrobe_app/screens/tailor_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_wardrobe_app/screens/virtual_try_on_screen.dart';
import '../providers/favorite_provider.dart';
import 'package:virtual_wardrobe_app/controllers/controller_create_outfit.dart';
import 'package:virtual_wardrobe_app/screens/home_screen.dart';
// import 'package:virtual_wardrobe_app/screens/virtual_tryon_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OutfitDetailsScreen extends StatelessWidget {
  final OutfitModel? outfit;
   OutfitDetailsScreen({Key? key, this.outfit}) : super(key: key);

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
  Rx<File?> imageFile = Rx<File?>(null);
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    if (outfit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Outfit not found.')),
      );
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('User not logged in.')),
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('outfits')
          .doc(outfit!.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Outfit not found.')),
          );
        }
        final data = snapshot.data!.data()!;
        final liveOutfit = OutfitModel.fromJson(data, documentId: outfit!.id);
        final String title = liveOutfit.title;
        final String description = liveOutfit.description;
        final String category = liveOutfit.categories.join(', ');
        final String clothingType = liveOutfit.clothingType;
        final String weather = liveOutfit.weatherRange;
        final String season = liveOutfit.season;
        final String donated = liveOutfit.isDonated ? 'Yes' : 'No';
        final String created = dateFormat.format(liveOutfit.createdAt);
        // Instead of using imageProvider directly, resolve the local file path
        return FutureBuilder<File?>(
          future: ControllerCreateOutfit.getImageFileByIdStatic(liveOutfit.imageId),
          builder: (context, imgSnapshot) {
            final file = imgSnapshot.data;
            imageFile.value = file;
            final imageProvider = (file != null && file.existsSync())
                ? FileImage(file) as ImageProvider
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
                      final isFavorite = favoriteIds.contains(liveOutfit.id);
                      return IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : colorScheme.primary),
                        onPressed: () => _toggleFavorite(context, isFavorite),
                        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      ).marginOnly(right: 10);
                    },
                  ),
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
                            outfitId: liveOutfit.id,
                            userId: user.uid,
                            imageId: liveOutfit.imageId,
                          );
                          if (success) {
                            Get.snackbar('Deleted', 'Outfit deleted successfully.');
                            Get.offAll(() => HomeScreen(), arguments: {'reload': true});
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
              backgroundColor: colorScheme.background,
              body: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Fullscreen Image with Hero animation and Donated badge overlay
                  Hero(
                    tag: 'outfit_image_${liveOutfit.id}',
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            width: double.infinity,
                            height: Get.height * .6,
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
                          if (liveOutfit.isDonated)
                            Positioned(
                              top: 24,
                              left: 24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text('Donated', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                        ],
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: (liveOutfit.isDonated) ? null : () async {
                                      await Get.to(() => DonationScreen(outfitId: liveOutfit.id));
                                    },
                                    icon: Icon(liveOutfit.isDonated ? Icons.check : Icons.volunteer_activism),
                                    label: Text(liveOutfit.isDonated ? 'Donated' : 'Donate Clothes'),
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
                              ],
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: (outfit == null || outfit!.imageId.isEmpty) ? null : () async {
                                // final imageId = outfit!.imageId;
                                // final file = await ControllerCreateOutfit.getImageFileByIdStatic(imageId);
                                if (imageFile.value != null && await imageFile.value!.exists()) {
                                  Get.put(VirtualTryOnController())..clearData();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VirtualTryOnScreen(
                                        productImagePath: imageFile.value!,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Outfit image file not found.')),
                                  );
                                }
                              },
                              icon: Icon(Icons.camera_front),
                              label: Text('Virtual Try-On'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.surface,
                                minimumSize: const Size(double.infinity, 48.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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