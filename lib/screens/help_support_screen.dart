import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.help_outline, size: 60, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('Help & Support', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Find answers to common questions or contact our support team.'),
          const SizedBox(height: 24),
          Text('FAQs', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ExpansionTile(
            title: Text('How do I reset my password?'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Go to the Sign In screen, tap on "Forgot Password?", and follow the instructions.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I contact support?'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('You can email us at support@virtualwardrobe.com or use the Contact Support button below.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I delete my account?'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Please contact support to request account deletion.'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Contact Support', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.email, color: colorScheme.primary),
            title: Text('support@virtualwardrobe.com'),
            onTap: () {
              // TODO: Implement email launch
            },
          ),
          const SizedBox(height: 24),
          Text('Feedback', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final _emailController = TextEditingController();
                  final _messageController = TextEditingController();
                  return AlertDialog(
                    title: const Text('Send Feedback'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Your Email (optional)',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Your Feedback',
                              prefixIcon: Icon(Icons.feedback_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Send feedback to backend or email
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thank you for your feedback!')),
                          );
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.feedback),
            label: Text('Send Feedback'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
} 