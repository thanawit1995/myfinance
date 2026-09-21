class RemittanceAssessmentResult {
  final bool isTaxable;
  final String statusLabel;
  final String reasonTh;
  final String legalReferenceTh;

  const RemittanceAssessmentResult({
    required this.isTaxable,
    required this.statusLabel,
    required this.reasonTh,
    required this.legalReferenceTh,
  });
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
        reasonTh: 'เงินที่นำกลับเข้ามาเป็นเงินต้นเดิมที่เคยส่งออกไปลงทุน ไม่ถือเป็นเงินได้พึงประเมิน',
        legalReferenceTh: 'ประมวลรัษฎากร มาตรา 39 และมาตรา 40 (เงินต้นไม่ใช่เงินได้)',
      );
    }

    // 2. Pre-2024 Earned Income Exemption (ป.162/2566)
    if (taxYearEarned != null && taxYearEarned < 2024 && pre2024ExemptEnabled) {
      return RemittanceAssessmentResult(
        isTaxable: false,
        statusLabel: 'ยกเว้นภาษี (เกิดก่อนปี 2024)',
        reasonTh: 'เงินได้เกิดขึ้นในปีภาษี $taxYearEarned (ก่อน 1 ม.ค. 2024) นำเข้าไทยข้ามปีภาษี',
        legalReferenceTh: 'คำสั่งกรมสรรพากรที่ ป.162/2566 ข้อ 2',
      );
    }

    // 3. 180-Day Residency in Remitted Year Check
    if (daysInThailandYearRemitted != null && daysInThailandYearRemitted < residencyThreshold) {
      return RemittanceAssessmentResult(
        isTaxable: false,
        statusLabel: 'ยกเว้นภาษี (อยู่ไทยไม่ถึง 180 วัน)',
        reasonTh: 'ในปีที่นำเงินเข้า ($taxYearRemitted) พำนักในไทยรวม $daysInThailandYearRemitted วัน (ไม่ถึง $residencyThreshold วัน) ไม่ถือเป็นผู้อยู่ในประเทศไทย',
        legalReferenceTh: 'ประมวลรัษฎากร มาตรา 41 วรรคสาม',
      );
    }

    // 4. If days in Thailand is unknown / not yet specified
    if (daysInThailandYearRemitted == null) {
      return RemittanceAssessmentResult(
        isTaxable: true, // Conditionally flagged pending residency input
        statusLabel: 'รอยืนยันจำนวนวันในไทย',
        reasonTh: 'ยังไม่ได้ระบุจำนวนวันที่อยู่ในไทยของปี $taxYearRemitted (หากอยู่ >= $residencyThreshold วันจะต้องเสียภาษี)',
        legalReferenceTh: 'คำสั่งกรมสรรพากรที่ ป.161/2566',
      );
    }

    // 5. Taxable under Order P.161/2566
    return RemittanceAssessmentResult(
      isTaxable: true,
      statusLabel: 'ต้องเสียภาษีเงินได้',
      reasonTh: 'เป็นเงินได้พึงประเมินที่นำเข้ามาในไทยในปีภาษี $taxYearRemitted ซึ่งผู้มีเงินได้อยู่ในไทยรวม $daysInThailandYearRemitted วัน (>= $residencyThreshold วัน)',
      legalReferenceTh: 'คำสั่งกรมสรรพากรที่ ป.161/2566 ข้อ 1 และ ป.163/2567',
    );
  }
}
