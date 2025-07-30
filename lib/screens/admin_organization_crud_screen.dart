import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/organization_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/organization_model.dart';

class AdminOrganizationCrudScreen extends StatelessWidget {
  final OrganizationController orgController = Get.put(OrganizationController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!authController.isAdmin.value) {
        Future.microtask(() => Get.offAllNamed('/admin-login'));
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(title: Text('Manage Organizations')),
        body: orgController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orgController.organizations.length,
                itemBuilder: (context, index) {
                  final org = orgController.organizations[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(org.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone: ${org.phone}'),
                          Text('Email: ${org.email}'),
                          Text('Address: ${org.address}'),
                          if (org.description != null && org.description!.isNotEmpty)
                            Text('Description: ${org.description}'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(context, org),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, org),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: Icon(Icons.add),
          tooltip: 'Add Organization',
        ),
      );
    });
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Organization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController, 
                decoration: InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: phoneController, 
                decoration: InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: addressController, 
                decoration: InputDecoration(labelText: 'Address *'),
                maxLines: 2,
              ),
              TextField(
                controller: emailController, 
                decoration: InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: descController, 
                decoration: InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please fill all required fields');
                return;
              }
              await orgController.addOrganization(
                nameController.text.trim(),
                phoneController.text.trim(),
                addressController.text.trim(),
                emailController.text.trim(),
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, OrganizationModel org) {
    final nameController = TextEditingController(text: org.name);
    final phoneController = TextEditingController(text: org.phone);
    final addressController = TextEditingController(text: org.address);
    final emailController = TextEditingController(text: org.email);
    final descController = TextEditingController(text: org.description ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Organization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController, 
                decoration: InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: phoneController, 
                decoration: InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: addressController, 
                decoration: InputDecoration(labelText: 'Address *'),
                maxLines: 2,
              ),
              TextField(
                controller: emailController, 
                decoration: InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: descController, 
                decoration: InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please fill all required fields');
                return;
              }
              await orgController.updateOrganization(
                org.id,
                nameController.text.trim(),
                phoneController.text.trim(),
                addressController.text.trim(),
                emailController.text.trim(),
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, OrganizationModel org) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Organization'),
        content: Text('Are you sure you want to delete "${org.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await orgController.deleteOrganization(org.id);
              Navigator.pop(context);
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
} 