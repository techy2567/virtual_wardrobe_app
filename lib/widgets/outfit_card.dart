import 'package:flutter/material.dart';

class OutfitCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<Color> colors;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const OutfitCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.colors,
    this.onTap,
    this.isFavorite = false,
    this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Outfit image
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/outfits/outfit1.jpeg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            // Favorite icon button (top right)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavorite,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: isFavorite
                      ? Icon(Icons.favorite, key: ValueKey(true), color: Colors.redAccent, size: 28)
                      : Icon(Icons.favorite_border, key: ValueKey(false), color: Colors.white, size: 28),
                ),
              ),
            ),
            // Gradient overlay for title
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.primary.withOpacity(0.10),
                      colorScheme.primary.withOpacity(0.25),
                      colorScheme.primary.withOpacity(0.60),
                      colorScheme.primary,
                    ],
                    stops: [0.0, 0.3, 0.6, 0.85, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        color: colorScheme.onPrimary.withOpacity(0.85),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Color dots row (bottom left, above gradient)
            Positioned(
              left: 10,
              bottom: 48,
              child: Row(
                children: colors.take(5).map((color) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: color,
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
