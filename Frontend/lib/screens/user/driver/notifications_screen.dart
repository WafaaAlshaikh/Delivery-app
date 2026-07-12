// lib/screens/user/driver/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../services/notification_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _listenToNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _isLoading = false;
    });
  }

  void _listenToNotifications() {
    final notificationService = NotificationService();
    
    notificationService.onOrderNotification.listen((data) {
      if (mounted) {
        setState(() {
          _notifications.insert(0, {
            'title': data['title'] ?? 'New Order',
            'body': data['body'] ?? 'You have a new delivery request',
            'timestamp': DateTime.now(),
            'data': data,
            'read': false,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          '🔔 ${tr.t('notifications')}',
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _notifications.clear();
                });
              },
              child: Text(
                tr.t('clear_all'),
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState(tr)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _NotificationCard(
                      notification: notification,
                      onTap: () {
                        setState(() {
                          notification['read'] = true;
                        });
                        // معالجة النقر على الإشعار
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(AppLocalizations tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.ink300,
          ),
          const SizedBox(height: 16),
          Text(
            tr.t('no_notifications'),
            style: AppTypography.display(20, weight: FontWeight.w700, color: AppColors.ink500),
          ),
          const SizedBox(height: 8),
          Text(
            tr.t('no_notifications_desc'),
            style: AppTypography.body(14, color: AppColors.ink300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final isRead = notification['read'] ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? AppColors.border : AppColors.primary,
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] ?? 'Notification',
                    style: AppTypography.body(14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification['body'] ?? '',
                    style: AppTypography.body(12, color: AppColors.ink500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification['timestamp']),
                    style: AppTypography.body(10, color: AppColors.ink300),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    final diff = DateTime.now().difference(dateTime);
    
    if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}