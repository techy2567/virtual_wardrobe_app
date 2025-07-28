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
        appBar: AppBar(title: Text('UI Customization')),
        body: uiController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App Title'),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(hintText: 'Enter app title'),
                    ),
                    SizedBox(height: 24),
                    Text('Primary Color'),
                    _ColorPicker(
                      initialColor: uiController.primaryColor.value,
                      onColorChanged: (color) => uiController.primaryColor.value = color,
                    ),
                    SizedBox(height: 24),
                    Text('Background Color'),
                    _ColorPicker(
                      initialColor: uiController.backgroundColor.value,
                      onColorChanged: (color) => uiController.backgroundColor.value = color,
                    ),
                    SizedBox(height: 24),
                    Text('Surface Color'),
                    _ColorPicker(
                      initialColor: uiController.surfaceColor.value,
                      onColorChanged: (color) => uiController.surfaceColor.value = color,
                    ),
                    SizedBox(height: 32),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await uiController.updateColors(
                              primary: uiController.primaryColor.value,
                              background: uiController.backgroundColor.value,
                              surface: uiController.surfaceColor.value,
                            );
                            Get.snackbar('Success', 'Colors updated');
                          },
                          child: Text('Save Colors'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await uiController.updateTexts(title: titleController.text.trim());
                            Get.snackbar('Success', 'App title updated');
                          },
                          child: Text('Save Title'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class _ColorPicker extends StatelessWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  const _ColorPicker({required this.initialColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            Color picked = initialColor;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
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