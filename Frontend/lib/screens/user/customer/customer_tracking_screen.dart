// lib/screens/user/customer/customer_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../../../widgets/maps/live_location_map.dart';
import '../../../widgets/order/order_status_timeline.dart';
import '../../../core/theme/colors.dart';

class CustomerTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const CustomerTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends ConsumerState<CustomerTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailsProvider(widget.orderId as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: orderAsync.when(
        data: (order) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: LiveLocationMap(
                    order: order,
                    driverLocation: _getDriverLocation(order),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'رقم الطلب: ${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        order.storeName ?? order.business?.name ?? 'المتجر',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      OrderStatusTimeline(order: order),
                      const SizedBox(height: 20),
                      
                      _buildDetailItem(
                        icon: Icons.location_on_outlined,
                        label: 'عنوان التوصيل',
                        value: order.deliveryAddress, 
                      ),
                      const SizedBox(height: 8),
                      
                      _buildDetailItem(
                        icon: Icons.payment_outlined,
                        label: 'طريقة الدفع',
                        value: order.paymentMethod,
                      ),
                      const SizedBox(height: 8),
                      
                      _buildDetailItem(
                        icon: Icons.attach_money,
                        label: 'المبلغ الإجمالي',
                        value: '${order.finalAmount.toStringAsFixed(2)} ₪', 
                      ),
                      const SizedBox(height: 8),
                      
                      if (order.customer != null)
                        _buildDetailItem(
                          icon: Icons.person_outline,
                          label: 'العميل',
                          value: order.customer!.fullName,
                        ),
                      const SizedBox(height: 8),
                      
                      if (order.customer?.phone != null)
                        _buildDetailItem(
                          icon: Icons.phone_outlined,
                          label: 'الهاتف',
                          value: order.customer!.phone!,
                        ),
                      const SizedBox(height: 20),
                      
                      if (order.driverId != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: تنفيذ الاتصال بالسائق
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('جاري الاتصال بالسائق...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('الاتصال بالسائق'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ أثناء تحميل الطلب',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(orderDetailsProvider(widget.orderId as int));
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LatLng? _getDriverLocation(OrderModel order) {
    if (order.driverId != null) {

      return null; // مؤقتاً
    }
    return null;
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending': return 'قيد الانتظار';
      case 'Confirmed': return 'تم التأكيد';
      case 'Preparing': return 'قيد التحضير';
      case 'Ready': return 'جاهز للاستلام';
      case 'PickedUp': return 'مع السائق';
      case 'Delivered': return 'تم التوصيل';
      case 'Cancelled': return 'ملغي';
      case 'Refunded': return 'مسترجع';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Confirmed': return Colors.blue;
      case 'Preparing': return Colors.blue;
      case 'Ready': return Colors.purple;
      case 'PickedUp': return Colors.purple;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      case 'Refunded': return Colors.red;
      default: return Colors.grey;
    }
  }
}