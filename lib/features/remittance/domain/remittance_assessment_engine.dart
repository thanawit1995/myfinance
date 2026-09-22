class RemittanceAssessmentResult {
  final bool isTaxable;
  final String statusLabel;
  final String statusLabelEn;
  final String reasonTh;
  final String reasonEn;
  final String legalReferenceTh;
  final String legalReferenceEn;

  const RemittanceAssessmentResult({
    required this.isTaxable,
    required this.statusLabel,
    required this.statusLabelEn,
    required this.reasonTh,
    required this.reasonEn,
    required this.legalReferenceTh,
    required this.legalReferenceEn,
  });

  String getLocalizedStatus(bool isThai) => isThai ? statusLabel : statusLabelEn;
  String getLocalizedReason(bool isThai) => isThai ? reasonTh : reasonEn;
}

class RemittanceAssessmentEngine {
  /// Assesses whether foreign remittance brought into Thailand is taxable under Thai Revenue Code.
  static RemittanceAssessmentResult assessRemittance({
    required bool isPrincipal,
    required int? taxYearEarned,
    required int taxYearRemitted,
    required int? daysInThailandYearRemitted,
    int residencyThreshold = 180,
    bool pre2024ExemptEnabled = true,
  }) {
    // 1. Principal / Capital Return Check
    if (isPrincipal) {
      return const RemittanceAssessmentResult(
        isTaxable: false,
        statusLabel: 'ยกเว้นภาษี (เงินต้น)',
        statusLabelEn: 'Exempt (Principal)',
        reasonTh: 'เงินที่นำกลับเข้ามาเป็นเงินต้นเดิมที่เคยส่งออกไปลงทุน ไม่ถือเป็นเงินได้พึงประเมิน',
        reasonEn: 'Remitted funds are original capital previously transferred abroad, not taxable income.',
        legalReferenceTh: 'ประมวลรัษฎากร มาตรา 39 และมาตรา 40 (เงินต้นไม่ใช่เงินได้)',
        legalReferenceEn: 'Revenue Code Section 39 & 40 (Capital return is not income)',
      );
    }

    // 2. Pre-2024 Earned Income Exemption (ป.162/2566)
    if (taxYearEarned != null && taxYearEarned < 2024 && pre2024ExemptEnabled) {
      return RemittanceAssessmentResult(
        isTaxable: false,
        statusLabel: 'ยกเว้นภาษี (เกิดก่อนปี 2024)',
        statusLabelEn: 'Exempt (Earned pre-2024)',
        reasonTh: 'เงินได้เกิดขึ้นในปีภาษี $taxYearEarned (ก่อน 1 ม.ค. 2024) นำเข้าไทยข้ามปีภาษี',
        reasonEn: 'Income was earned in tax year $taxYearEarned (before Jan 1, 2024) and remitted in a later year.',
        legalReferenceTh: 'คำสั่งกรมสรรพากรที่ ป.162/2566 ข้อ 2',
        legalReferenceEn: 'Revenue Department Order Paw 162/2566 Item 2',
      );
    }

    // 3. 180-Day Residency in Remitted Year Check
    if (daysInThailandYearRemitted != null && daysInThailandYearRemitted < residencyThreshold) {
      return RemittanceAssessmentResult(
        isTaxable: false,
        statusLabel: 'ยกเว้นภาษี (อยู่ไทยไม่ถึง 180 วัน)',
        statusLabelEn: 'Exempt (Non-Resident < 180 days)',
        reasonTh: 'ในปีที่นำเงินเข้า ($taxYearRemitted) พำนักในไทยรวม $daysInThailandYearRemitted วัน (ไม่ถึง $residencyThreshold วัน) ไม่ถือเป็นผู้อยู่ในประเทศไทย',
        reasonEn: 'Stayed in Thailand for $daysInThailandYearRemitted days in $taxYearRemitted (< $residencyThreshold days threshold), qualifying as non-tax-resident.',
        legalReferenceTh: 'ประมวลรัษฎากร มาตรา 41 วรรคสาม',
        legalReferenceEn: 'Revenue Code Section 41 Paragraph 3',
      );
    }

    // 4. If days in Thailand is unknown / not yet specified
    if (daysInThailandYearRemitted == null) {
      return RemittanceAssessmentResult(
        isTaxable: true, // Conditionally flagged pending residency input
        statusLabel: 'รอยืนยันจำนวนวันในไทย',
        statusLabelEn: 'Pending Residency Check',
        reasonTh: 'ยังไม่ได้ระบุจำนวนวันที่อยู่ในไทยของปี $taxYearRemitted (หากอยู่ >= $residencyThreshold วันจะต้องเสียภาษี)',
        reasonEn: 'Days stayed in Thailand during $taxYearRemitted not specified (taxable if >= $residencyThreshold days).',
        legalReferenceTh: 'คำสั่งกรมสรรพากรที่ ป.161/2566',
        legalReferenceEn: 'Revenue Department Order Paw 161/2566',
      );
    }

    // 5. Taxable under Order P.161/2566
    return RemittanceAssessmentResult(
      isTaxable: true,
      statusLabel: 'ต้องเสียภาษีเงินได้',
      statusLabelEn: 'Taxable Remittance',
      reasonTh: 'เป็นเงินได้พึงประเมินที่นำเข้ามาในไทยในปีภาษี $taxYearRemitted ซึ่งผู้มีเงินได้อยู่ในไทยรวม $daysInThailandYearRemitted วัน (>= $residencyThreshold วัน)',
      reasonEn: 'Assessable income remitted into Thailand in $taxYearRemitted while staying in Thailand >= $residencyThreshold days.',
      legalReferenceTh: 'คำสั่งกรมสรรพากรที่ ป.161/2566 ข้อ 1 และ ป.163/2567',
      legalReferenceEn: 'Revenue Department Order Paw 161/2566 & Paw 163/2567',
    );
  }
}
