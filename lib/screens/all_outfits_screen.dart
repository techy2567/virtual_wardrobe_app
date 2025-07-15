import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/outfit_model.dart';
import '../layouts/outfit_card.dart';
import 'outfit_details_screen.dart';
import '../controllers/controller_create_outfit.dart';
import '../providers/favorite_provider.dart';

class AllOutfitsScreen extends StatefulWidget {
  final String title;
  final bool showRecommended;
  const AllOutfitsScreen({Key? key, required this.title, this.showRecommended = false}) : super(key: key);

  @override
  State<AllOutfitsScreen> createState() => _AllOutfitsScreenState();
}

class _AllOutfitsScreenState extends State<AllOutfitsScreen> with SingleTickerProviderStateMixin {
  late Future<List<OutfitModel>> _outfitsFuture;
  late AnimationController _animController;
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All', 'Men', 'Women', 'Other', 'Summer', 'Winter', 'Spring', 'Autumn'
  ];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _outfitsFuture = fetchOutfits();
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animController.forward();
  }

  Future<List<OutfitModel>> fetchOutfits() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('outfits')
          .orderBy('createdAt', descending: true)
          .get();
      final all = snapshot.docs.map((doc) => OutfitModel.fromJson(doc.data(), documentId: doc.id)).toList();
      if (widget.showRecommended) {
        // Simple recommendation: filter by weather/season, can be improved
        final now = DateTime.now();
        return all.where((o) {
          // Example: recommend for current month/season
          final month = now.month;
          if (month >= 3 && month <= 5 && o.season.toLowerCase() == 'spring') return true;
          if (month >= 6 && month <= 8 && o.season.toLowerCase() == 'summer') return true;
          if (month >= 9 && month <= 11 && o.season.toLowerCase() == 'autumn') return true;
          if ((month == 12 || month == 1 || month == 2) && o.season.toLowerCase() == 'winter') return true;
          return false;
        }).toList();
      }
      return all;
    } catch (e) {
      print('Error fetching outfits: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorScheme.primaryContainer,
      ),
      backgroundColor: colorScheme.surface,
      body: FutureBuilder<List<OutfitModel>>(
        future: _outfitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Skeletonizer(
              enabled: true,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => Card(
                  child: Container(height: 140),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load outfits.'));
          }
          final outfits = snapshot.data ?? [];
          List<OutfitModel> filtered = outfits;
          if (_selectedFilter != 'All') {
            if (_selectedFilter == 'Men' || _selectedFilter == 'Women' || _selectedFilter == 'Other') {
              filtered = filtered.where((o) => (o.genderType ?? '').toLowerCase() == _selectedFilter.toLowerCase()).toList();
            } else {
              filtered = filtered.where((o) => (o.season).toLowerCase() == _selectedFilter.toLowerCase()).toList();
            }
          }
          if (_searchQuery.isNotEmpty) {
            filtered = filtered.where((o) =>
              o.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              o.clothingType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (o.description).toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }
          if (outfits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time_filled_outlined, size: 48, color: colorScheme.primary.withOpacity(0.5)),
                    SizedBox(height: 12),
                    Text(
                      'No outfits found',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.primary.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Try adding more outfits!',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search outfits... ',
                      prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: colorScheme.primary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final selected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (val) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        labelStyle: TextStyle(
                          color: selected ? colorScheme.background : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        checkmarkColor: selected ? colorScheme.background : colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ).marginSymmetric(horizontal: 16),
              ),
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<Set<String>>(
                  stream: FavoriteProvider().favoriteIdsStream,
                  builder: (context, favSnapshot) {
                    final favoriteIds = favSnapshot.data ?? <String>{};
                    if (filtered.isEmpty)
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time_filled_outlined, size: 48, color: colorScheme.primary.withOpacity(0.5)),
                            SizedBox(height: 12),
                            Text(
                              'No outfits found',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.primary.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try adding more outfits or change your\nsearch/filter!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final outfit = filtered[index];
                        final isFavorite = favoriteIds.contains(outfit.id);
                        return FutureBuilder<File?>(
                          future: ControllerCreateOutfit.getImageFileByIdStatic(outfit.imageId),
                          builder: (context, imgSnapshot) {
                            final imageFile = imgSnapshot.data;
                            final displayOutfit = outfit.copyWith(imageId: imageFile?.path ?? '');
                            return FadeTransition(
                              opacity: CurvedAnimation(parent: _animController, curve: Interval(0, 1, curve: Curves.easeIn)),
                              child: OutfitCard(
                                outfit: displayOutfit,
                                horizontal: true,
                                isFavorite: isFavorite,
                                onFavorite: () async {
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
                                },
                                onTap: () => Get.to(() => OutfitDetailsScreen(outfit: displayOutfit)),
                              ),
                            );
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