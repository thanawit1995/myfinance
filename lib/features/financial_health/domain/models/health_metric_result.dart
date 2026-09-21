enum HealthStatus {
  pass,
  warning,
  fail,
}

class MetricBreakdownItem {
  final String label;
  final String formattedValue;
  final String? note;

  const MetricBreakdownItem({
    required this.label,
    required this.formattedValue,
    this.note,
  });
}

class HealthMetricResult {
  final int metricIndex; // 1 to 8
  final String code;
  final String title;
  final String subtitle;
  final num currentValue;
  final String formattedValue;
  final String targetThreshold;
  final HealthStatus status;
  final int score;
  final int maxScore;
  final String formulaDescription;
  final List<MetricBreakdownItem> breakdownItems;
  final String recommendation;

  const HealthMetricResult({
    required this.metricIndex,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.formattedValue,
    required this.targetThreshold,
    required this.status,
    required this.score,
    required this.maxScore,
    required this.formulaDescription,
    required this.breakdownItems,
    required this.recommendation,
  });
}

class FinancialHealthSummary {
  final int totalScore; // 0 to 100
  final HealthStatus overallStatus;
  final List<HealthMetricResult> metrics;
  final List<String> prioritizedRecommendations;

  const FinancialHealthSummary({
    required this.totalScore,
    required this.overallStatus,
    required this.metrics,
    required this.prioritizedRecommendations,
  });
}
