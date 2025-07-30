import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/outfit_model.dart';
import '../layouts/outfit_card.dart';
import 'create_outfit_screen.dart';
import 'outfit_details_screen.dart';
import '../providers/favorite_provider.dart';

class MyOutfitsScreen extends StatefulWidget {
  const MyOutfitsScreen({super.key});

  @override
  State<MyOutfitsScreen> createState() => _MyOutfitsScreenState();
}

class _MyOutfitsScreenState extends State<MyOutfitsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    // Categories
    'Classic', 'Home', 'Outside', 'Casual', 'Sport', 'Festive',
    // Seasons
    'Summer', 'Winter', 'Spring', 'Autumn',
    // Clothing Types (most common)
    'Shirt', 'Pant', 'Dress', 'Jacket', 'Sweater', 'T-shirt', 'Jeans', 'Suit',
    // Gender
    'Men', 'Women', 'Other'
  ];

  // Enhanced filtering function that checks multiple criteria
  List<OutfitModel> filterOutfits(List<OutfitModel> outfits, String selectedFilter) {
    if (selectedFilter == 'All') {
      return outfits;
    }
    
    // Handle gender-based filtering
    if (selectedFilter == 'Men' || selectedFilter == 'Women' || selectedFilter == 'Other') {
      return outfits.where((o) => 
        (o.genderType ?? '').toLowerCase() == selectedFilter.toLowerCase()
      ).toList();
    }
    
    // Enhanced filtering for clothing type, category, and season
    return outfits.where((o) {
      final filterLower = selectedFilter.toLowerCase();
      
      // Check clothing type
      final clothingTypeMatch = o.clothingType.toLowerCase().contains(filterLower);
      
      // Check categories (outfit can have multiple categories)
      final categoryMatch = o.categories.any((category) => 
        category.toLowerCase().contains(filterLower)
      );
      
      // Check season
      final seasonMatch = o.season.toLowerCase().contains(filterLower);
      
      // Return true if ANY of the criteria match (OR logic)
      return clothingTypeMatch || categoryMatch || seasonMatch;
    }).toList();
  }

  Stream<List<OutfitModel>> outfitsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('outfits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OutfitModel.fromJson(doc.data(), documentId: doc.id)).toList());
  }

  Future<void> toggleFavorite(OutfitModel outfit, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourite')
        .doc(outfit.id);
    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set(outfit.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Outfits'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.background,
      ),
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CreateOutfitScreen()),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.background),
        tooltip: 'Add Outfit',
      ),
      body: StreamBuilder<List<OutfitModel>>(
        stream: outfitsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Skeletonizer(
              enabled: true,
              child: Column(
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
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8),
                      itemBuilder: (context, index) => Container(
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => Card(
                        child: Container(height: 200),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load outfits.'));
          }
          
          final outfits = snapshot.data ?? [];
          final filteredOutfits = filterOutfits(outfits, _selectedFilter);

          return Column(
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
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surface,
                      labelStyle: TextStyle(
                        color: selected ? colorScheme.background : colorScheme.primary,
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
                child: filteredOutfits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.style, size: 64, color: colorScheme.primary.withOpacity(0.2)),
                            SizedBox(height: 12),
                            Text(
                              outfits.isEmpty ? 'No outfits found' : 'No outfits match the filter',
                              style: TextStyle(fontSize: 18, color: colorScheme.primary.withOpacity(0.7))
                            ),
                            SizedBox(height: 8),
                            Text(
                              outfits.isEmpty ? 'Tap + to add your first outfit!' : 'Try changing the filter',
                              style: TextStyle(fontSize: 14, color: colorScheme.primary.withOpacity(0.5))
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<Set<String>>(
                        stream: FavoriteProvider().favoriteIdsStream,
                        builder: (context, favSnapshot) {
                          final favoriteIds = favSnapshot.data ?? <String>{};
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: filteredOutfits.length,
                            itemBuilder: (context, index) {
                              final outfit = filteredOutfits[index];
                              return OutfitCard(
                                outfit: outfit,
                                isFavorite: favoriteIds.contains(outfit.id),
                                onTap: () {
                                  Get.to(() => OutfitDetailsScreen(outfit: outfit));
                                },
                                onFavorite: () async {
                                  final isFavorite = favoriteIds.contains(outfit.id);
                                  await toggleFavorite(outfit, isFavorite);
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
} 