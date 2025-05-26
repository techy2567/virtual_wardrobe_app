import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners like the image
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Today, Jan 1',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Weather',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                   Text(
                    '-3° to +8°',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                   const SizedBox(height: 8.0),
                    Text(
                    'Probability of Precipitation',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                   Text(
                    '90%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Placeholder for weather image or icon
            Expanded(
              flex: 1,
              child: Center(
                child: Icon(
                  Icons.cloud_outlined, // Placeholder icon
                  size: 60,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 