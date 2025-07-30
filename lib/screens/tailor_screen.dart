import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/tailor_controller.dart';
import '../controllers/organization_controller.dart';

class TailorScreen extends StatelessWidget {
  const TailorScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final TailorController tailorController = Get.put(TailorController());
    final OrganizationController orgController = Get.put(OrganizationController());

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
      body: Obx(() {
        if (tailorController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (tailorController.tailors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: colorScheme.primary.withOpacity(0.5)),
                SizedBox(height: 16),
                Text(
                  'No tailors available',
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
                  itemCount: tailorController.tailors.length,
                  itemBuilder: (context, index) {
                    final tailor = tailorController.tailors[index];
                    final org = orgController.organizations.firstWhereOrNull((o) => o.id == tailor.organizationId);
                    
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
                                // Tailor image placeholder
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.person, size: 40, color: colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Tailor name
                                      Text(
                                        tailor.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Organization
                                      if (org != null) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.business, size: 16, color: colorScheme.primary.withOpacity(0.7)),
                                            const SizedBox(width: 4),
                                            Text(
                                              org.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: colorScheme.primary.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      
                                      // Address
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: colorScheme.primary.withOpacity(0.7)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              tailor.address,
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
                                    onTap: () => _launchUrl('tel:${tailor.phone}'),
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
                                          Expanded(
                                            child: Text(
                                              tailor.phone,
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
                                const SizedBox(width: 12),
                                
                                // Email
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _launchUrl('mailto:${tailor.email}'),
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
                                              tailor.email,
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
                            if (tailor.specialties.isNotEmpty) ...[
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
                                  tailor.specialties.length,
                                  (index) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      tailor.specialties[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // WhatsApp button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _launchUrl(_generateWhatsAppUrl(tailor.phone));
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
        );
      }),
    );
  }
} 