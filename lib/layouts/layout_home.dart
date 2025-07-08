import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:virtual_wardrobe_app/layouts/weather_card.dart';
import 'package:virtual_wardrobe_app/models/outfit_model.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/controller_create_outfit.dart';
import '../screens/create_outfit_screen.dart';
import '../screens/outfit_details_screen.dart';
import '../screens/weekly_challenge_screen.dart';
import '../widgets/outfit_card.dart';
import '../widgets/section_title.dart';
import '../controllers/controller_weather.dart';
import '../screens/all_outfits_screen.dart';
import '../providers/favorite_provider.dart';

class LayoutHome extends StatefulWidget {
  LayoutHome({super.key});

  @override
  State<LayoutHome> createState() => _LayoutHomeState();
}

class _LayoutHomeState extends State<LayoutHome> with TickerProviderStateMixin {
  late final AnimationController _weatherAnim;
  late final AnimationController _challengeAnim;
  late final AnimationController _outfitsAnim;
  late final AnimationController _itemsAnim;
  // Favorite state
  final Set<String> _favoriteTitles = {};
  late Future<List<OutfitModel>> _myOutfitsFuture;
  List<OutfitModel>? _cachedOutfits;
  late WeatherController weatherController;
  String _selectedFilter = 'All';
  String _selectedRecommendedFilter = 'All';
  final List<String> _filters = [
    'All', 'Men', 'Women', 'Other', 'Summer', 'Winter', 'Spring', 'Autumn'
  ];
  final List<String> _recommendedFilters = [
    'Recommended', 'My Outfits'
  ];

  @override
  void initState() {
    super.initState();
    _weatherAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _challengeAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _outfitsAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _itemsAnim = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _weatherAnim.forward();
    Future.delayed(Duration(milliseconds: 200), () => _challengeAnim.forward());
    Future.delayed(Duration(milliseconds: 400), () => _outfitsAnim.forward());
    Future.delayed(Duration(milliseconds: 600), () => _itemsAnim.forward());
    weatherController = Get.put(WeatherController());
    _myOutfitsFuture = fetchMyOutfits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = Get.arguments;
    if (args != null && args is Map && args['reload'] == true) {
      _refreshOutfits();
      // Optionally clear the argument to avoid repeated reloads
      // Get.arguments = null;
    }
  }

  @override
  void dispose() {
    _weatherAnim.dispose();
    _challengeAnim.dispose();
    _outfitsAnim.dispose();
    _itemsAnim.dispose();
    super.dispose();
  }

