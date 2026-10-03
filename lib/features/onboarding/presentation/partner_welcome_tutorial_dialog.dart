import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/lumi_theme.dart';

class PartnerWelcomeTutorialDialog extends StatefulWidget {
  final String partnerName;
  final VoidCallback? onCompleted;

  const PartnerWelcomeTutorialDialog({
    super.key,
    this.partnerName = 'Pealpeal',
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String partnerName = 'Pealpeal',
    VoidCallback? onCompleted,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PartnerWelcomeTutorialDialog(
        partnerName: partnerName,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PartnerWelcomeTutorialDialog> createState() => _PartnerWelcomeTutorialDialogState();
}

class _PartnerWelcomeTutorialDialogState extends State<PartnerWelcomeTutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_partner_tutorial', true);
    await prefs.remove('should_show_partner_welcome');
    if (mounted) {
      Navigator.of(context).pop();
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1B1522) : const Color(0xFFFFFDFC);
    final borderColor = isDark ? const Color(0xFF352742) : const Color(0xFFF7D9E4);
    final primaryTextColor = isDark ? const Color(0xFFFFF0F5) : const Color(0xFF332B32);
    final secondaryTextColor = isDark ? const Color(0xFFD8CEE0) : const Color(0xFF6B5863);
    final accentColor = isDark ? LumiTheme.darkAccent : LumiTheme.lightAccent;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 620),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : const Color(0x22FF5B9A),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header with Page Indicator & Skip button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(_totalPages, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive ? accentColor : (isDark ? Colors.white24 : const Color(0xFFE8D4DE)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      // Skip Button
                      if (_currentPage < _totalPages - 1)
                        TextButton(
                          onPressed: _finishTutorial,
                          style: TextButton.styleFrom(
                            foregroundColor: secondaryTextColor,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Skip', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        )
                      else
                        const SizedBox(width: 48, height: 32),
                    ],
                  ),
                ),

                // Carousel Body
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      // Slide 1: Welcome to OURS
                      _buildSlide(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFFF5B9A),
                        iconBgColor: isDark ? const Color(0xFF331525) : const Color(0xFFFFEEF5),
                        badgeText: 'OURS SPECIAL GIFT 💕',
                        badgeColor: const Color(0xFFFF5B9A),
                        title: 'Welcome, ${widget.partnerName} 💕',
                        description:
                            'OURS was specially crafted with love for you — a warm, calming space for your daily finances, personal dreams, and peace of mind.',
                        highlightBox: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF241A2D) : const Color(0xFFFFF4F8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF452B4E) : const Color(0xFFFFDDEB)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF5B9A), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Your private ledger is 100% personal & secure.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),

                      // Slide 2: Lumi Sunny Bloom
                      _buildSlide(
                        icon: Icons.local_florist_rounded,
                        iconColor: const Color(0xFFE28B23),
                        iconBgColor: isDark ? const Color(0xFF362817) : const Color(0xFFFFF6E6),
                        badgeText: 'SUNNY BLOOM STYLE 🌸',
                        badgeColor: const Color(0xFFE28B23),
                        title: 'Gentle & Uplifting Design',
                        description:
                            'Designed with soft pastel tones and rounded cards to make everyday money management feel cozy, light, and stress-free.',
                        highlightBox: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF221A2A) : const Color(0xFFFFF9F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF3F2F4E) : const Color(0xFFF3DCE5)),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildMiniBadge('🌸 Light & Cozy', isDark),
                              _buildMiniBadge('🌙 Sleep Friendly', isDark),
                              _buildMiniBadge('✨ Zero Clutter', isDark),
                            ],
                          ),
                        ),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),

                      // Slide 3: Quick & Joyful Tracking
                      _buildSlide(
                        icon: Icons.coffee_rounded,
                        iconColor: const Color(0xFF2E8B57),
                        iconBgColor: isDark ? const Color(0xFF162D20) : const Color(0xFFEDF8F1),
                        badgeText: '3-SECOND LOGGING ☕',
                        badgeColor: const Color(0xFF2E8B57),
                        title: 'Effortless Daily Moments',
                        description:
                            'Tap the floating (+) button at any time to record coffee dates, groceries, shopping, or happy surprises in just 3 seconds.',
                        highlightBox: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF18281F) : const Color(0xFFF2FAF5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF284E37) : const Color(0xFFD3EEDF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle_rounded, color: Color(0xFF2E8B57), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tap (+) anytime at the bottom bar to add a new record.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),

                      // Slide 4: Add to Home Screen (iPhone 14 Pro)
                      _buildSlide(
                        icon: Icons.ios_share_rounded,
                        iconColor: const Color(0xFF007AFF),
                        iconBgColor: isDark ? const Color(0xFF142436) : const Color(0xFFEEF5FF),
                        badgeText: 'FOR YOUR IPHONE 14 PRO 📱',
                        badgeColor: const Color(0xFF007AFF),
                        title: 'Add to Your Home Screen',
                        description:
                            'For the smoothest full-screen experience with no Safari address bar:',
                        highlightBox: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF172535) : const Color(0xFFF4F8FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF2A4261) : const Color(0xFFD6E6FF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('1. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const Icon(Icons.ios_share_rounded, color: Color(0xFF007AFF), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Tap Safari\'s Share button at the bottom',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('2. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const Icon(Icons.add_box_outlined, color: Color(0xFF007AFF), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Scroll down & select "Add to Home Screen"',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton.filledTonal(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF2C2237) : const Color(0xFFF5E4EC),
                            foregroundColor: primaryTextColor,
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (_currentPage < _totalPages - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _finishTutorial();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _totalPages - 1
                                ? 'Let\'s Begin, ${widget.partnerName} 💖'
                                : 'Next',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2337) : const Color(0xFFFFEEF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF6B5863),
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String description,
    required Widget highlightBox,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Circle
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: iconColor),
          ),
          const SizedBox(height: 14),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Highlight box
          highlightBox,
        ],
      ),
    );
  }
}
