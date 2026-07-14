// lib/screens/user/driver/communication/widgets/eta_timer.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/theme/typography.dart';

class ETATimer extends StatefulWidget {
  final int initialMinutes;
  final String trafficStatus;
  final VoidCallback onComplete;

  const ETATimer({
    super.key,
    required this.initialMinutes,
    required this.trafficStatus,
    required this.onComplete,
  });

  @override
  State<ETATimer> createState() => _ETATimerState();
}

class _ETATimerState extends State<ETATimer> {
  late int _remainingMinutes;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _remainingMinutes = widget.initialMinutes;
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      
      setState(() {
        _remainingMinutes--;
        if (_remainingMinutes <= 0) {
          _isRunning = false;
          widget.onComplete();
        }
      });
      return _isRunning && _remainingMinutes > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          _buildETA(),
          const SizedBox(width: 16),
          _buildTrafficInfo(),
          const Spacer(),
          _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildETA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⏱️ الوقت المتبقي',
          style: AppTypography.body(12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          _remainingMinutes > 0
              ? '$_remainingMinutes دقيقة'
              : '🟢 وصلت!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _remainingMinutes > 0 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficInfo() {
    final emoji = widget.trafficStatus == 'light' ? '🟢' :
                   widget.trafficStatus == 'moderate' ? '🟡' : '🔴';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚦 حالة الطريق',
          style: AppTypography.body(12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          '$emoji ${_getTrafficText()}',
          style: AppTypography.body(14, weight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getTrafficText() {
    switch (widget.trafficStatus) {
      case 'light':
        return 'خفيف';
      case 'moderate':
        return 'متوسط';
      case 'heavy':
        return 'مزدحم';
      default:
        return 'خفيف';
    }
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () {
        setState(() => _isRunning = false);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.red, size: 20),
      ),
    );
  }
}