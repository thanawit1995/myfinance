import 'package:flutter/material.dart';
import '../domain/models/health_metric_result.dart';

class MetricDetailSheet extends StatelessWidget {
  final HealthMetricResult metric;

  const MetricDetailSheet({super.key, required this.metric});

  static Future<void> show(BuildContext context, HealthMetricResult metric) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MetricDetailSheet(metric: metric),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final statusColor = _getStatusColor(metric.status);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Title & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isThai ? "ตัวชี้วัดที่" : "Metric #"} ${metric.metricIndex}: ${metric.code.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (metric.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          metric.subtitle,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(metric.status), size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(metric.status, isThai),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Score & Target Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(isThai ? 'คะแนนที่ได้' : 'Score', '${metric.score} / ${metric.maxScore}', statusColor),
                    Container(height: 36, width: 1, color: Colors.grey.shade300),
                    _buildStatColumn(isThai ? 'ค่าปัจจุบัน' : 'Current', metric.formattedValue, theme.colorScheme.onSurface),
                    Container(height: 36, width: 1, color: Colors.grey.shade300),
                    _buildStatColumn(isThai ? 'เกณฑ์เป้าหมาย' : 'Target', metric.targetThreshold, Colors.blueGrey.shade700),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Formula Box
            Text(
              isThai ? 'สูตรการคำนวณ' : 'Calculation Formula',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                metric.formulaDescription,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Source of Numbers (Transparent Breakdown)
            Text(
              isThai ? 'ที่มาของตัวเลข (Source of Numbers)' : 'Source of Numbers (Breakdown)',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (metric.breakdownItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(isThai ? 'ไม่มีตัวเลขแยกย่อย' : 'No breakdown data', style: TextStyle(color: Colors.grey.shade600)),
              )
            else
              ...metric.breakdownItems.map((item) => _buildBreakdownRow(context, item)),
            const SizedBox(height: 20),

            // Recommendation Card
            Text(
              isThai ? 'คำแนะนำและการปรับปรุง' : 'Recommendation & Next Steps',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: statusColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      metric.recommendation,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(isThai ? 'ปิดหน้าต่างนี้' : 'Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(BuildContext context, MetricBreakdownItem item) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 12.5),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.formattedValue,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.pass:
        return Colors.green.shade700;
      case HealthStatus.warning:
        return Colors.amber.shade800;
      case HealthStatus.fail:
        return Colors.red.shade700;
    }
  }

  IconData _getStatusIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.pass:
        return Icons.check_circle_outline;
      case HealthStatus.warning:
        return Icons.warning_amber_rounded;
      case HealthStatus.fail:
        return Icons.error_outline;
    }
  }

  String _getStatusLabel(HealthStatus status, bool isThai) {
    switch (status) {
      case HealthStatus.pass:
        return isThai ? 'ผ่านเกณฑ์ดี' : 'Pass';
      case HealthStatus.warning:
        return isThai ? 'เฝ้าระวัง' : 'Warning';
      case HealthStatus.fail:
        return isThai ? 'ต้องปรับปรุง' : 'Action Needed';
    }
  }
}
