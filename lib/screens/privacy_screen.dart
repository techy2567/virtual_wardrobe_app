import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.privacy_tip, size: 60, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('Privacy Policy', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('We value your privacy and are committed to protecting your personal data. This policy explains how we collect, use, and safeguard your information.'),
          const SizedBox(height: 24),
          Text('Data Collection', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('We collect only the data necessary to provide and improve our services, such as your name, email, and wardrobe preferences.'),
          const SizedBox(height: 20),
          Text('Usage', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your data is used solely for enhancing your experience, personalizing recommendations, and ensuring account security.'),
          const SizedBox(height: 20),
          Text('User Rights', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You have the right to access, update, or delete your data at any time. Contact us for any privacy-related requests.'),
          const SizedBox(height: 20),
          Text('Contact', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('For questions or concerns about your privacy, email us at support@virtualwardrobe.com.'),
        ],
      ),
    );
  }
} 