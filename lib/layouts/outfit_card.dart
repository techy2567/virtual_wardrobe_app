import 'package:flutter/material.dart';
import 'package:virtual_wardrobe_app/models/outfit_model.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OutfitCard extends StatefulWidget {
  final OutfitModel outfit;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final bool horizontal;
  const OutfitCard({Key? key, required this.outfit, this.onTap, this.isFavorite = false, this.onFavorite, this.horizontal = false}) : super(key: key);

  @override
  State<OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<OutfitCard> {
  bool _loadingFavorite = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget buildImage(String imageId, {double? width, double? height}) {
      if (widget.outfit.imageId.isEmpty) {
        return Image.asset(
          'assets/images/items/item1.jpeg',
          fit: BoxFit.contain,
          width: width,
          height: height,
        );
      }
      else if (imageId.startsWith('http')) {
        // Firebase Storage URL, add cache busting param
        final cacheBustedUrl = imageId + '?v= [1m{DateTime.now().millisecondsSinceEpoch}';
        return Image.network(
          cacheBustedUrl,
          fit: BoxFit.contain,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/items/item1.jpeg',
            fit: BoxFit.contain,
            width: width,
            height: height,
          ),
        );
      } else {
        // Local file
        return Image.file(
          File(imageId),
          fit: BoxFit.contain,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/items/item1.jpeg',
            fit: BoxFit.contain,
            width: width,
            height: height,
          ),
        );
      }
    }
    if (widget.horizontal) {
      // Horizontal card for FavoriteScreen
      return GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20.0)),
                child: Container(
                  color: Colors.white,
                  width: 120,
                  height: 140,
                  child: Center(
                    child: buildImage(widget.outfit.imageId, width: 100, height: 130),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.outfit.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: _loadingFavorite ? null : () async {
                              if (widget.onFavorite != null) {
                                setState(() => _loadingFavorite = true);
                                widget.onFavorite!();
                                setState(() => _loadingFavorite = false);
                              }
                            },
                            child: _loadingFavorite
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(colorScheme.primary)),
                                  )
                                : Icon(
                                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: widget.isFavorite ? Colors.redAccent : Colors.black12,
                                    size: 28,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Type: ${widget.outfit.clothingType}',
                        style: TextStyle(fontSize: 14, color: colorScheme.primary.withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Season: ${widget.outfit.season}',
                        style: TextStyle(fontSize: 13, color: colorScheme.primary.withOpacity(0.6)),
                      ),
                      if (widget.outfit.genderType != null && widget.outfit.genderType!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'For: ${widget.outfit.genderType}',
                            style: TextStyle(fontSize: 13, color: colorScheme.primary.withOpacity(0.6)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Added: ${widget.outfit.createdAt.toLocal().toString().split(" ")[0]}',
                          style: TextStyle(fontSize: 12, color: colorScheme.primary.withOpacity(0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Vertical card
    return GestureDetector(
      onTap: widget.onTap,
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                  child: Container(
                    color: Colors.white, // Neutral background
                    width: 180,
                    height: 200, // Slightly taller for better aspect
                    child: Center(
                      child: buildImage(widget.outfit.imageId, width: 140, height: 180),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _loadingFavorite ? null : () async {
                      if (widget.onFavorite != null) {
                        setState(() => _loadingFavorite = true);
                        widget.onFavorite!();
                        setState(() => _loadingFavorite = false);
                      }
                    },
                    child: _loadingFavorite
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(colorScheme.primary)),
                          )
                        : Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: widget.isFavorite ? Colors.redAccent : Colors.black12,
                            size: 28,
                          ),
                  ),
                ),
                if (widget.outfit.isDonated)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Donated', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
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
                    widget.outfit.title,
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
                    widget.outfit.clothingType,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.outfit.season,
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
