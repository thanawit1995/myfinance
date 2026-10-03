import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/vault_theme.dart';

class EditCreditCardDialog extends ConsumerStatefulWidget {
  final Account account;

  const EditCreditCardDialog({super.key, required this.account});

  static Future<bool?> show(BuildContext context, {required Account account}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditCreditCardDialog(account: account),
    );
  }

  @override
  ConsumerState<EditCreditCardDialog> createState() => _EditCreditCardDialogState();
}

class _EditCreditCardDialogState extends ConsumerState<EditCreditCardDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _closingDayController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _creditLimitController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _closingDayController = TextEditingController(text: (widget.account.closingDay ?? 23).toString());
    _dueDayController = TextEditingController(text: (widget.account.dueDay ?? 10).toString());

    final limitSatang = widget.account.creditLimitSatang;
    final limitStr = (limitSatang != null && limitSatang > 0)
        ? (limitSatang / 100).toStringAsFixed(0)
        : '';
    _creditLimitController = TextEditingController(text: limitStr);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final closingDay = int.parse(_closingDayController.text.trim());
      final dueDay = int.parse(_dueDayController.text.trim());

      final limitText = _creditLimitController.text.trim().replaceAll(',', '');
      final limitDouble = double.tryParse(limitText);
      final creditLimitSatang = (limitDouble != null && limitDouble > 0)
          ? (limitDouble * 100).round()
          : null;

      await ref.read(accountsDaoProvider).updateCreditCardDetails(
        id: widget.account.id,
        name: name,
        closingDay: closingDay,
        dueDay: dueDay,
        creditLimitSatang: creditLimitSatang,
      );

      ref.read(transactionsVersionProvider.notifier).state++;
      ref.invalidate(accountsDaoProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isLumi = VaultTheme.isLumi(context);
    final accent = isLumi ? const Color(0xFFFF5B9A) : VaultTheme.accent(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);
    final surface = VaultTheme.surface(context);

    final currentClosingDay = int.tryParse(_closingDayController.text.trim()) ?? 23;
    final currentDueDay = int.tryParse(_dueDayController.text.trim()) ?? 10;

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.credit_card_rounded, color: accent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isThai ? 'แก้ไขข้อมูลบัตรเครดิต' : 'Edit Credit Card',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isThai ? 'ปรับแต่งรอบบิลและวันชำระเงิน' : 'Customize cycle & due dates',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isThai ? 'ชื่อบัตรเครดิต' : 'Credit Card Name',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return isThai ? 'โปรดระบุชื่อบัตรเครดิต' : 'Card name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Days Row: Closing Day & Payment Due Day
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Closing Day
                    Expanded(
                      child: TextFormField(
                        controller: _closingDayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: isThai ? 'วันตัดรอบ (1-31)' : 'Closing Day (1-31)',
                          hintText: '23',
                          prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          helperText: isThai ? 'สรุปยอดทุกวันที่' : 'Closes on day',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return isThai ? 'โปรดระบุ' : 'Required';
                          }
                          final d = int.tryParse(v.trim());
                          if (d == null || d < 1 || d > 31) {
                            return isThai ? '1-31 เท่านั้น' : '1-31 only';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Payment Due Day
                    Expanded(
                      child: TextFormField(
                        controller: _dueDayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: isThai ? 'วันชำระ (1-31)' : 'Due Day (1-31)',
                          hintText: '10',
                          prefixIcon: const Icon(Icons.event_available_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          helperText: isThai ? 'ครบชำระวันที่' : 'Due on day',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return isThai ? 'โปรดระบุ' : 'Required';
                          }
                          final d = int.tryParse(v.trim());
                          if (d == null || d < 1 || d > 31) {
                            return isThai ? '1-31 เท่านั้น' : '1-31 only';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Credit Limit (Optional)
                TextFormField(
                  controller: _creditLimitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isThai ? 'วงเงินบัตรเครดิต (ไม่บังคับ)' : 'Credit Limit (Optional)',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                    suffixText: 'THB',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 18),

                // Realtime Preview Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isThai
                              ? 'ตัดรอบบิลทุกวันที่ $currentClosingDay ของเดือน และครบกำหนดชำระวันที่ $currentDueDay ของเดือนถัดไป'
                              : 'Statement closes on day $currentClosingDay and payment is due on day $currentDueDay of next month.',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                      child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isThai ? 'บันทึก' : 'Save',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
