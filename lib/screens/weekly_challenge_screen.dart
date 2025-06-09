import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeeklyChallengeScreen extends StatelessWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dummy data for weekly challenges
    final List<Map<String, dynamic>> challenges = [
      {
        'title': 'Summer Breeze Challenge',
        'description': 'Create a light and breezy outfit perfect for a summer day at the beach. Use light fabrics and bright colors to capture the essence of summer.',
        'startDate': 'June 1, 2023',
        'endDate': 'June 7, 2023',
        'prize': 'Featured on homepage',
        'participants': 42,
        'image': 'https://via.placeholder.com/400x200/FFD700/000000?text=Summer+Breeze',
        'guidelines': [
          'Use at least one light-colored item',
          'Include a hat or sunglasses',
          'Focus on breathable fabrics',
          'Maximum 3 items per outfit'
        ],
      },
      {
        'title': 'Urban Explorer Challenge',
        'description': 'Design an outfit that combines style and comfort for a day of exploring the city. Think practical yet fashionable for urban adventures.',
        'startDate': 'June 8, 2023',
        'endDate': 'June 14, 2023',
        'prize': 'Gift card to partner store',
        'participants': 28,
        'image': 'https://via.placeholder.com/400x200/4682B4/FFFFFF?text=Urban+Explorer',
        'guidelines': [
          'Include comfortable footwear',
          'Use at least one layer piece',
          'Incorporate a practical bag or accessory',
          'Focus on neutral colors with one pop of color'
        ],
      },
      {
        'title': 'Vintage Revival Challenge',
        'description': 'Create an outfit inspired by your favorite decade from the past. Reimagine vintage styles with a modern twist.',
        'startDate': 'June 15, 2023',
        'endDate': 'June 21, 2023',
        'prize': 'Exclusive styling session',
        'participants': 35,
        'image': 'https://via.placeholder.com/400x200/8B4513/FFFFFF?text=Vintage+Revival',
        'guidelines': [
          'Choose a specific decade (60s, 70s, 80s, or 90s)',
          'Use at least one vintage-inspired piece',
          'Add a modern element to the outfit',
          'Include a statement accessory'
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Weekly Challenges',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
      ),
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Challenges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create outfits based on these weekly themes and guidelines',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Challenge image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            challenge['image'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: colorScheme.surface,
                              child: Icon(Icons.image, size: 50, color: colorScheme.primary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Challenge title
                              Text(
                                challenge['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Challenge dates
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: colorScheme.primary.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${challenge['startDate']} - ${challenge['endDate']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.primary.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              
                              // Participants count
                              Row(
                                children: [
                                  Icon(Icons.people, size: 16, color: colorScheme.primary.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${challenge['participants']} participants',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.primary.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Challenge description
                              Text(
                                challenge['description'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Prize
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.emoji_events, size: 16, color: colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Prize: ${challenge['prize']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Guidelines
                              Text(
                                'Guidelines:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(
                                challenge['guidelines'].length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 16, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          challenge['guidelines'][index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Participate button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Navigate to create outfit screen with challenge parameters
                                    Get.toNamed('/create-outfit', arguments: {'challenge': challenge});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.background,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Participate in Challenge',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 