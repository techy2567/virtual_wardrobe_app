import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:virtual_wardrobe_app/layouts/weather_card.dart';
import 'dart:ui';

import '../screens/create_outfit_screen.dart';
import '../screens/myoutfits_screen.dart';
import '../screens/outfit_details_screen.dart';
import '../screens/weekly_challenge_screen.dart';
import '../widgets/item_card.dart';
import '../widgets/outfit_card.dart';
import '../widgets/section_title.dart';
import '../controllers/controller_weather.dart';

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
  }

  @override
  void dispose() {
    _weatherAnim.dispose();
    _challengeAnim.dispose();
    _outfitsAnim.dispose();
    _itemsAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final WeatherController weatherController = Get.put(WeatherController());
    // Dummy data for demonstration
    final List<Map<String, dynamic>> dummyOutfits = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FF0000', // Placeholder image URL
        'title': 'Casual',
        'colors': [Colors.brown, Colors.grey, Colors.blueGrey, Colors.black, Colors.blue],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/00FF00', // Placeholder image URL
        'title': 'Classic',
        'colors': [Colors.brown, Colors.blueGrey, Colors.green, Colors.brown, Colors.amber],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/0000FF', // Placeholder image URL
        'title': 'Sporty',
        'colors': [Colors.red, Colors.white, Colors.black],
      },
    ];
    // Recommended Outfits dummy data
    final List<Map<String, dynamic>> recommendedOutfits = [
      {
        'imageUrl': 'https://via.placeholder.com/150/FF5733',
        'title': 'Holiday',
        'colors': [Colors.red, Colors.green, Colors.white, Colors.yellow],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/33FF57',
        'title': 'Evening',
        'colors': [Colors.black, Colors.red, Colors.grey],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/3357FF',
        'title': 'Summer',
        'colors': [Colors.yellow, Colors.blue, Colors.white],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/FF33FF',
        'title': 'Trendy',
        'colors': [Colors.purple, Colors.pink, Colors.white],
      },
      {
        'imageUrl': 'https://via.placeholder.com/150/33FFFF',
        'title': 'Winter',
        'colors': [Colors.blueGrey, Colors.white, Colors.black],
      },
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        Get.to(CreateOutfitScreen());
      }, child: Icon(Icons.add),),

      appBar: AppBar(
        title: Text(
          'Outfits Calendar',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: colorScheme.primary, size: 28),
            onPressed: () {},
            tooltip: 'Calendar',
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              await weatherController.getCurrentLocationAndFetchWeather();
            },
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
                                            colorScheme.primary.withOpacity(0.25),
                                            colorScheme.primary.withOpacity(0.45),
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
                          const SizedBox(height: 28.0),
                          // My Outfits Section Title
                          SectionTitle(
                            key: Key('myOutfitsTitle'),
                            title: 'My Outfits',
                            onAddPressed: () {},
                            onViewAllPressed: () {},
                          ),
                          const SizedBox(height: 18.0),
                          // Outfits List with animation
                          AnimatedBuilder(
                            animation: _itemsAnim,
                            builder: (context, child) => Opacity(
                              opacity: _itemsAnim.value,
                              child: Transform.translate(
                                offset: Offset(0, 40 * (1 - _itemsAnim.value)),
                                child: child,
                              ),
                            ),
                            child: SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendedOutfits.length,
                                itemBuilder: (context, index) {
                                  final outfit = recommendedOutfits[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => OutfitDetailsScreen(),
                                          ),
                                        );
                                      },
                                      child: AnimatedScale(
                                        scale: 1.0,
                                        duration: Duration(milliseconds: 180),
                                        child: SizedBox(
                                          width: 130,
                                          child: OutfitCard(
                                            imageUrl: outfit['imageUrl'],
                                            title: outfit['title'],
                                            colors: outfit['colors'],
                                            isFavorite: _favoriteTitles.contains(outfit['title']),
                                            onFavorite: () {
                                              setState(() {
                                                if (_favoriteTitles.contains(outfit['title'])) {
                                                  _favoriteTitles.remove(outfit['title']);
                                                } else {
                                                  _favoriteTitles.add(outfit['title']);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 28.0),
                          // Recommended Outfits Section Title
                          SectionTitle(
                            key: Key('recommendedOutfitsTitle'),
                            title: 'Recommended Outfits',
                            onAddPressed: null,
                            onViewAllPressed: null,
                          ),
                          const SizedBox(height: 18.0),
                          // Recommended Outfits List with animation
                          AnimatedBuilder(
                            animation: _itemsAnim,
                            builder: (context, child) => Opacity(
                              opacity: _itemsAnim.value,
                              child: Transform.translate(
                                offset: Offset(0, 40 * (1 - _itemsAnim.value)),
                                child: child,
                              ),
                            ),
                            child: SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendedOutfits.length,
                                itemBuilder: (context, index) {
                                  final outfit = recommendedOutfits[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => OutfitDetailsScreen(),
                                          ),
                                        );
                                      },
                                      child: AnimatedScale(
                                        scale: 1.0,
                                        duration: Duration(milliseconds: 180),
                                        child: SizedBox(
                                          width: 130,
                                          child: OutfitCard(
                                            imageUrl: outfit['imageUrl'],
                                            title: outfit['title'],
                                            colors: outfit['colors'],
                                            isFavorite: _favoriteTitles.contains(outfit['title']),
                                            onFavorite: () {
                                              setState(() {
                                                if (_favoriteTitles.contains(outfit['title'])) {
                                                  _favoriteTitles.remove(outfit['title']);
                                                } else {
                                                  _favoriteTitles.add(outfit['title']);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32.0),
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
