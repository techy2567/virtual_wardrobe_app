import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  // Function to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dummy data for organizations
    final List<Map<String, dynamic>> organizations = [
      {
        'name': 'Clothes for Hope',
        'logo': 'https://via.placeholder.com/150/FF5733',
        'phone': '+1234567890',
        'email': 'contact@clothesforhope.org',
        'phoneUrl': 'tel:+1234567890',
        'emailUrl': 'mailto:contact@clothesforhope.org',
      },
      {
        'name': 'Wardrobe Warriors',
        'logo': 'https://via.placeholder.com/150/33FF57',
        'phone': '+1987654321',
        'email': 'info@wardrobewarriors.org',
        'phoneUrl': 'tel:+1987654321',
        'emailUrl': 'mailto:info@wardrobewarriors.org',
      },
      {
        'name': 'Fashion Forward',
        'logo': 'https://via.placeholder.com/150/3357FF',
        'phone': '+1122334455',
        'email': 'help@fashionforward.org',
        'phoneUrl': 'tel:+1122334455',
        'emailUrl': 'mailto:help@fashionforward.org',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Donate Clothes',
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
                'Support These Organizations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click on the icons to contact these organizations directly',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: organizations.length,
                itemBuilder: (context, index) {
                  final org = organizations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  org['logo'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: colorScheme.surface,
                                    child: Icon(Icons.business, color: colorScheme.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      org['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.phone, color: colorScheme.primary),
                                          onPressed: () => _launchUrl(org['phoneUrl']),
                                        ),
                                        Text(
                                          org['phone'],
                                          style: TextStyle(color: colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.email, color: colorScheme.primary),
                                          onPressed: () => _launchUrl(org['emailUrl']),
                                        ),
                                        Expanded(
                                          child: Text(
                                            org['email'],
                                            style: TextStyle(color: colorScheme.primary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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