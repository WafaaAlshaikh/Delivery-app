// lib/screens/user/driver/communication/call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../providers/communication_provider.dart';
import '../../../../../services/call_service.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String customerName;
  final String phoneNumber;

  const CallScreen({
    super.key,
    required this.customerName,
    required this.phoneNumber,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final CallService _callService = CallService();
  bool _isCalling = false;
  bool _isRecording = false;
  int _callDuration = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communicationProvider);
    final bestTime = _callService.suggestBestTime();

    return Scaffold(
      backgroundColor: AppColors.duskGradient.colors.first,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.routeGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                widget.customerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                _isCalling ? '📞 جاري الاتصال...' : '🟢 متاح للاتصال',
                style: TextStyle(
                  color: _isCalling ? Colors.amber : Colors.green,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 $bestTime',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_isCalling) ...[
                Text(
                  '${_callDuration ~/ 60}:${(_callDuration % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCalling) ...[
                    _CallButton(
                      icon: _isRecording ? Icons.mic_off : Icons.mic,
                      label: _isRecording ? 'إيقاف التسجيل' : 'تسجيل',
                      color: _isRecording ? Colors.red : Colors.white70,
                      onTap: () {
                        setState(() {
                          _isRecording = !_isRecording;
                          if (_isRecording) {
                            _callService.startRecording();
                          } else {
                            _callService.stopRecording();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 24),
                  ],
                  
                  _CallButton(
                    icon: _isCalling ? Icons.call_end : Icons.call,
                    label: _isCalling ? 'إنهاء' : 'اتصال',
                    color: _isCalling ? Colors.red : Colors.green,
                    isBig: true,
                    onTap: _isCalling ? _endCall : _startCall,
                  ),
                  
                  if (_isCalling) ...[
                    const SizedBox(width: 24),
                    _CallButton(
                      icon: Icons.volume_up,
                      label: 'مكبر الصوت',
                      color: Colors.white70,
                      onTap: () {},
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              if (!_isCalling)
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '📝 إضافة ملاحظات',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCall() {
    setState(() {
      _isCalling = true;
    });

    _callService.makeCall(widget.phoneNumber);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _callDuration++;
      });
      return _isCalling;
    });
  }

  void _endCall() {
    setState(() {
      _isCalling = false;
      _callDuration = 0;
    });

    if (_isRecording) {
      _callService.stopRecording();
      setState(() => _isRecording = false);
    }

    Navigator.pop(context);
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isBig;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isBig = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: isBig ? 72 : 56,
            height: isBig ? 72 : 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: isBig ? 32 : 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}