  Future<List<OutfitModel>> fetchMyOutfits() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('outfits')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => OutfitModel.fromJson(doc.data(), documentId: doc.id)).toList();
    } catch (e) {
      print('Error fetching outfits: $e');
      return [];
    }
  }

  Future<void> _refreshOutfits() async {
    setState(() {
      _myOutfitsFuture = fetchMyOutfits();
      _cachedOutfits = null;
    });
    await weatherController.getCurrentLocationAndFetchWeather();
  }

  List<OutfitModel> getRecommendedOutfits(List<OutfitModel> outfits) {
    final temp = weatherController.weatherData.value?.temperature ?? 0.0;
    // Example: recommend outfits for current temperature
    return outfits.where((o) {
      if (o.weatherRange.contains('Hot') && temp > 25) return true;
      if (o.weatherRange.contains('Warm') && temp > 15 && temp <= 25) return true;
      if (o.weatherRange.contains('Cold') && temp < 10) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favoriteIdsStream = FavoriteProvider().favoriteIdsStream;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        Get.to(CreateOutfitScreen());
      }, child: Icon(Icons.add),),

      appBar: AppBar(
        title: Text(
          'Virtual Wardrobe',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 1,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.calendar_month, color: colorScheme.primary, size: 28),
        //     onPressed: () {},
        //     tooltip: 'Calendar',
        //   ),
        // ],
      ),
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _refreshOutfits,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Weather Section with animation
                          AnimatedBuilder(
                            animation: _weatherAnim,
                            builder: (context, child) => Opacity(
                              opacity: _weatherAnim.value,
                              child: Transform.translate(
                                offset: Offset(0, 40 * (1 - _weatherAnim.value)),
                                child: child,
                              ),
                            ),
                            child: SizedBox(height: 205, child: const WeatherCard()),
                          ),
                          const SizedBox(height: 24.0),
                          // Weekly Challenge Card with glassmorphism and animation
                          AnimatedBuilder(
                            animation: _challengeAnim,
                            builder: (context, child) => Opacity(
                              opacity: _challengeAnim.value,
                              child: Transform.translate(
                                offset: Offset(0, 40 * (1 - _challengeAnim.value)),
                                child: child,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Glassmorphism background
                                  BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary.withOpacity(0.70),
                                            colorScheme.primary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.18),
                                            blurRadius: 12,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => Get.to(() => const WeeklyChallengeScreen()),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
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
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1.1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Create 5 sustainable outfits this week!',
                                                    style: TextStyle(
                                                      color: colorScheme.onPrimary.withOpacity(0.92),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: colorScheme.onPrimary.withOpacity(0.18),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.emoji_events,
                                                color: colorScheme.onPrimary,
                                                size: 34,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          FutureBuilder<List<OutfitModel>>(
                            future: _myOutfitsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Skeletonizer(
                                  enabled: true,
                                  child: SizedBox(
                                    height: 310,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 3,
                                      separatorBuilder: (_, __) => SizedBox(width: 16),
                                      itemBuilder: (context, index) => SizedBox(
                                        width: 180,
                                        child: OutfitCard(
                                          outfit: OutfitModel(
                                            id: '',
                                            userId: '',
                                            title: '',
                                            description: '',
                                            imageId: '',
                                            categories: [''],
                                            clothingType: '',
                                            weatherRange: '',
                                            season: '',
                                            isFavorite: false,
                                            isDonated: false,
                                            createdAt: DateTime.now(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Failed to load outfits.'));
                              }
                              final outfits = snapshot.data ?? [];
                              // My Outfits filtering
                              List<OutfitModel> filteredOutfits = outfits;
                              if (_selectedFilter != 'All') {
                                if (_selectedFilter == 'Men' || _selectedFilter == 'Women' || _selectedFilter == 'Other') {
                                  filteredOutfits = outfits.where((o) => (o.genderType ?? '').toLowerCase() == _selectedFilter.toLowerCase()).toList();
                                } else {
                                  filteredOutfits = outfits.where((o) => (o.season).toLowerCase() == _selectedFilter.toLowerCase()).toList();
                                }
                              }
                              // Recommended Outfits filtering
                              List<OutfitModel> recommended = getRecommendedOutfits(outfits);
                              List<OutfitModel> filteredRecommended = recommended;
                              if (_selectedRecommendedFilter != 'All') {
                                if (_selectedRecommendedFilter == 'Men' || _selectedRecommendedFilter == 'Women' || _selectedRecommendedFilter == 'Other') {
                                  filteredRecommended = recommended.where((o) => (o.genderType ?? '').toLowerCase() == _selectedRecommendedFilter.toLowerCase()).toList();
                                } else {
                                  filteredRecommended = recommended.where((o) => (o.season).toLowerCase() == _selectedRecommendedFilter.toLowerCase()).toList();
                                }
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SectionTitle(
                                        key: Key('recommendedOutfitsTitle'),
                                        title: 'Recommended Outfits',
                                        onAddPressed: null,
                                        onViewAllPressed: null,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.to(() => AllOutfitsScreen(
                                            title: 'Recommended Outfits',
                                            showRecommended: true,
                                          ));
                                        },
                                        child: Row(
                                          children: [
                                            Text('See All ', style: TextStyle(fontWeight: FontWeight.bold)),
                                            // Icon(Icons.arrow_forward_ios, size: 12),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Filter Chips for Recommended Outfits
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _filters.map((filter) {
                                        final selected = _selectedRecommendedFilter == filter;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: ChoiceChip(
                                            label: Text(filter),
                                            selected: selected,
                                            onSelected: (val) {
                                              setState(() {
                                                _selectedRecommendedFilter = filter;
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
                                    ),
                                  ),
                                  const SizedBox(height: 18.0),
                                  // Recommended Outfits List
                                  if (filteredRecommended.isEmpty)
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.recommend, size: 48, color: colorScheme.primary.withOpacity(0.5)),
                                          SizedBox(height: 12),
                                          Text(
                                            'No recommended outfits',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: colorScheme.primary.withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Try adding more outfits for better recommendations.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.primary.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 310,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredRecommended.length,
                                        separatorBuilder: (_, __) => SizedBox(width: 16),
                                        itemBuilder: (context, index) {
                                          final outfit = filteredRecommended[index];
                                          return FutureBuilder<File?>(
                                            future: ControllerCreateOutfit.getImageFileByIdStatic(outfit.imageId),
                                            builder: (context, imgSnapshot) {
                                              final imageFile = imgSnapshot.data;
                                              return SizedBox(
                                                width: 180,
                                                child: OutfitCard(
                                                  outfit: outfit.copyWith(imageId: imageFile?.path ?? ''),
                                                  onTap: () => Get.to(() => OutfitDetailsScreen(outfit: outfit.copyWith(imageId: imageFile?.path ?? ''))),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 28.0),
                                  // Filter Chips

                                  // My Outfits Section Title
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SectionTitle(
                                        key: Key('myOutfitsTitle'),
                                        title: 'My Outfits',
                                        onAddPressed: null,
                                        onViewAllPressed: null,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.to(() => AllOutfitsScreen(
                                            title: 'My Outfits',
                                            showRecommended: false,
                                          ));
                                        },
                                        child: Row(
                                          children: [
                                            Text('See All', style: TextStyle(fontWeight: FontWeight.bold)),
                                            // Icon(Icons.arrow_forward_ios, size: 16),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Filter Chips for My Outfits
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
                                    ),
                                  ),
                                  const SizedBox(height: 18.0),
                                  // My Outfits List
                                  if (filteredOutfits.isEmpty)
                                    Center(
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
                                            'Tap + to add your first outfit!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.primary.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 310,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: filteredOutfits.length,
                                        separatorBuilder: (_, __) => SizedBox(width: 16),
                                        itemBuilder: (context, index) {
                                          final outfit = filteredOutfits[index];
                                          return FutureBuilder<File?>(
                                            future: ControllerCreateOutfit.getImageFileByIdStatic(outfit.imageId),
                                            builder: (context, imgSnapshot) {
                                              final imageFile = imgSnapshot.data;
                                              return SizedBox(
                                                width: 180,
                                                child: OutfitCard(
                                                  outfit: outfit.copyWith(imageId: imageFile?.path ?? ''),
                                                  onTap: () => Get.to(() => OutfitDetailsScreen(outfit: outfit.copyWith(imageId: imageFile?.path ?? ''))),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 28.0),
                                  // Recommended Outfits Section Title

                                ],
                              );
                            },
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
