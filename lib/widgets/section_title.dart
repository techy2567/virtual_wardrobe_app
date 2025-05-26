import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onAddPressed;
  final VoidCallback? onViewAllPressed;

  const SectionTitle({
    Key? key,
    required this.title,
    this.trailingText,
    this.onAddPressed,
    this.onViewAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0), // Adjusted padding for consistency
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary, // Dark navy color
                ),
              ),
              if (trailingText != null) // Display trailing text if provided
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Add spacing between title and trailing text
                  child: Text(
                    trailingText!,
                     style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary.withOpacity(0.7), // Slightly lighter color
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (onAddPressed != null)
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.primary.withOpacity(0.8)),
                  onPressed: onAddPressed,
                ),
              if (onViewAllPressed != null)
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: colorScheme.primary.withOpacity(0.8), size: 20),
                  onPressed: onViewAllPressed,
                ),
            ],
          ),
        ],
      ),
    );
  }
} 