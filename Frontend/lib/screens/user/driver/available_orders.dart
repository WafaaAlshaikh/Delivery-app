// lib/screens/user/driver/available_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/offer_model.dart';
import '../../../providers/driver_provider.dart';
import '../../../services/socket_service.dart';
import '../../../services/driver_service.dart';
import 'widgets/offer_card.dart';
import 'widgets/empty_offers.dart';

class AvailableOrders extends ConsumerStatefulWidget {
  const AvailableOrders({super.key});

  @override
  ConsumerState<AvailableOrders> createState() => _AvailableOrdersState();
}

class _AvailableOrdersState extends ConsumerState<AvailableOrders> {
  List<OfferModel> _offers = [];
  bool _isLoading = true;
  String? _error;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _loadOffers();
  }

  void _initSocket() {
    _socket = SocketService.getSocket();
    
    _socket?.on('new_offer', (data) {
      if (mounted) {
        final offer = OfferModel.fromJson(data);
        setState(() {
          _offers.insert(0, offer);
        });
        _showOfferNotification(offer);
      }
    });

    _socket?.on('offer_timer', (data) {
      if (mounted) {
        setState(() {
          final index = _offers.indexWhere((o) => o.offerId == data['offerId']);
          if (index != -1) {
            _offers[index] = _offers[index].copyWith(
              remainingSeconds: data['remaining']
            );
          }
        });
      }
    });

    _socket?.on('offer_taken', (data) {
      if (mounted) {
        setState(() {
          _offers.removeWhere((o) => o.offerId == data['offerId']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Order taken by another driver'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    });

    _socket?.on('offer_expired', (data) {
      if (mounted) {
        setState(() {
          _offers.removeWhere((o) => o.offerId == data['offerId']);
        });
      }
    });

    _socket?.on('offer_accepted', (data) {
      if (mounted) {
        setState(() {
          _offers.removeWhere((o) => o.offerId == data['offerId']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message'] ?? 'Order accepted!'}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final driverService = ref.read(driverServiceProvider);
      final response = await driverService.getAvailableOffers();
      
      if (response['success'] == true) {
        final data = response['data'];
        final offers = (data['offers'] as List? ?? [])
            .map((json) => OfferModel.fromJson(json))
            .toList();
        
        setState(() {
          _offers = offers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load offers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showOfferNotification(OfferModel offer) {
    final businessName = offer.order.business.name;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'New offer from $businessName',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // التمرير إلى العرض
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socket?.off('new_offer');
    _socket?.off('offer_timer');
    _socket?.off('offer_taken');
    _socket?.off('offer_expired');
    _socket?.off('offer_accepted');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final isOnline = driverState.isOnline;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: _buildContent(isOnline),
    );
  }

  Widget _buildContent(bool isOnline) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.body(14, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOffers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_offers.isEmpty) {
      return const EmptyOffers();
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return OfferCard(
            offer: offer,
            isOnline: isOnline,
            onAccept: () => _acceptOffer(offer),
            onReject: () => _rejectOffer(offer),
            key: ValueKey(offer.offerId),
          );
        },
      ),
    );
  }

  Future<void> _acceptOffer(OfferModel offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Accept Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to accept this order?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store: ${offer.order.business.name}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Total: \$${offer.order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Earning: \$${offer.order.estimatedEarning?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: AppColors.success),
                  ),
                  Text(
                    'Distance: ${offer.order.distance?.toStringAsFixed(1) ?? '?'} km',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _socket?.emit('accept_offer', {
      'offerId': offer.offerId,
    });

    setState(() {
      _offers.removeWhere((o) => o.offerId == offer.offerId);
    });
  }

  Future<void> _rejectOffer(OfferModel offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Reject Order'),
        content: const Text('Are you sure you want to reject this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _socket?.emit('reject_offer', {
      'offerId': offer.offerId,
    });

    setState(() {
      _offers.removeWhere((o) => o.offerId == offer.offerId);
    });
  }
}