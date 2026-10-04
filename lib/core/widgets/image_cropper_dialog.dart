import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Pure Flutter interactive image cropper dialog that works across
/// Web, Windows Desktop, and Android without requiring native platform-specific plugins.
class ImageCropperDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final double aspectRatio; // e.g. 1.0 for square, 0.9 for character
  final String title;

  const ImageCropperDialog({
    super.key,
    required this.imageBytes,
    this.aspectRatio = 1.0,
    this.title = 'ครอบตัดรูปภาพ',
  });

  /// Displays the crop dialog and returns the cropped image bytes (PNG).
  static Future<Uint8List?> show(
    BuildContext context, {
    required Uint8List imageBytes,
    double aspectRatio = 1.0,
    String? title,
  }) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImageCropperDialog(
        imageBytes: imageBytes,
        aspectRatio: aspectRatio,
        title: title ?? (isThai ? 'ครอบตัดรูปภาพ' : 'Crop Image'),
      ),
    );
  }

  @override
  State<ImageCropperDialog> createState() => _ImageCropperDialogState();
}

class _ImageCropperDialogState extends State<ImageCropperDialog> {
  final TransformationController _controller = TransformationController();
  ui.Image? _decodedImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  Future<void> _decodeImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _decodedImage = frame.image;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cropAndFinish() async {
    if (_decodedImage == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      const viewportWidth = 280.0;
      final viewportHeight = viewportWidth / widget.aspectRatio;

      final imgW = _decodedImage!.width.toDouble();
      final imgH = _decodedImage!.height.toDouble();

      // Determine initial fitted display size (BoxFit.cover to fill viewport)
      final scaleToFitWidth = viewportWidth / imgW;
      final scaleToFitHeight = viewportHeight / imgH;
      final baseScale = math.max(scaleToFitWidth, scaleToFitHeight);

      final displayW = imgW * baseScale;
      final displayH = imgH * baseScale;

      // Output resolution (capped at 512 for performance and storage)
      const maxTargetDimension = 512.0;
      final targetWidth = widget.aspectRatio >= 1.0
          ? maxTargetDimension
          : maxTargetDimension * widget.aspectRatio;
      final targetHeight = targetWidth / widget.aspectRatio;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetWidth, targetHeight));

      // Scaling factor from on-screen crop box to output bitmap
      final outputScale = targetWidth / viewportWidth;
      canvas.scale(outputScale, outputScale);

      // Apply the user's interactive viewer transformation matrix
      final matrix = _controller.value;
      canvas.transform(matrix.storage);

      // Draw the exact displayed image quad centered in viewport
      final initialOffsetX = (viewportWidth - displayW) / 2.0;
      final initialOffsetY = (viewportHeight - displayH) / 2.0;

      canvas.drawImageRect(
        _decodedImage!,
        Rect.fromLTWH(0, 0, imgW, imgH),
        Rect.fromLTWH(initialOffsetX, initialOffsetY, displayW, displayH),
        Paint()..isAntiAlias = true..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(targetWidth.round(), targetHeight.round());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        Navigator.pop(context, byteData.buffer.asUint8List());
      } else {
        if (mounted) Navigator.pop(context, widget.imageBytes);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) Navigator.pop(context, widget.imageBytes);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    const cropBoxWidth = 280.0;
    final cropBoxHeight = cropBoxWidth / widget.aspectRatio;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isThai
                  ? 'ลาก เลื่อน หรือซูมภาพเพื่อจัดวางให้อยู่ในกรอบ'
                  : 'Pan and pinch to position your image within the frame',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Crop Box Area
            Container(
              width: cropBoxWidth,
              height: cropBoxHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(widget.aspectRatio == 1.0 ? 140 : 16),
                border: Border.all(color: const Color(0xFFFF5C9D), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 12),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.aspectRatio == 1.0 ? 140 : 14),
                child: _decodedImage == null
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C9D)))
                    : Builder(
                        builder: (context) {
                          final imgW = _decodedImage!.width.toDouble();
                          final imgH = _decodedImage!.height.toDouble();
                          final scaleToFitWidth = cropBoxWidth / imgW;
                          final scaleToFitHeight = cropBoxHeight / imgH;
                          final baseScale = math.max(scaleToFitWidth, scaleToFitHeight);
                          final displayW = imgW * baseScale;
                          final displayH = imgH * baseScale;

                          return InteractiveViewer(
                            transformationController: _controller,
                            minScale: 0.5,
                            maxScale: 5.0,
                            boundaryMargin: const EdgeInsets.all(180),
                            child: SizedBox(
                              width: cropBoxWidth,
                              height: cropBoxHeight,
                              child: Center(
                                child: SizedBox(
                                  width: displayW,
                                  height: displayH,
                                  child: RawImage(
                                    image: _decodedImage,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C9D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isProcessing ? null : _cropAndFinish,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isThai ? 'บันทึกรูปภาพ' : 'Save Crop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
