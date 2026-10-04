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
      // Crop to square or aspect ratio at max 512x512 resolution for smooth performance & storage
      const targetSize = 512.0;
      final targetWidth = targetSize;
      final targetHeight = targetSize / widget.aspectRatio;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetWidth, targetHeight));

      // Calculate transformation from InteractiveViewer matrix
      final matrix = _controller.value;
      final scale = matrix.getMaxScaleOnAxis();
      final translationX = matrix.getTranslation().x;
      final translationY = matrix.getTranslation().y;

      // The crop window on screen
      const viewportSize = 280.0;
      final viewportHeight = viewportSize / widget.aspectRatio;

      // Draw with offset and scale to match the user's interactive positioning
      final scaleRatio = targetWidth / viewportSize;

      canvas.save();
      canvas.scale(scaleRatio, scaleRatio);
      canvas.translate(translationX, translationY);
      canvas.scale(scale, scale);

      // Fit image into initial viewport box
      final imgW = _decodedImage!.width.toDouble();
      final imgH = _decodedImage!.height.toDouble();

      final fittedScale = (viewportSize / imgW).clamp(0.001, 10.0);
      final renderW = imgW * fittedScale;
      final renderH = imgH * fittedScale;

      canvas.drawImageRect(
        _decodedImage!,
        Rect.fromLTWH(0, 0, imgW, imgH),
        Rect.fromLTWH(
          (viewportSize - renderW) / 2,
          (viewportHeight - renderH) / 2,
          renderW,
          renderH,
        ),
        Paint()..isAntiAlias = true,
      );

      canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(targetWidth.toInt(), targetHeight.toInt());
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
                    : InteractiveViewer(
                        transformationController: _controller,
                        minScale: 0.5,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(120),
                        child: Center(
                          child: RawImage(
                            image: _decodedImage,
                            fit: BoxFit.contain,
                          ),
                        ),
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
