import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/controller_create_outfit.dart';
import '../controllers/organization_controller.dart';

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

  // Function to generate WhatsApp URL
  String _generateWhatsAppUrl(String phone) {
    // Remove any non-digit characters and ensure it starts with country code
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }
    return 'https://wa.me/${cleanPhone.replaceAll('+', '')}';
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
    final OrganizationController orgController = Get.put(OrganizationController());

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
      body: Obx(() {
        if (orgController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (orgController.organizations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 64, color: colorScheme.primary.withOpacity(0.5)),
                SizedBox(height: 16),
                Text(
                  'No organizations available',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later or contact admin',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
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
                  itemCount: orgController.organizations.length,
                  itemBuilder: (context, index) {
                    final org = orgController.organizations[index];
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
                                // Organization logo placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.business, color: colorScheme.primary,size: 50,),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        org.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Contact information
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.phone, color: colorScheme.primary),
                                            onPressed: () => _launchUrl('tel:${org.phone}'),
                                          ),
                                          Expanded(
                                            child: Text(
                                              org.phone,
                                              style: TextStyle(color: colorScheme.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.email, color: colorScheme.primary),
                                            onPressed: () => _launchUrl('mailto:${org.email}'),
                                          ),
                                          Expanded(
                                            child: Text(
                                              org.email,
                                              style: TextStyle(color: colorScheme.primary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Address
                                      if (org.address.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: colorScheme.primary.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                org.address,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme.primary.withOpacity(0.7),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      
                                      // Description
                                      if (org.description != null && org.description!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          org.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.primary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                      
                                      const SizedBox(height: 12),
                                      
                                      // Action buttons
                                      
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _launchUrl(_generateWhatsAppUrl(org.phone)),
                                              icon: Icon(Icons.message),
                                              label: Text('WhatsApp'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                minimumSize: const Size(0, 40.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: _donating || _donatedTo != null
                                                  ? null
                                                  : () => _handleDonate(org.name),
                                              icon: _donating
                                                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                  : Icon(Icons.volunteer_activism),
                                              label: Text(_donatedTo == org.name ? 'Donated' : 'Donate'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: colorScheme.primary,
                                                foregroundColor: colorScheme.background,
                                                minimumSize: const Size(0, 40.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
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
        );
      }),
    );
  }
} 