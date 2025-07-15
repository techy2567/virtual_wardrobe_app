import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TailorScreen extends StatelessWidget {
  const TailorScreen({super.key});

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

    // Dummy data for tailors
    final List<Map<String, dynamic>> tailors = [
      {
        'name': 'Elegant Stitches',
        'address': '123 Fashion Street, Downtown, City',
        'phone': '+1234567890',
        'email': 'contact@elegantstitches.com',
        'phoneUrl': 'tel:+1234567890',
        'emailUrl': 'mailto:contact@elegantstitches.com',
        'specialties': ['Wedding Dresses', 'Formal Wear', 'Alterations'],
        'rating': 4.8,
        'reviews': 124,
        'image': 'https://via.placeholder.com/150/FF5733',
      },
      {
        'name': 'Precision Tailors',
        'address': '456 Style Avenue, Uptown, City',
        'phone': '+1987654321',
        'email': 'info@precisiontailors.com',
        'phoneUrl': 'tel:+1987654321',
        'emailUrl': 'mailto:info@precisiontailors.com',
        'specialties': ['Business Suits', 'Casual Wear', 'Custom Designs'],
        'rating': 4.6,
        'reviews': 98,
        'image': 'https://via.placeholder.com/150/33FF57',
      },
      {
        'name': 'Heritage Tailoring',
        'address': '789 Tradition Road, Old Town, City',
        'phone': '+1122334455',
        'email': 'service@heritagetailoring.com',
        'phoneUrl': 'tel:+1122334455',
        'emailUrl': 'mailto:service@heritagetailoring.com',
        'specialties': ['Traditional Wear', 'Vintage Styles', 'Repairs'],
        'rating': 4.9,
        'reviews': 156,
        'image': 'https://via.placeholder.com/150/3357FF',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Find a Tailor',
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
                'Local Tailors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find professional tailors in your area',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tailors.length,
                itemBuilder: (context, index) {
                  final tailor = tailors[index];
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tailor image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  tailor['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 100,
                                    height: 100,
                                    color: colorScheme.surface,
                                    child: Icon(Icons.person, size: 40, color: colorScheme.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tailor name
                                    Text(
                                      tailor['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    
                                    // Rating
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${tailor['rating']} (${tailor['reviews']} reviews)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.primary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Address
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: colorScheme.primary.withOpacity(0.7)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            tailor['address'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Contact information
                          Row(
                            children: [
                              // Phone
                              Expanded(
                                child: InkWell(
                                  onTap: () => _launchUrl(tailor['phoneUrl']),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone, size: 16, color: colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          tailor['phone'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Email
                              Expanded(
                                child: InkWell(
                                  onTap: () => _launchUrl(tailor['emailUrl']),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.email, size: 16, color: colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            tailor['email'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.primary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Specialties
                          Text(
                            'Specialties:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              tailor['specialties'].length,
                              (index) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tailor['specialties'][index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Book appointment button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                               _launchUrl('https://wa.me/${'+923084316822'.replaceAll('+', '')}'); // WhatsApp link
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
                                'WhatsApp to Book',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
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