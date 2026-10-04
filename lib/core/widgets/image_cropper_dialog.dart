import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

/// Pure Flutter interactive image cropper dialog that works across
/// Web, Windows Desktop, and Android without requiring native platform-specific plugins.
/// Features:
/// - WYSIWYG crop accuracy (1:1 with what you see on screen)
/// - Dimmed overlay so you can see image borders outside the crop window
/// - Rotate 90° clockwise support
/// - Zoom slider & buttons for mouse/desktop and fine touch adjustments
/// - Reset button to center and fit
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
  int _rotationQuarterTurns = 0; // 0, 1, 2, 3 (each is 90 deg clockwise)
  double _currentScale = 1.0;

  // Viewport dimensions for cropping window
  static const double _cropWindowWidth = 260.0;
  double get _cropWindowHeight => _cropWindowWidth / widget.aspectRatio;

  // Outer container size that lets user see surrounding image areas
  static const double _viewportWidth = 300.0;
  double get _viewportHeight => math.max(_cropWindowHeight + 36.0, 280.0);

  @override
  void initState() {
    super.initState();
    _decodeImage();
    _controller.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01 && mounted) {
      setState(() {
        _currentScale = scale.clamp(0.5, 4.0);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformationChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _decodeImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _decodedImage = frame.image;
        _resetTransform(frame.image, _rotationQuarterTurns);
      });
    }
  }

  /// Calculates the effective width and height after rotation
  Size _getRotatedSize(ui.Image img, int quarterTurns) {
    if (quarterTurns % 2 == 1) {
      return Size(img.height.toDouble(), img.width.toDouble());
    }
    return Size(img.width.toDouble(), img.height.toDouble());
  }

  void _resetTransform(ui.Image? img, int quarterTurns) {
    if (img == null) return;
    final rSize = _getRotatedSize(img, quarterTurns);

    final scaleToFitW = _cropWindowWidth / rSize.width;
    final scaleToFitH = _cropWindowHeight / rSize.height;
    final baseScale = math.max(scaleToFitW, scaleToFitH);

    final displayW = rSize.width * baseScale;
    final displayH = rSize.height * baseScale;

    final initialTx = (_viewportWidth - displayW) / 2.0;
    final initialTy = (_viewportHeight - displayH) / 2.0;

    _controller.value = Matrix4.identity()
      ..translateByVector3(v64.Vector3(initialTx, initialTy, 0.0));
    _currentScale = 1.0;
  }

  void _rotateClockwise() {
    if (_decodedImage == null) return;
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
      _resetTransform(_decodedImage, _rotationQuarterTurns);
    });
  }

  void _onScaleSliderChanged(double newScale) {
    if (_decodedImage == null) return;
    final currentMatrix = _controller.value;
    final oldScale = currentMatrix.getMaxScaleOnAxis();
    if (oldScale <= 0) return;

    final scaleMultiplier = newScale / oldScale;

    // Zoom centered on crop window center
    final centerViewport = Offset(_viewportWidth / 2.0, _viewportHeight / 2.0);

    final matrix = Matrix4.identity()
      ..translateByVector3(v64.Vector3(centerViewport.dx, centerViewport.dy, 0.0))
      ..scaleByVector3(v64.Vector3(scaleMultiplier, scaleMultiplier, 1.0))
      ..translateByVector3(v64.Vector3(-centerViewport.dx, -centerViewport.dy, 0.0))
      ..multiply(currentMatrix);

    _controller.value = matrix;
    setState(() {
      _currentScale = newScale;
    });
  }

  Future<void> _cropAndFinish() async {
    if (_decodedImage == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final img = _decodedImage!;
      final rSize = _getRotatedSize(img, _rotationQuarterTurns);

      final scaleToFitW = _cropWindowWidth / rSize.width;
      final scaleToFitH = _cropWindowHeight / rSize.height;
      final baseScale = math.max(scaleToFitW, scaleToFitH);

      final displayW = rSize.width * baseScale;
      final displayH = rSize.height * baseScale;

      // Crop window bounds inside the viewport
      final cropWindowLeft = (_viewportWidth - _cropWindowWidth) / 2.0;
      final cropWindowTop = (_viewportHeight - _cropWindowHeight) / 2.0;

      // Desired output resolution (max 512 for smooth rendering and compact storage)
      const maxTargetDimension = 512.0;
      final targetWidth = widget.aspectRatio >= 1.0
          ? maxTargetDimension
          : maxTargetDimension * widget.aspectRatio;
      final targetHeight = targetWidth / widget.aspectRatio;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, targetWidth, targetHeight));

      // 1. Scale from crop window coords to target canvas resolution
      final outputScale = targetWidth / _cropWindowWidth;
      canvas.scale(outputScale, outputScale);

      // 2. Shift crop window origin to (0, 0)
      canvas.translate(-cropWindowLeft, -cropWindowTop);

      // 3. Apply the user's interactive viewer transformation matrix
      canvas.transform(_controller.value.storage);

      // 4. Draw rotated image exactly as rendered in InteractiveViewer's displayW x displayH box
      canvas.save();
      canvas.translate(displayW / 2.0, displayH / 2.0);
      canvas.rotate(_rotationQuarterTurns * math.pi / 2.0);

      // Raw unrotated image source dimensions
      final imgW = img.width.toDouble();
      final imgH = img.height.toDouble();
      final origScaledW = imgW * baseScale;
      final origScaledH = imgH * baseScale;

      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, imgW, imgH),
        Rect.fromLTWH(
          -origScaledW / 2.0,
          -origScaledH / 2.0,
          origScaledW,
          origScaledH,
        ),
        Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high,
      );
      canvas.restore();

      final picture = recorder.endRecording();
      final outputImage = await picture.toImage(targetWidth.round(), targetHeight.round());
      final byteData = await outputImage.toByteData(format: ui.ImageByteFormat.png);

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
    final cropBoxRadius = widget.aspectRatio == 1.0 ? _cropWindowWidth / 2.0 : 16.0;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.crop_rounded, color: Color(0xFFFF5C9D), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isThai
                    ? 'ลากเลื่อน ซูม หรือหมุนรูปภาพเพื่อจัดให้อยู่ในกรอบ'
                    : 'Pan, zoom, or rotate to fit inside the frame',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Interactive Crop Viewport with Dimmed Overlay Cutout
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: _viewportWidth,
                  height: _viewportHeight,
                  color: Colors.black,
                  child: _decodedImage == null
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C9D)))
                      : Stack(
                          children: [
                            // 1. Interactive Image Layer
                            Builder(
                              builder: (context) {
                                final img = _decodedImage!;
                                final rSize = _getRotatedSize(img, _rotationQuarterTurns);
                                final scaleToFitW = _cropWindowWidth / rSize.width;
                                final scaleToFitH = _cropWindowHeight / rSize.height;
                                final baseScale = math.max(scaleToFitW, scaleToFitH);

                                final displayW = rSize.width * baseScale;
                                final displayH = rSize.height * baseScale;
                                final unrotatedW = img.width * baseScale;
                                final unrotatedH = img.height * baseScale;

                                return InteractiveViewer(
                                  transformationController: _controller,
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  boundaryMargin: const EdgeInsets.all(240),
                                  child: SizedBox(
                                    width: displayW,
                                    height: displayH,
                                    child: Center(
                                      child: Transform.rotate(
                                        angle: _rotationQuarterTurns * math.pi / 2.0,
                                        child: RawImage(
                                          image: img,
                                          width: unrotatedW,
                                          height: unrotatedH,
                                          fit: BoxFit.fill,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 2. Dimmed Cutout Overlay + Guide Frame
                            IgnorePointer(
                              child: CustomPaint(
                                size: Size(_viewportWidth, _viewportHeight),
                                painter: _CropOverlayPainter(
                                  cropWidth: _cropWindowWidth,
                                  cropHeight: _cropWindowHeight,
                                  borderRadius: cropBoxRadius,
                                  isCircle: widget.aspectRatio == 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // Zoom Slider & Quick Adjustment Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out_rounded, color: Colors.white70, size: 20),
                    tooltip: isThai ? 'ซูมออก' : 'Zoom out',
                    onPressed: () => _onScaleSliderChanged((_currentScale - 0.2).clamp(0.5, 4.0)),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFF5C9D),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _currentScale.clamp(0.5, 4.0),
                        min: 0.5,
                        max: 4.0,
                        onChanged: _onScaleSliderChanged,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 20),
                    tooltip: isThai ? 'ซูมเข้า' : 'Zoom in',
                    onPressed: () => _onScaleSliderChanged((_currentScale + 0.2).clamp(0.5, 4.0)),
                  ),
                ],
              ),

              // Rotate & Reset Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.rotate_right_rounded, size: 18),
                    label: Text(isThai ? 'หมุน 90°' : 'Rotate 90°', style: const TextStyle(fontSize: 12.5)),
                    onPressed: _rotateClockwise,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: Text(isThai ? 'รีเซ็ต' : 'Reset', style: const TextStyle(fontSize: 12.5)),
                    onPressed: () => setState(() => _resetTransform(_decodedImage, _rotationQuarterTurns)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons (Cancel / Save)
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
                          : Text(
                              isThai ? 'บันทึกรูปภาพ' : 'Save Crop',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dimmed outer cutout and crisp guidelines
class _CropOverlayPainter extends CustomPainter {
  final double cropWidth;
  final double cropHeight;
  final double borderRadius;
  final bool isCircle;

  _CropOverlayPainter({
    required this.cropWidth,
    required this.cropHeight,
    required this.borderRadius,
    required this.isCircle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cropLeft = (size.width - cropWidth) / 2.0;
    final cropTop = (size.height - cropHeight) / 2.0;
    final cropRect = Rect.fromLTWH(cropLeft, cropTop, cropWidth, cropHeight);

    // Path for outer screen
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Path for hole
    final holePath = Path();
    if (isCircle) {
      holePath.addOval(cropRect);
    } else {
      holePath.addRRect(RRect.fromRectAndRadius(cropRect, Radius.circular(borderRadius)));
    }

    // Difference = Dimmed area
    final overlayPath = Path.combine(PathOperation.difference, outerPath, holePath);
    final dimmedPaint = Paint()..color = const Color(0xB3000000); // 70% black
    canvas.drawPath(overlayPath, dimmedPaint);

    // Border line
    final borderPaint = Paint()
      ..color = const Color(0xFFFF5C9D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isCircle) {
      canvas.drawOval(cropRect, borderPaint);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(cropRect, Radius.circular(borderRadius)), borderPaint);
    }

    // Rule of thirds subtle grid lines inside the crop rect
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final stepX = cropWidth / 3.0;
    final stepY = cropHeight / 3.0;

    canvas.save();
    canvas.clipPath(holePath);
    // Vertical grid lines
    canvas.drawLine(Offset(cropLeft + stepX, cropTop), Offset(cropLeft + stepX, cropTop + cropHeight), gridPaint);
    canvas.drawLine(Offset(cropLeft + stepX * 2, cropTop), Offset(cropLeft + stepX * 2, cropTop + cropHeight), gridPaint);
    // Horizontal grid lines
    canvas.drawLine(Offset(cropLeft, cropTop + stepY), Offset(cropLeft + cropWidth, cropTop + stepY), gridPaint);
    canvas.drawLine(Offset(cropLeft, cropTop + stepY * 2), Offset(cropLeft + cropWidth, cropTop + stepY * 2), gridPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropWidth != cropWidth ||
        oldDelegate.cropHeight != cropHeight ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.borderRadius != borderRadius;
  }
}
