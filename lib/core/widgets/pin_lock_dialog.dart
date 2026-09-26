import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/auth_provider.dart';

class PinLockDialog extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;
  final String title;
  final bool canCancel;

  const PinLockDialog({
    super.key,
    required this.onUnlocked,
    this.title = 'กรุณาใส่รหัส PIN 6 หลัก',
    this.canCancel = true,
  });

  static Future<bool> show(BuildContext context, {bool canCancel = true, String? title}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: canCancel,
      builder: (ctx) => PopScope(
        canPop: canCancel,
        child: PinLockDialog(
          onUnlocked: () => Navigator.of(ctx).pop(true),
          canCancel: canCancel,
          title: title ?? 'กรุณาใส่รหัส PIN 6 หลัก',
        ),
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PinLockDialog> createState() => _PinLockDialogState();
}

class _PinLockDialogState extends ConsumerState<PinLockDialog> {
  String _enteredPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final authService = ref.read(authServiceProvider);
    final enabled = await authService.isBiometricsEnabled();
    if (enabled) {
      final success = await authService.authenticateBiometric();
      if (success && mounted) {
        widget.onUnlocked();
      }
    }
  }

  void _onKeyPress(String key) {
    final authService = ref.read(authServiceProvider);
    if (authService.isLockedOut) {
      setState(() {
        _errorMessage = 'ใส่รหัสผิดเกินกำหนด กรุณารอ ${authService.remainingLockoutSeconds} วินาที';
      });
      return;
    }

    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += key;
        _errorMessage = null;
      });

      if (_enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authService = ref.read(authServiceProvider);
    if (authService.isLockedOut) {
      setState(() {
        _enteredPin = '';
        _errorMessage = 'ใส่รหัสผิดเกินกำหนด กรุณารอ ${authService.remainingLockoutSeconds} วินาที';
      });
      return;
    }

    final isCorrect = await authService.verifyPin(_enteredPin);

    if (isCorrect) {
      if (mounted) {
        widget.onUnlocked();
      }
    } else {
      setState(() {
        _enteredPin = '';
        if (authService.isLockedOut) {
          _errorMessage = 'ใส่รหัสผิดเกิน 5 ครั้ง กรุณารอ ${authService.remainingLockoutSeconds} วินาที';
        } else {
          _errorMessage = 'รหัส PIN ไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final char = event.character;
          if (char != null && RegExp(r'^[0-9]$').hasMatch(char)) {
            _onKeyPress(char);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          children: [
            Container(
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < _enteredPin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? theme.colorScheme.primary : Colors.transparent,
                          border: Border.all(
                            color: isFilled ? theme.colorScheme.primary : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 20,
                    child: _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildRow(['1', '2', '3']),
                  const SizedBox(height: 12),
                  _buildRow(['4', '5', '6']),
                  const SizedBox(height: 12),
                  _buildRow(['7', '8', '9']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fingerprint, size: 28),
                        onPressed: _tryBiometric,
                        tooltip: 'สแกนลายนิ้วมือ',
                      ),
                      _buildKey('0'),
                      IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 24),
                        onPressed: _onBackspace,
                        tooltip: 'ลบ',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.canCancel)
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('ยกเลิก / ย้อนกลับ'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                ],
              ),
            ),
            if (widget.canCancel)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'ปิดหน้าต่าง',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildKey(k)).toList(),
    );
  }

  Widget _buildKey(String text) {
    return SizedBox(
      width: 64,
      height: 64,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onPressed: () => _onKeyPress(text),
        child: Text(
          text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
