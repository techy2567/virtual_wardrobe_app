import 'package:flutter/material.dart';
import 'package:virtual_wardrobe_app/models/outfit_model.dart';
import 'dart:io';

class OutfitCard extends StatelessWidget {
  final OutfitModel outfit;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  const OutfitCard({Key? key, required this.outfit, this.onTap, this.isFavorite = false, this.onFavorite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                    image: DecorationImage(

                      image: outfit.imageId.isNotEmpty
                          ? FileImage(File(outfit.imageId,))
                          : AssetImage('assets/images/items/item1.jpeg') as ImageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outfit.clothingType,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outfit.season,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
