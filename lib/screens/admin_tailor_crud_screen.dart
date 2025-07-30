import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tailor_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/tailor_model.dart';

class AdminTailorCrudScreen extends StatelessWidget {
  final TailorController tailorController = Get.put(TailorController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!authController.isAdmin.value) {
        Future.microtask(() => Get.offAllNamed('/admin-login'));
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(title: Text('Manage Tailors')),
        body: tailorController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: tailorController.tailors.length,
                itemBuilder: (context, index) {
                  final tailor = tailorController.tailors[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(tailor.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone: ${tailor.phone}'),
                          Text('Email: ${tailor.email}'),
                          Text('Address: ${tailor.address}'),
                          if (tailor.specialties.isNotEmpty)
                            Text('Specialties: ${tailor.specialties.join(', ')}'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(context, tailor),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, tailor),
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
          tooltip: 'Add Tailor',
        ),
      );
    });
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();
    final contactController = TextEditingController();
    final specialtyController = TextEditingController();
    List<String> specialties = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Tailor'),
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
                  controller: contactController, 
                  decoration: InputDecoration(labelText: 'Contact (Optional)'),
                ),
                SizedBox(height: 16),
                Text('Specialties:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: specialtyController,
                        decoration: InputDecoration(
                          labelText: 'Add Specialty',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              if (specialtyController.text.trim().isNotEmpty) {
                                setState(() {
                                  specialties.add(specialtyController.text.trim());
                                  specialtyController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (specialties.isNotEmpty) ...[
                  Text('Current Specialties:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: specialties.map((specialty) => Chip(
                      label: Text(specialty),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          specialties.remove(specialty);
                        });
                      },
                    )).toList(),
                  ),
                ],
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
                await tailorController.addTailor(
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  addressController.text.trim(),
                  emailController.text.trim(),
                  specialties,
                  '', // Empty organizationId since we removed the field
                  contact: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TailorModel tailor) {
    final nameController = TextEditingController(text: tailor.name);
    final phoneController = TextEditingController(text: tailor.phone);
    final addressController = TextEditingController(text: tailor.address);
    final emailController = TextEditingController(text: tailor.email);
    final contactController = TextEditingController(text: tailor.contact ?? '');
    final specialtyController = TextEditingController();
    List<String> specialties = List.from(tailor.specialties);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Tailor'),
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
                  controller: contactController, 
                  decoration: InputDecoration(labelText: 'Contact (Optional)'),
                ),
                SizedBox(height: 16),
                Text('Specialties:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: specialtyController,
                        decoration: InputDecoration(
                          labelText: 'Add Specialty',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              if (specialtyController.text.trim().isNotEmpty) {
                                setState(() {
                                  specialties.add(specialtyController.text.trim());
                                  specialtyController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (specialties.isNotEmpty) ...[
                  Text('Current Specialties:'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: specialties.map((specialty) => Chip(
                      label: Text(specialty),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          specialties.remove(specialty);
                        });
                      },
                    )).toList(),
                  ),
                ],
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
                await tailorController.updateTailor(
                  tailor.id,
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  addressController.text.trim(),
                  emailController.text.trim(),
                  specialties,
                  tailor.organizationId, // Keep existing organizationId
                  contact: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TailorModel tailor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Tailor'),
        content: Text('Are you sure you want to delete "${tailor.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await tailorController.deleteTailor(tailor.id);
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