import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfinance/features/onboarding/presentation/partner_welcome_tutorial_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({String partnerName = 'Pealpeal'}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => PartnerWelcomeTutorialDialog.show(context, partnerName: partnerName),
            child: const Text('Open Welcome'),
          ),
        ),
      ),
    );
  }

  group('PartnerWelcomeTutorialDialog Tests', () {
    testWidgets('Renders slide 1 with custom partner name and navigates through all 4 slides', (tester) async {
      await tester.pumpWidget(createTestWidget(partnerName: 'Pealpeal'));

      // Open dialog
      await tester.tap(find.text('Open Welcome'));
      await tester.pumpAndSettle();

      // Slide 1 checks
      expect(find.text('Welcome, Pealpeal 💕'), findsOneWidget);
      expect(find.text('OURS SPECIAL GIFT 💕'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap Next -> Slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Gentle & Uplifting Design'), findsOneWidget);
      expect(find.text('SUNNY BLOOM STYLE 🌸'), findsOneWidget);

      // Tap Next -> Slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Effortless Daily Moments'), findsOneWidget);
      expect(find.text('3-SECOND LOGGING ☕'), findsOneWidget);

      // Tap Next -> Slide 4 (iPhone 14 Pro guide)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Add to Your Home Screen'), findsOneWidget);
      expect(find.text('FOR YOUR IPHONE 14 PRO 📱'), findsOneWidget);
      expect(find.text('Let\'s Begin, Pealpeal 💖'), findsOneWidget);

      // Finish tutorial
      await tester.tap(find.text('Let\'s Begin, Pealpeal 💖'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.text('Welcome, Pealpeal 💕'), findsNothing);

      // Verify SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_partner_tutorial'), true);
      expect(prefs.getBool('should_show_partner_welcome'), null);
    });

    testWidgets('Skip button dismisses dialog immediately and marks tutorial as seen', (tester) async {
      await tester.pumpWidget(createTestWidget(partnerName: 'Pealpeal'));

      await tester.tap(find.text('Open Welcome'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome, Pealpeal 💕'), findsOneWidget);

      // Tap Skip on slide 1
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.text('Welcome, Pealpeal 💕'), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_partner_tutorial'), true);
    });
  });
}
