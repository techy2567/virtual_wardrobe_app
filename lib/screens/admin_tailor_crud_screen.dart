import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tailor_controller.dart';
import '../controllers/organization_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/tailor_model.dart';

class AdminTailorCrudScreen extends StatelessWidget {
  final TailorController tailorController = Get.put(TailorController());
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
        appBar: AppBar(title: Text('Manage Tailors')),
        body: tailorController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: tailorController.tailors.length,
                itemBuilder: (context, index) {
                  final tailor = tailorController.tailors[index];
                  final org = orgController.organizations.firstWhereOrNull((o) => o.id == tailor.organizationId);
                  return ListTile(
                    title: Text(tailor.name),
                    subtitle: Text('Organization: \\${org?.name ?? 'Unknown'}\\nContact: \\${tailor.contact ?? '-'}'),
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
    final contactController = TextEditingController();
    String? selectedOrgId;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Tailor'),
        content: GetX<OrganizationController>(
          builder: (orgCtrl) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: contactController, decoration: InputDecoration(labelText: 'Contact')),
              DropdownButtonFormField<String>(
                value: selectedOrgId,
                items: orgCtrl.organizations
                    .map((org) => DropdownMenuItem(value: org.id, child: Text(org.name)))
                    .toList(),
                onChanged: (val) => selectedOrgId = val,
                decoration: InputDecoration(labelText: 'Organization'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedOrgId != null) {
                await tailorController.addTailor(
                  nameController.text.trim(),
                  selectedOrgId!,
                  contact: contactController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TailorModel tailor) {
    final nameController = TextEditingController(text: tailor.name);
    final contactController = TextEditingController(text: tailor.contact ?? '');
    String? selectedOrgId = tailor.organizationId;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Tailor'),
        content: GetX<OrganizationController>(
          builder: (orgCtrl) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: contactController, decoration: InputDecoration(labelText: 'Contact')),
              DropdownButtonFormField<String>(
                value: selectedOrgId,
                items: orgCtrl.organizations
                    .map((org) => DropdownMenuItem(value: org.id, child: Text(org.name)))
                    .toList(),
                onChanged: (val) => selectedOrgId = val,
                decoration: InputDecoration(labelText: 'Organization'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedOrgId != null) {
                await tailorController.updateTailor(
                  tailor.id,
                  nameController.text.trim(),
                  selectedOrgId!,
                  contact: contactController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
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