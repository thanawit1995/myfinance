import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../security/auth_provider.dart';

enum PinSetupStep {
  enterOld,
  enterNew,
  confirmNew,
}

class PinSetupDialog extends ConsumerStatefulWidget {
  final bool isChanging;

  const PinSetupDialog({
    super.key,
    required this.isChanging,
  });

  static Future<bool> show(BuildContext context, {required bool isChanging}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PinSetupDialog(isChanging: isChanging),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends ConsumerState<PinSetupDialog> {
  late PinSetupStep _step;
  String _enteredPin = '';
  String _oldPin = '';
  String _newPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _step = widget.isChanging ? PinSetupStep.enterOld : PinSetupStep.enterNew;
  }

  String get _title {
    switch (_step) {
      case PinSetupStep.enterOld:
        return 'ใส่รหัส PIN เดิม';
      case PinSetupStep.enterNew:
        return widget.isChanging ? 'ตั้งรหัส PIN ใหม่' : 'ตั้งรหัส PIN 6 หลัก';
      case PinSetupStep.confirmNew:
        return 'ยืนยันรหัส PIN ใหม่';
    }
  }

  String get _subtitle {
    switch (_step) {
      case PinSetupStep.enterOld:
        return 'กรุณาใส่รหัส PIN 6 หลักเดิมเพื่อยืนยันตัวตน';
      case PinSetupStep.enterNew:
        return 'กำหนดรหัส PIN 6 หลักใหม่ที่คุณต้องการ';
      case PinSetupStep.confirmNew:
        return 'ใส่รหัส PIN ใหม่อีกครั้งเพื่อยืนยันความถูกต้อง';
    }
  }

  void _onKeyPress(String key) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += key;
        _errorMessage = null;
      });

      if (_enteredPin.length == 6) {
        _onCompleteInput();
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

  Future<void> _onCompleteInput() async {
    final auth = ref.read(authServiceProvider);

    switch (_step) {
      case PinSetupStep.enterOld:
        final isCorrect = await auth.verifyPin(_enteredPin);
        if (isCorrect) {
          setState(() {
            _oldPin = _enteredPin;
            _enteredPin = '';
            _errorMessage = null;
            _step = PinSetupStep.enterNew;
          });
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'รหัส PIN เดิมไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง';
          });
        }
        break;

      case PinSetupStep.enterNew:
        setState(() {
          _newPin = _enteredPin;
          _enteredPin = '';
          _errorMessage = null;
          _step = PinSetupStep.confirmNew;
        });
        break;

      case PinSetupStep.confirmNew:
        if (_enteredPin == _newPin) {
          if (widget.isChanging) {
            await auth.changePin(_oldPin, _newPin);
          } else {
            await auth.setPin(_newPin);
          }
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'รหัส PIN ไม่ตรงกัน กรุณาตั้งรหัสใหม่อีกครั้ง';
            _step = PinSetupStep.enterNew;
          });
        }
        break;
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _step == PinSetupStep.enterOld
                        ? Icons.lock_clock_outlined
                        : (_step == PinSetupStep.enterNew ? Icons.lock_reset : Icons.lock_outline),
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // 6-digit dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final filled = index < _enteredPin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? theme.colorScheme.primary : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Keypad
                  Column(
                    children: [
                      _buildRow(['1', '2', '3']),
                      const SizedBox(height: 10),
                      _buildRow(['4', '5', '6']),
                      const SizedBox(height: 10),
                      _buildRow(['7', '8', '9']),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 58, height: 58),
                          _buildKey('0'),
                          IconButton(
                            icon: const Icon(Icons.backspace_outlined, size: 24),
                            onPressed: _onBackspace,
                            tooltip: 'ลบ',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('ยกเลิก'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'ยกเลิก',
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
      width: 58,
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onPressed: () => _onKeyPress(text),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
