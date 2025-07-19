import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

import '../api_config/virtual_config.dart';

class VirtualTryOnController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Observable variables
  var isLoading = false.obs;
  var selectedImage = Rx<File?>(null);
  var resultImage = Rx<File?>(null);
  var resultImageUrl = RxString('');
  var errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        resultImage.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: ${e.toString()}';
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        resultImage.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: ${e.toString()}';
    }
  }

  // Validate image format and size
  Future<bool> validateImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Check file size (max 10MB)
      if (bytes.length > 10 * 1024 * 1024) {
        errorMessage.value = 'Image file is too large. Maximum size is 10MB.';
        return false;
      }

      try {
        await imageFile.readAsBytes();
        return true;
      } catch (e) {
        errorMessage.value = 'Invalid image file. Please select a valid image.';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error validating image: ${e.toString()}';
      return false;
    }
  }

  // Get image format from file
  String getImageFormat(File imageFile) {
    final path = imageFile.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return 'jpeg';
    } else if (path.endsWith('.png')) {
      return 'png';
    } else if (path.endsWith('.webp')) {
      return 'webp';
    } else {
      return 'jpeg'; // default
    }
  }

  // Convert image to base64 with proper format detection
  // Only File is supported for image conversion. Pass a File loaded from local storage.
  Future<String?> convertImageToBase64(File imageFile) async {
    try {
      if (!await validateImage(imageFile)) {
        return null;
      }

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final format = getImageFormat(imageFile);

      return 'data:image/$format;base64,$base64String';
    } catch (e) {
      errorMessage.value = 'Failed to convert image to base64: ${e.toString()}';
      return null;
    }
  }

  // Perform virtual try-on with File object
  Future<void> performVirtualTryOn(File productImageFile) async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Please select a model image first';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('Starting virtual try-on process...');
      print('Model image path: ${selectedImage.value!.path}');
      print('Product image path: ${productImageFile.path}');

      // Convert both images to base64 with validation
      String? modelImageUrl = await convertImageToBase64(selectedImage.value!);
      String? productImageUrl = await convertImageToBase64(productImageFile);

      if (modelImageUrl == null || productImageUrl == null) {
        errorMessage.value = 'Failed to prepare images for API';
        return;
      }

      print('Model image format: ${modelImageUrl.substring(0, modelImageUrl.indexOf(';'))}');
      print('Product image format: ${productImageUrl.substring(0, productImageUrl.indexOf(';'))}');
      print('Model image length: ${modelImageUrl.length}');
      print('Product image length: ${productImageUrl.length}');

      // Prepare the request body
      final requestBody = {
        'model_name': VirtualTryOnConfig.modelName,
        'inputs': {
          'model_image': modelImageUrl,
          'garment_image': productImageUrl,
        }
      };

      print('Sending request to API...');
      print('API URL: ${VirtualTryOnConfig.apiUrl}');
      print('Model name: ${VirtualTryOnConfig.modelName}');

      // Make the API request
      final response = await http.post(
        Uri.parse(VirtualTryOnConfig.apiUrl),
        headers: {
          'Authorization': 'Bearer ${VirtualTryOnConfig.getApiKey()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: VirtualTryOnConfig.requestTimeoutSeconds));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Full API Response: $responseData');

        if (responseData['error'] != null) {
          errorMessage.value = 'API Error: ${responseData['error']}';
          print('API Error: ${responseData['error']}');
          return;
        }

        if (responseData['id'] != null) {
          print('Job ID received: ${responseData['id']}');
          await Future.delayed(Duration(seconds: 5));
          await checkJobStatus(responseData['id']);
        } else if (responseData['output'] != null && responseData['output']['image_url'] != null) {
          await downloadResultImage(responseData['output']['image_url']);
        } else {
          errorMessage.value = 'Unexpected API response format';
          print('Unexpected API response: $responseData');
        }
      } else if (response.statusCode == 401) {
        errorMessage.value = 'API key is invalid or missing. Please check your API key in virtual_config.dart and make sure you have a valid fashn.ai API key.';
      } else if (response.statusCode == 429) {
        errorMessage.value = 'API rate limit exceeded. Please try again later.';
      } else {
        errorMessage.value = 'API request failed with status: ${response.statusCode}';
        print('API Error Response: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        errorMessage.value = 'Request timed out. Please try again.';
      } else {
        errorMessage.value = 'Error performing virtual try-on: ${e.toString()}';
      }
      print('Exception during API call: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check job status for async processing
  Future<void> checkJobStatus(String jobId, {int attempts = 0}) async {
    if (attempts >= 20) {
      errorMessage.value = 'Job processing timed out. Please try again.';
      return;
    }
    try {
      print('Checking job status for ID: $jobId');
      final statusUrl = 'https://api.fashn.ai/v1/status/$jobId';
      print('Status URL: $statusUrl');

      final response = await http.get(
        Uri.parse(statusUrl),
        headers: {
          'Authorization': 'Bearer ${VirtualTryOnConfig.getApiKey()}',
        },
      ).timeout(Duration(seconds: 30));

      print('Job status response: ${response.statusCode}');
      print('Job status body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'completed' && responseData['output'] != null) {
          if (responseData['output'] is List && responseData['output'].isNotEmpty) {
            await downloadResultImage(responseData['output'][0]);
          } else if (responseData['output'] is Map && responseData['output']['image_url'] != null) {
            await downloadResultImage(responseData['output']['image_url']);
          } else {
            errorMessage.value = 'Unexpected output format from API';
            print('Unexpected output: ${responseData['output']}');
          }
        } else if (responseData['status'] == 'processing' || responseData['status'] == 'pending') {
          await Future.delayed(Duration(seconds: 3));
          await checkJobStatus(jobId, attempts: attempts + 1);
        } else {
          errorMessage.value = 'Job failed or timed out. Status: ${responseData['status']}';
          print('Job status: ${responseData}');
        }
      } else if (response.statusCode == 404) {
        await Future.delayed(Duration(seconds: 5));
        await checkJobStatus(jobId, attempts: attempts + 1);
      } else {
        errorMessage.value = 'Failed to check job status. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error checking job status: ${e.toString()}';
      print('Job status error: $e');
    }
  }

  // Download the result image
  Future<void> downloadResultImage(String imageUrl) async {
    try {
      print('Downloading result image from: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl))
          .timeout(Duration(seconds: VirtualTryOnConfig.downloadTimeoutSeconds));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'virtual_tryon_result_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = path.join(tempDir.path, fileName);

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        resultImage.value = file;
        print('Result image saved to: $filePath');
      } else {
        errorMessage.value = 'Failed to download result image. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error downloading result image: ${e.toString()}';
      print('Error downloading image: $e');
    }
  }

  // Clear all data
  void clearData() {
    selectedImage.value = null;
    resultImage.value = null;
    resultImageUrl.value = '';
    errorMessage.value = '';
  }

  // Check if we can proceed with virtual try-on
  bool get canProceedWithTryOn {
    return selectedImage.value != null && !isLoading.value;
  }

  // Get API key status
  bool get isApiKeyConfigured {
    return VirtualTryOnConfig.isApiKeyConfigured;
  }
}