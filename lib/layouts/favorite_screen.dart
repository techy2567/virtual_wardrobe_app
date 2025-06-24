import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../screens/outfit_details_screen.dart';
import '../widgets/outfit_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  Stream<List<OutfitModel>> favoriteOutfitsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourite')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        OutfitModel.fromJson(doc.data(), documentId: doc.id),
                  )
                  .toList(),
        );
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
        title: const Text('Favorite Outfits'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      backgroundColor: colorScheme.surface,
      body: StreamBuilder<List<OutfitModel>>(
        stream: favoriteOutfitsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Skeletonizer(
                enabled: true,
                child: ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Container(
                            color: Colors.white,
                            width: 120,
                            height: 140,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 80,
                                    height: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 60,
                                    height: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 50,
                                    height: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }
          final outfits = snapshot.data ?? [];
          if (outfits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No favorites found',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Browse outfits and tap the heart icon to add them here!',
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: outfits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final outfit = outfits[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OutfitDetailsScreen()),
                    );
                  },
                  child: OutfitCard(
                    outfit: outfit,
                    horizontal: true,
                    isFavorite: true,
                    onFavorite: () => toggleFavorite(outfit, true),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
