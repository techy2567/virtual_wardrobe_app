import 'package:flutter/material.dart';

class TermsPoliciesScreen extends StatelessWidget {
  const TermsPoliciesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Policies'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.policy, size: 60, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('Terms & Policies', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('By using our app, you agree to the following terms and policies. Please read them carefully.'),
          const SizedBox(height: 24),
          Text('Terms of Use', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You must use the app in accordance with all applicable laws and regulations.'),
          const SizedBox(height: 20),
          Text('User Responsibilities', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.'),
          const SizedBox(height: 20),
          Text('Prohibited Activities', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You may not misuse the app, attempt unauthorized access, or engage in any activity that could harm the app or its users.'),
          const SizedBox(height: 20),
          Text('Contact', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('For questions about our terms and policies, email us at legal@virtualwardrobe.com.'),
        ],
      ),
    );
  }
} 