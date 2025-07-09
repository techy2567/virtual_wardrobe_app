import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

class VirtualTryOnScreen extends StatefulWidget {
  final String? outfitImagePath;
  const VirtualTryOnScreen({Key? key, this.outfitImagePath}) : super(key: key);

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  bool _loading = false;
  bool _showResult = false;

  void _startTryOn() async {
    setState(() {
      _loading = true;
      _showResult = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _loading = false;
        _showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Try-On'),
        backgroundColor: colorScheme.primary,
      ),
      body: !_loading && !_showResult
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_front, size: 64, color: colorScheme.primary),
                  SizedBox(height: 24),
                  Text('Ready to try on this outfit virtually?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startTryOn,
                    child: Text('Start Virtual Try-On'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.background,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : _loading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 24),
                      Text('Processing outfit for virtual try-on...'),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // SVG silhouette fills the available space
                            Opacity(
                              opacity: 0.22,
                              child: SvgPicture.asset(
                                'assets/images/user_silhouette.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Center the clothing image
                            Align(
                              alignment: Alignment.center,
                              child: (widget.outfitImagePath != null && widget.outfitImagePath!.isNotEmpty)
                                  ? Image.file(
                                      File(widget.outfitImagePath!),
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      'assets/images/items/item1.jpeg',
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            // Demo label
                            Positioned(
                              bottom: 40,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Text(
                                    'Virtual Try-On Complete (Demo)',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 