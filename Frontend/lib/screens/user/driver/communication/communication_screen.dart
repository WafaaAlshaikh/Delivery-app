// lib/screens/user/driver/communication/communication_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/screens/user/driver/communication/widgets/call_screen.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../providers/communication_provider.dart';
import '../../../../../data/models/communication_model.dart';
import 'widgets/smart_replies.dart';
import 'widgets/eta_timer.dart';
import 'widgets/template_messages.dart';

class CommunicationScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;
  final String phoneNumber;

  const CommunicationScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.phoneNumber,
  });

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(communicationProvider.notifier).loadChat(widget.customerId.toString());
  });
}

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communicationProvider);
    final notifier = ref.read(communicationProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildQuickActions(notifier),
          const SizedBox(height: 8),
          
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(state, notifier),
          ),
          
          if (state.suggestions.isNotEmpty)
            SmartSuggestions(
              suggestions: state.suggestions,
              onSuggestionTap: (suggestion) {
                _messageController.text = suggestion.text;
                _sendMessage(notifier);
              },
            ).animate().fadeIn().slideY(),
          
          _buildMessageInput(notifier),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              widget.customerName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: AppTypography.display(16, weight: FontWeight.w700),
                ),
                Text(
                  '🟢 متصل الآن',
                  style: AppTypography.body(12, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallScreen(
                  customerName: widget.customerName,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: () {
            // ✅ مشاركة الموقع
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(CommunicationNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.directions_car,
            label: 'في الطريق',
            color: Colors.blue,
            onTap: () {
              notifier.notifyOnTheWay(widget.customerId, etaMinutes: 10);
            },
          ),
          const SizedBox(width: 8),
          _QuickActionButton(
            icon: Icons.location_on,
            label: 'وصلت',
            color: Colors.green,
            onTap: () {
              notifier.notifyArrived(widget.customerId);
            },
          ),
          const SizedBox(width: 8),
          _QuickActionButton(
            icon: Icons.timer,
            label: 'ETA',
            color: Colors.orange,
            onTap: () {
              _showETADialog(notifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(CommunicationState state, CommunicationNotifier notifier) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _MessageBubble(
          message: message,
          isFromDriver: message.isFromDriver,
        ).animate().fadeIn(
          duration: 200.ms,
          delay: Duration(milliseconds: index * 50),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل بعد',
            style: AppTypography.display(18, weight: FontWeight.w700, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ المحادثة مع ${widget.customerName}',
            style: AppTypography.body(14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(CommunicationNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (text) {
                setState(() => _isTyping = text.isNotEmpty);
              },
              onSubmitted: (_) => _sendMessage(notifier),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isTyping ? () => _sendMessage(notifier) : null,
            ),
          ),
        ],
      ),
    );
  }

void _sendMessage(CommunicationNotifier notifier) {
  if (_messageController.text.trim().isEmpty) return;

  notifier.sendMessage(
    customerId: widget.customerId.toString(),
    text: _messageController.text.trim(),
  );

  _messageController.clear();
  setState(() => _isTyping = false);
  
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

void _sendOnTheWay(CommunicationNotifier notifier) {
  notifier.notifyOnTheWay(
    widget.customerId.toString(), 
    etaMinutes: 10,
  );
}

void _sendArrived(CommunicationNotifier notifier) {
  notifier.notifyArrived(widget.customerId.toString()); 
}

  void _showETADialog(CommunicationNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⏱️ تقدير وقت الوصول',
              style: AppTypography.display(18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ..._buildETASlider(notifier),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildETASlider(CommunicationNotifier notifier) {
    int eta = 5;
    String traffic = '🟢 خفيف';

    return [
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الوقت المتوقع:'),
                  Text(
                    '$eta دقائق',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: eta.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    eta = value.round();
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _trafficOption('🟢 خفيف', setState, () => traffic = 'light'),
                  _trafficOption('🟡 متوسط', setState, () => traffic = 'moderate'),
                  _trafficOption('🔴 مزدحم', setState, () => traffic = 'heavy'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    notifier.sendETA(
                      customerId: widget.customerId,
                      minutes: eta,
                      trafficStatus: traffic,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إرسال ETA'),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  Widget _trafficOption(String label, StateSetter setState, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        setState(() {
          onTap();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppTypography.body(12)),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFromDriver;

  const _MessageBubble({
    required this.message,
    required this.isFromDriver,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromDriver ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isFromDriver ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isFromDriver ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: isFromDriver ? const Radius.circular(16) : const Radius.circular(4),
          ),
          border: isFromDriver ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isFromDriver ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isFromDriver ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}