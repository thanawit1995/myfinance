import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/vault_theme.dart';

/// Fullscreen celebration overlay that animates on successful transaction submission
class TransactionSuccessOverlay {
  static void show(BuildContext context) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _SuccessCelebrationWidget(
        onDismiss: () {
          try {
            entry.remove();
          } catch (_) {}
        },
      ),
    );

    overlayState.insert(entry);
  }
}

class _SuccessCelebrationWidget extends StatefulWidget {
  final VoidCallback onDismiss;

  const _SuccessCelebrationWidget({required this.onDismiss});

  @override
  State<_SuccessCelebrationWidget> createState() => _SuccessCelebrationWidgetState();
}

class _SuccessCelebrationWidgetState extends State<_SuccessCelebrationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _controller.forward().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isLumi = VaultTheme.isLumi(context);
    final count = isLumi ? 36 : 24;

    final palette = isLumi
        ? const [
            Color(0xFFFF75A0),
            Color(0xFFFFB26B),
            Color(0xFFFFD93D),
            Color(0xFF6BCB77),
            Color(0xFF4D96FF),
            Color(0xFF9D4EDD),
          ]
        : const [
            Color(0xFFD4AF37), // Metallic Gold
            Color(0xFFF3E5AB), // Vanilla Gold
            Color(0xFFC5A059), // Champagne
            Color(0xFF2ECC71), // Success emerald
            Color(0xFFE2E8F0), // Platinum
          ];

    _particles = List.generate(count, (index) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80.0 + _random.nextDouble() * 180.0;
      final size = isLumi ? 6.0 + _random.nextDouble() * 8.0 : 4.0 + _random.nextDouble() * 6.0;
      final color = palette[_random.nextInt(palette.length)];
      final isCircle = isLumi ? _random.nextBool() : true;

      return _Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: color,
        isCircle: isCircle,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLumi = VaultTheme.isLumi(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final scale = Tween<double>(begin: 0.2, end: 1.0)
              .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack)))
              .value;

          return Stack(
            children: [
              // Particles
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: progress,
                  ),
                ),
              ),

              // Central animated badge
              Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      decoration: BoxDecoration(
                        color: isLumi ? Colors.white : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: (isLumi ? const Color(0xFFFF5C9D) : const Color(0xFFD4AF37)).withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(
                          color: isLumi ? const Color(0xFFFF5C9D) : const Color(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLumi ? Icons.celebration_rounded : Icons.check_circle_rounded,
                            color: isLumi ? const Color(0xFFFF5C9D) : const Color(0xFFD4AF37),
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isLumi ? 'บันทึกสำเร็จ ✨' : 'SAVED SUCCESSFULLY',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: isLumi ? 0.3 : 1.2,
                              color: isLumi ? const Color(0xFF2B2338) : Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final bool isCircle;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.isCircle,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final distance = p.speed * progress;
      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance + (progress * progress * 80.0); // slight gravity
      final alpha = ((1.0 - progress) * 255).clamp(0, 255).toInt();
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..style = PaintingStyle.fill;

      if (p.isCircle) {
        canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress * 0.3), paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: p.size, height: p.size),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
