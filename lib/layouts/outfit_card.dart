import 'package:flutter/material.dart';

class OutfitCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<Color> colors;

  const OutfitCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      clipBehavior: Clip.antiAlias, // Clip the image to the rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl, // Use provided image URL
            fit: BoxFit.cover,
            height: 120, // Example height, adjust as needed
            width: double.infinity, // Take full width of the card
            // Add a placeholder or error widget if image fails to load
            errorBuilder: (context, error, stackTrace) => Container(
              color: colorScheme.surface,
              child: Icon(Icons.broken_image, color: colorScheme.primary.withOpacity(0.6)),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary.withOpacity(0.9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0), // Fixed padding
            child: Row(
              children: colors.map((color) => Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: color,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 