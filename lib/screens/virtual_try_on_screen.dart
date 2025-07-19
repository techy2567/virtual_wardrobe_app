import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../api_config/virtual_config.dart';
import '../controllers/virtual_try_on_controller.dart';

class VirtualTryOnScreen extends StatefulWidget {
  /// Only File is supported for productImagePath. Pass a File loaded from local storage.
  final File productImagePath;
  // final String productType;

  const VirtualTryOnScreen({
    required this.productImagePath,
    // required this.productType,
    Key? key,
  }) : super(key: key);

  @override
  _VirtualTryOnScreenState createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  late VirtualTryOnController _controller;
  late SelfieSegmenter _segmenter;
  late PoseDetector _poseDetector;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(VirtualTryOnController());
    _segmenter = SelfieSegmenter(mode: SegmenterMode.single);
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
  }

  ScreenshotController _screenshotController = ScreenshotController();

  @override
  void dispose() {
    _segmenter.close();
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await _controller.pickImageFromGallery();
  }

  Future<void> _performVirtualTryOn() async {
    // Check if API key is configured
    if (!VirtualTryOnConfig.isApiKeyConfigured) {
      _showError(
          'API key not configured. Please update the API key in api_config.dart');
      return;
    }
    await _controller.performVirtualTryOn(widget.productImagePath);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.pop(context); // Close the bottom sheet
    await _controller.pickImageFromCamera();
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context); // Close the bottom sheet
    await _controller.pickImageFromGallery();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: 'Camera',
                    child: GestureDetector(
                      onTap: _pickImageFromCamera,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                        child: Icon(Icons.camera_alt, size: 32, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Gallery',
                    child: GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                        child: Icon(Icons.photo_library, size: 32, color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child, double? width, double? height, EdgeInsets? padding}) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor.withOpacity(0.7),
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildAvatar(File? image) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: image != null
          ? CircleAvatar(
              key: ValueKey(image.path),
              radius: 56,
              backgroundImage: FileImage(image),
              backgroundColor: Colors.transparent,
            )
          : CircleAvatar(
              key: ValueKey('empty'),
              radius: 56,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person_outline, size: 48, color: Colors.grey[400]),
            ),
    );
  }

  Widget _buildProductCard() {
    return Hero(
      tag: 'product-image',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.18),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
            image: DecorationImage(
              image: FileImage(widget.productImagePath),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.25),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedResultImage(File? image) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.file(
                image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 340,
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildAnimatedSelectedImage(File? image) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.file(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 340,
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildErrorBanner(String message) {
    return AnimatedOpacity(
      opacity: message.isNotEmpty ? 1.0 : 0.0,
      duration: Duration(milliseconds: 400),
      child: message.isNotEmpty
          ? Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildApiKeyWarning() {
    return !VirtualTryOnConfig.isApiKeyConfigured
        ? Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.22)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'API key not configured. Please update the API key in api_config.dart',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.18),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              strokeWidth: 5,
            ),
            SizedBox(height: 24),
            Text(
              'Processing virtual try-on...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Obx(() {
      final hasResult = _controller.resultImage.value != null;
      return AnimatedContainer(
        duration: Duration(milliseconds: 400),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        margin: EdgeInsets.only(bottom: 24, left: 24, right: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child:hasResult
            ?  InkWell(
          onTap: ()async{
            await _downloadImage();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.save_alt, color: Colors.green, size: 32),
                    Text("Download Result", style: TextStyle(color: Colors.green, fontSize: 16)),
                  ],
          ),
        ):Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            IconButton(
              tooltip: 'Select Photo',
              icon: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor, size: 32),
              onPressed: _controller.isLoading.value ? null : _showImageSourceSheet,
            ),
            AnimatedScale(
              scale: _controller.canProceedWithTryOn && !_controller.isLoading.value ? 1.0 : 0.85,
              duration: Duration(milliseconds: 300),
              child: IconButton(
                tooltip: 'Try On',
                icon: Icon(Icons.auto_awesome, color: _controller.canProceedWithTryOn && !_controller.isLoading.value ? Color(0xff0C3924) : Colors.grey[400], size: 32),
                onPressed: _controller.canProceedWithTryOn && !_controller.isLoading.value ? _performVirtualTryOn : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 12, top: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.titleLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Virtual Try-On',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = _controller.isLoading.value;
        final hasResult = _controller.resultImage.value != null;
        final selectedImage = _controller.selectedImage.value;
        final resultImage = _controller.resultImage.value;
        final errorMessage = _controller.errorMessage.value;
        return Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.12),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.10),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 12),
                      // Product image card floating above
                      Align(
                        alignment: Alignment.topRight,
                        child: _buildProductCard(),
                      ),
                      SizedBox(height: 12),
                      // User avatar
                      Center(child: _buildAvatar(selectedImage)),
                      SizedBox(height: 18),
                      // Glass card for instructions and warnings
                      _buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Try On Your Style!',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Select a clear photo of yourself and see how this product looks on you. Enjoy a seamless virtual try-on experience!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 15,
                                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                  ),
                            ),
                            _buildApiKeyWarning(),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                      ),
                      _buildErrorBanner(errorMessage),
                      SizedBox(height: 18),
                      // Main image area
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: isLoading
                            ? _buildLoadingOverlay()
                            : hasResult
                                ? Screenshot(
                                    controller: _screenshotController,
                                    child: _buildAnimatedResultImage(resultImage),
                                  )
                                : _buildAnimatedSelectedImage(selectedImage),
                      ),
                      if (!isLoading && !hasResult && selectedImage == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Column(
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'No image selected',
                                style: TextStyle(fontSize: 17, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the camera icon below to select a photo',
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 120), // For bottom bar spacing
                    ],
                  ),
                ),
              ),
            ),
            // Bottom action bar
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomActionBar(),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _downloadImage() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(image),
          quality: 100,
          name: 'virtual_tryon_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved to gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image:  [1m${result['errorMessage'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}