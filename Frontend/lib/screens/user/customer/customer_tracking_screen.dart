// lib/screens/user/customer/customer_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/order_model.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/maps/live_location_map.dart';
import '../../../widgets/order/order_status_timeline.dart';

class CustomerTrackingScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const CustomerTrackingScreen({super.key, required this.order});

  @override
  ConsumerState<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends ConsumerState<CustomerTrackingScreen> {
  late IO.Socket _socket;
  LatLng? _driverLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchDriverLocation();
  }

  void _initSocket() {
    _socket = SocketService.getSocket();
    _socket.on('driver_location_updated', (data) {
      if (data['orderId'] == widget.order.orderId) {
        setState(() {
          _driverLocation = LatLng(
            data['latitude'],
            data['longitude'],
          );
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchDriverLocation() async {
    // يمكن إضافة API لجلب الموقع الحالي للسائق إذا كان الطلب قيد التنفيذ
    // وللتبسيط، سنفترض أن الموقع سيتم تحديثه عبر WebSocket
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _socket.off('driver_location_updated');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final order = widget.order;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          tr.t('track_order'),
          style: AppTypography.display(18, weight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: LiveLocationMap(
                order: order,
                driverLocation: _driverLocation,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OrderStatusTimeline(order: order),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildOrderInfoCard(tr, order),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(AppLocalizations tr, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tr.t('order')} #${order.orderId}',
            style: AppTypography.display(16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 16, color: AppColors.ink500),
              const SizedBox(width: 8),
              Text(
                order.business.name,
                style: AppTypography.body(14, color: AppColors.ink700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.ink500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress.fullAddress,
                  style: AppTypography.body(14, color: AppColors.ink700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.t('total'),
                style: AppTypography.body(14, color: AppColors.ink500),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: AppTypography.display(16, weight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}