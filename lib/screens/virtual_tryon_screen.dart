// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
// import 'package:image/image.dart' as img;
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
//
// class VirtualTryOnScreen extends StatefulWidget {
//   final String? outfitImagePath;
//   const VirtualTryOnScreen({Key? key, this.outfitImagePath}) : super(key: key);
//
//   @override
//   State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
// }
//
// class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
//   File? _userPhoto;
//   File? _compositedImage;
//   bool _loading = false;
//   String? _error;
//
//   void _manualOverlay(img.Image base, img.Image overlay, int dstX, int dstY) {
//     for (int y = 0; y < overlay.height; y++) {
//       for (int x = 0; x < overlay.width; x++) {
//         final ox = x;
//         final oy = y;
//         final bx = dstX + x;
//         final by = dstY + y;
//         if (bx >= 0 && bx < base.width && by >= 0 && by < base.height) {
//           final overlayPixel = overlay.getPixel(ox, oy);
//           final alpha = overlayPixel.a / 255.0;
//           if (alpha > 0) {
//             final basePixel = base.getPixel(bx, by);
//             final r = (overlayPixel.r * alpha + basePixel.r * (1 - alpha)).toInt();
//             final g = (overlayPixel.g * alpha + basePixel.g * (1 - alpha)).toInt();
//             final b = (overlayPixel.b * alpha + basePixel.b * (1 - alpha)).toInt();
//             final a = (overlayPixel.a * alpha + basePixel.a * (1 - alpha)).toInt();
//             base.setPixelRgba(bx, by, r, g, b, a);
//           }
//         }
//       }
//     }
//   }
//
//   // Utility: Download image from URL to local file
//   Future<File> _downloadImageToFile(String url, String filename) async {
//     final response = await http.get(Uri.parse(url));
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$filename');
//     await file.writeAsBytes(response.bodyBytes);
//     return file;
//   }
//
//   Future<void> _pickPhoto() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//       _compositedImage = null;
//     });
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(source: ImageSource.camera);
//       if (pickedFile == null) {
//         setState(() {
//           _loading = false;
//           _error = 'No photo selected.';
//         });
//         return;
//       }
//       _userPhoto = File(pickedFile.path);
//       await _processTryOn();
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _error = 'Failed to pick photo: $e';
//       });
//     }
//   }
//
//   Future<void> _processTryOn() async {
//     if (_userPhoto == null || widget.outfitImagePath == null || widget.outfitImagePath!.isEmpty) {
//       setState(() {
//         _loading = false;
//         _error = 'Missing photo or outfit image.';
//       });
//       return;
//     }
//     try {
//       print('outfitImagePath: " [widget.outfitImagePath]"');
//       // 1. Run segmentation
//       final inputImage = InputImage.fromFile(_userPhoto!);
//       final segmenter = SelfieSegmenter(mode: SegmenterMode.single);
//       final mask = await segmenter.processImage(inputImage);
//       await segmenter.close();
//       // 2. Load images
//       final userBytes = await _userPhoto!.readAsBytes();
//       File outfitFile;
//       if (widget.outfitImagePath!.startsWith('http')) {
//         // Download from URL to local file
//         final filename = 'outfit_${DateTime.now().millisecondsSinceEpoch}.png';
//         outfitFile = await _downloadImageToFile(widget.outfitImagePath!, filename);
//       } else {
//         outfitFile = File(widget.outfitImagePath!);
//       }
//       final outfitBytes = await outfitFile.readAsBytes();
//       img.Image? userImg = img.decodeImage(userBytes);
//       img.Image? outfitImg = img.decodeImage(outfitBytes);
//       if (userImg == null || outfitImg == null) throw 'Image decode failed.';
//       // 3. Resize outfit to fit torso area (centered, 60% width)
//       final outfitWidth = (userImg.width * 0.6).toInt();
//       final outfitHeight = (outfitImg.height * outfitWidth / outfitImg.width).toInt();
//       final resizedOutfit = img.copyResize(outfitImg, width: outfitWidth, height: outfitHeight);
//       // 4. Get segmentation mask as grayscale
//       if (mask == null) throw Exception('Segmentation mask is null.');
//       final maskData = mask.confidences;
//       final maskImg = img.Image(width: userImg.width, height: userImg.height);
//       for (int y = 0; y < userImg.height; y++) {
//         for (int x = 0; x < userImg.width; x++) {
//           final confidence = maskData[y * userImg.width + x];
//           final maskVal = (confidence * 255).toInt();
//           maskImg.setPixelRgba(x, y, maskVal, maskVal, maskVal, 255);
//         }
//       }
//       // 5. Composite: keep only person area, overlay outfit
//       final composited = img.Image.from(userImg);
//       // Apply mask: set background to white
//       for (int y = 0; y < userImg.height; y++) {
//         for (int x = 0; x < userImg.width; x++) {
//           final maskVal = maskImg.getPixel(x, y).r;
//           if (maskVal < 128) {
//             composited.setPixelRgba(x, y, 255, 255, 255, 255);
//           }
//         }
//       }
//       // Overlay outfit (centered)
//       final x0 = (userImg.width - outfitWidth) ~/ 2;
//       final y0 = (userImg.height * 0.32).toInt(); // approx. torso
//       _manualOverlay(composited, resizedOutfit, x0, y0);
//       // 6. Save composited image to temp file
//       final tempPath = '${_userPhoto!.parent.path}/tryon_result.png';
//       final resultFile = File(tempPath)..writeAsBytesSync(img.encodePng(composited));
//       setState(() {
//         _compositedImage = resultFile;
//         _loading = false;
//         _error = null;
//       });
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _error = 'Try-on failed: $e';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Virtual Try-On'),
//         backgroundColor: colorScheme.primary,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: _loading
//               ? Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 24),
//                     Text('Processing...'),
//                   ],
//                 )
//               : _compositedImage != null
//                   ? Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('Virtual Try-On Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                         SizedBox(height: 16),
//                         Image.file(_compositedImage!, fit: BoxFit.contain, height: 400),
//                         SizedBox(height: 24),
//                         ElevatedButton.icon(
//                           onPressed: _pickPhoto,
//                           icon: Icon(Icons.refresh),
//                           label: Text('Try Another Photo'),
//                         ),
//                       ],
//                     )
//                   : Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.camera_alt, size: 64, color: colorScheme.primary),
//                         SizedBox(height: 24),
//                         Text('Take a photo to try on this outfit!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//                         SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _pickPhoto,
//                           child: Text('Take Photo'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: colorScheme.primary,
//                             foregroundColor: colorScheme.background,
//                             padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                             textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         if (_error != null) ...[
//                           SizedBox(height: 24),
//                           Text(_error!, style: TextStyle(color: Colors.red)),
//                         ]
//                       ],
//                     ),
//         ),
//       ),
//     );
//   }
// }