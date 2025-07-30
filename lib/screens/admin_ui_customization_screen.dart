import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/ui_customization_controller.dart';
import '../controllers/auth_controller.dart';

class AdminUICustomizationScreen extends StatelessWidget {
  final UICustomizationController uiController = Get.find<UICustomizationController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!authController.isAdmin.value) {
        Future.microtask(() => Get.offAllNamed('/admin-login'));
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      titleController.text = uiController.appTitle.value;
      return Scaffold(
        appBar: AppBar(
          title: Text('UI Customization'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => uiController.resetToDefaults(),
              tooltip: 'Reset to Defaults',
            ),
          ],
        ),
        body: uiController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Title',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: uiController.primaryColor.value,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                hintText: 'Enter app title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await uiController.updateTexts(title: titleController.text.trim());
                              },
                              child: Text('Save Title'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: uiController.primaryColor.value,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Color Scheme',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: uiController.primaryColor.value,
                              ),
                            ),
                            SizedBox(height: 16),
                            _ColorPicker(
                              label: 'Primary Color',
                              initialColor: uiController.primaryColor.value,
                              onColorChanged: (color) => uiController.primaryColor.value = color,
                            ),
                            SizedBox(height: 16),
                            _ColorPicker(
                              label: 'Background Color',
                              initialColor: uiController.backgroundColor.value,
                              onColorChanged: (color) => uiController.backgroundColor.value = color,
                            ),
                            SizedBox(height: 16),
                            _ColorPicker(
                              label: 'Surface Color',
                              initialColor: uiController.surfaceColor.value,
                              onColorChanged: (color) => uiController.surfaceColor.value = color,
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await uiController.updateColors(
                                        primary: uiController.primaryColor.value,
                                        background: uiController.backgroundColor.value,
                                        surface: uiController.surfaceColor.value,
                                      );
                                    },
                                    child: Text('Save Colors'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: uiController.primaryColor.value,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => uiController.resetToDefaults(),
                                    child: Text('Reset to Defaults'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: uiController.primaryColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: uiController.primaryColor.value,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: uiController.backgroundColor.value,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: uiController.primaryColor.value,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      uiController.appTitle.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: uiController.surfaceColor.value,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Sample content with surface color',
                                      style: TextStyle(color: uiController.primaryColor.value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  
  const _ColorPicker({
    required this.label,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () async {
            Color picked = initialColor;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Pick $label'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: initialColor,
                    onColorChanged: (color) {
                      picked = color;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onColorChanged(picked);
                    },
                    child: Text('Select'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: initialColor,
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(width: 16),
        Text('#${initialColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
      ],
    );
  }
} 