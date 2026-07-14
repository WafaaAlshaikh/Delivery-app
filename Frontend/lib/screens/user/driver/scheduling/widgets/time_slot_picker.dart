// lib/screens/user/driver/scheduling/widgets/time_slot_picker.dart

import 'package:flutter/material.dart';
import 'package:frontend/data/models/scheduled_order_model.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../services/scheduling_service.dart';

class TimeSlotPicker extends StatefulWidget {
  final Function(String orderId, DateTime time) onScheduleCreated;

  const TimeSlotPicker({
    super.key,
    required this.onScheduleCreated,
  });

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  final TextEditingController _orderIdController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  bool _isLoading = false;
  AISuggestion? _aiSuggestion;

  final SchedulingService _service = SchedulingService();

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _getAISuggestion() async {
    if (_orderIdController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final suggestion = await _service.suggestOptimalTime(
        orderId: _orderIdController.text.trim(),
      );
      setState(() {
        _aiSuggestion = suggestion;
        _selectedTime = suggestion.suggestedTime;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            '📅 إضافة جدول جديد',
            style: AppTypography.display(20, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل رقم الطلب واختر الوقت المناسب',
            style: AppTypography.body(14, color: AppColors.ink500),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _orderIdController,
            decoration: InputDecoration(
              labelText: 'رقم الطلب',
              hintText: 'أدخل رقم الطلب',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                onPressed: _getAISuggestion,
                tooltip: 'اقتراح وقت ذكي',
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          if (_aiSuggestion != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🤖 الوقت المقترح: ${_formatTime(_aiSuggestion!.suggestedTime)}',
                          style: AppTypography.body(13, weight: FontWeight.w600),
                        ),
                        Text(
                          _aiSuggestion!.reasoning,
                          style: AppTypography.body(11, color: AppColors.ink500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              child: TimePicker(
                initialTime: _selectedTime,
                onTimeChanged: (time) {
                  setState(() => _selectedTime = time);
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _orderIdController.text.trim().isEmpty
                      ? null
                      : () {
                          final orderId = _orderIdController.text.trim();
                          if (int.tryParse(orderId) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('رقم الطلب غير صحيح'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          widget.onScheduleCreated(
                            orderId,
                            _selectedTime,
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class TimePicker extends StatefulWidget {
  final DateTime initialTime;
  final ValueChanged<DateTime> onTimeChanged;

  const TimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('الساعة', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Expanded(
                child: ListWheelScrollView(
                  itemExtent: 40,
                  children: List.generate(24, (index) {
                    final isSelected = index == _selectedHour;
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    );
                  }),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedHour = index;
                      _updateTime();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('الدقيقة', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Expanded(
                child: ListWheelScrollView(
                  itemExtent: 40,
                  children: List.generate(60, (index) {
                    final isSelected = index == _selectedMinute;
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    );
                  }),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMinute = index;
                      _updateTime();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateTime() {
    final newTime = DateTime(
      widget.initialTime.year,
      widget.initialTime.month,
      widget.initialTime.day,
      _selectedHour,
      _selectedMinute,
    );
    widget.onTimeChanged(newTime);
  }
}