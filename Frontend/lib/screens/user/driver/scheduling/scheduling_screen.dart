// lib/screens/user/driver/scheduling/scheduling_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/data/models/scheduled_order_model.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../providers/scheduling_provider.dart';
import 'widgets/scheduled_order_card.dart';
import 'widgets/route_optimization_card.dart';
import 'widgets/ai_suggestion_card.dart';
import 'widgets/time_slot_picker.dart';

class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  ConsumerState<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  late DateTime _selectedDate;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(schedulingProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schedulingProvider);
    final notifier = ref.read(schedulingProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          '📅 جدولة الطلبات',
          style: AppTypography.display(20, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => notifier.refreshData(),
            icon: state.isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refreshData(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCalendar(notifier),
              const SizedBox(height: 16),

              if (state.aiSuggestion != null)
                AISuggestionCard(
                  suggestion: state.aiSuggestion!,
                ).animate().fadeIn(duration: 300.ms).slideY(),
              const SizedBox(height: 16),

              if (state.routeOptimization != null)
                RouteOptimizationCard(
                  optimization: state.routeOptimization!,
                ).animate().fadeIn(duration: 300.ms).slideY(),
              const SizedBox(height: 16),

              _buildScheduledOrders(state),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateScheduleDialog(context, notifier),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('إضافة جدول'),
      ),
    );
  }


Widget _buildCalendar(SchedulingNotifier notifier) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: TableCalendar(
      focusedDay: _selectedDate,
      firstDay: DateTime(2024, 1, 1),
      lastDay: DateTime(2030, 12, 31), 
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
        notifier.changeDate(selectedDay);
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    ),
  );
}
  Widget _buildScheduledOrders(SchedulingState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.scheduledOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات مجدولة',
              style: AppTypography.display(16, weight: FontWeight.w700, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على زر + لإضافة جدول جديد',
              style: AppTypography.body(14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: state.scheduledOrders.map((scheduled) {
        return ScheduledOrderCard(
          scheduledOrder: scheduled,
          onConfirm: () {
            _showConfirmDialog(context, scheduled);
          },
          onCancel: () {
            _showCancelDialog(context, scheduled);
          },
        ).animate().fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 100 * state.scheduledOrders.indexOf(scheduled)),
        );
      }).toList(),
    );
  }

  void _showCreateScheduleDialog(BuildContext context, SchedulingNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TimeSlotPicker(
        onScheduleCreated: (orderId, time) {
          notifier.createSchedule(
            orderId: orderId,
            scheduledTime: time,
          );
        },
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, ScheduledOrder scheduled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الجدول'),
        content: Text('هل أنت متأكد من تأكيد هذا الجدول؟\nالطلب: ${scheduled.order?.orderNumber ?? 'N/A'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(schedulingProvider.notifier).confirmSchedule(scheduled.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, ScheduledOrder scheduled) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إلغاء الجدول'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من إلغاء هذا الجدول؟\nالطلب: ${scheduled.order?.orderNumber ?? 'N/A'}'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإلغاء (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رجوع'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(schedulingProvider.notifier).cancelSchedule(
                scheduled.id,
                reason: reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}