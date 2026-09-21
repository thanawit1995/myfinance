import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/remittance/domain/remittance_assessment_engine.dart';

void main() {
  group('RemittanceAssessmentEngine Tests', () {
    test('Rule 1: Capital return / Principal is always exempt', () {
      final result = RemittanceAssessmentEngine.assessRemittance(
        isPrincipal: true,
        taxYearEarned: 2024,
        taxYearRemitted: 2025,
        daysInThailandYearRemitted: 250,
      );

      expect(result.isTaxable, false);
      expect(result.statusLabel, contains('เงินต้น'));
    });

    test('Rule 2: Pre-2024 earned income is exempt under Order P.162/2566', () {
      final result = RemittanceAssessmentEngine.assessRemittance(
        isPrincipal: false,
        taxYearEarned: 2023,
        taxYearRemitted: 2025,
        daysInThailandYearRemitted: 300,
        pre2024ExemptEnabled: true,
      );

      expect(result.isTaxable, false);
      expect(result.statusLabel, contains('เกิดก่อนปี 2024'));
      expect(result.legalReferenceTh, contains('ป.162/2566'));
    });

    test('Rule 3: Remitted year with < 180 days in Thailand is exempt', () {
      final result = RemittanceAssessmentEngine.assessRemittance(
        isPrincipal: false,
        taxYearEarned: 2024,
        taxYearRemitted: 2025,
        daysInThailandYearRemitted: 150, // Less than 180 days
      );

      expect(result.isTaxable, false);
      expect(result.statusLabel, contains('ไม่ถึง 180 วัน'));
      expect(result.legalReferenceTh, contains('มาตรา 41 วรรคสาม'));
    });

    test('Rule 4: Earned in 2024+, remitted in 2025 with >= 180 days in Thailand is taxable', () {
      final result = RemittanceAssessmentEngine.assessRemittance(
        isPrincipal: false,
        taxYearEarned: 2024,
        taxYearRemitted: 2025,
        daysInThailandYearRemitted: 200, // >= 180 days
      );

      expect(result.isTaxable, true);
      expect(result.statusLabel, contains('ต้องเสียภาษี'));
      expect(result.legalReferenceTh, contains('ป.161/2566'));
    });

    test('Rule 5: Pending residency when days in Thailand is not specified', () {
      final result = RemittanceAssessmentEngine.assessRemittance(
        isPrincipal: false,
        taxYearEarned: 2024,
        taxYearRemitted: 2025,
        daysInThailandYearRemitted: null,
      );

      expect(result.isTaxable, true);
      expect(result.statusLabel, contains('รอยืนยัน'));
    });
  });
}
