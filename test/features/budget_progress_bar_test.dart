import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/widgets/budget_progress_bar.dart';

void main() {
  group('BudgetProgressBar Component Tests', () {
    testWidgets('Calculates percent and renders trailing badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              spentSatang: 50000,
              limitSatang: 100000,
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('Handles zero limit safely without division by zero', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              spentSatang: 10000,
              limitSatang: 0,
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('Handles exceeded budget (>= 100%) cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              spentSatang: 120000,
              limitSatang: 100000,
            ),
          ),
        ),
      );

      expect(find.text('120%'), findsOneWidget);
    });

    testWidgets('Can hide trailing badge when showTrailingBadge is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              spentSatang: 75000,
              limitSatang: 100000,
              showTrailingBadge: false,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsNothing);
    });
  });
}
