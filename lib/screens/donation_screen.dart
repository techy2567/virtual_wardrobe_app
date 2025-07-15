import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/controller_create_outfit.dart';

class DonationScreen extends StatefulWidget {
  final String outfitId;
  const DonationScreen({super.key, required this.outfitId});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  bool _donating = false;
  String? _donatedTo;

  // Function to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _handleDonate(String orgName) async {
    setState(() { _donating = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in.');
      setState(() { _donating = false; });
      return;
    }
    final success = await ControllerCreateOutfit.markOutfitAsDonated(
      outfitId: widget.outfitId,
      userId: user.uid,
    );
    setState(() {
      _donating = false;
      if (success) _donatedTo = orgName;
    });
    if (success) {
      Get.snackbar('Success', 'Marked as donated to $orgName!');
      // Redirect to HomeScreen after successful donation
      Future.delayed(const Duration(milliseconds: 800), () {
        Get.offAllNamed('/home');
      });
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
                'Click on the icons to contact these organizations directly or donate your outfit',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              if (_donatedTo != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: colorScheme.primary),
                      SizedBox(width: 8),
                      Expanded(child: Text('Outfit marked as donated to $_donatedTo!')),
                    ],
                  ),
                ),
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
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _donating || _donatedTo != null
                                          ? null
                                          : () => _handleDonate(org['name']),
                                      icon: _donating
                                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                          : Icon(Icons.volunteer_activism),
                                      label: Text(_donatedTo == org['name'] ? 'Donated' : 'Donate to this organization'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.background,
                                        minimumSize: const Size(double.infinity, 40.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        elevation: 1.0,
                                      ),
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