import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: colorScheme.primaryContainer,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.indeterminate_check_box_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              'Virtual Wardrobe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 18),
            Text(
              'Virtual Wardrobe helps you organize your clothes, create outfits, and get daily recommendations. Developed with love for fashion enthusiasts.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Developed by'),
              subtitle: const Text('LayyahDevs'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Contact'),
              subtitle: const Text('support@layyahdevs.com'),
              onTap: () => _launchUrl('mailto:support@layyahdevs.com'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: const Text('+92 300 1234567'),
              onTap: () => _launchUrl('tel:+923001234567'),
            ),
            // ListTile(
            //   leading: const Icon(Icons.whatsapp),
            //   title: const Text('WhatsApp'),
            //   subtitle: const Text('+92 300 1234567'),
            //   onTap: () => _launchUrl('https://wa.me/923001234567'),
            // ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Website'),
              subtitle: const Text('layyahdevs.com'),
              onTap: () => _launchUrl('https://layyahdevs.com'),
            ),
            // const Spacer(),
            Text(
              '© 2024 LayyahDevs. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
          ),
      ),
    );
  }
} 