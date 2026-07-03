// lib/widgets/maps/driver_location_map.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
    if (dart.library.html) 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
    as google_maps_web;
import '../../core/theme/colors.dart';

class DriverLocationMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final bool isOnline;
  final Function(LatLng)? onLocationChanged;
  final bool interactive;

  const DriverLocationMap({
    super.key,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.onLocationChanged,
    this.interactive = true,
  });

  @override
  State<DriverLocationMap> createState() => _DriverLocationMapState();
}

class _DriverLocationMapState extends State<DriverLocationMap> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updatePosition();
  }

  @override
  void didUpdateWidget(DriverLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _updatePosition();
    }
  }

  void _updatePosition() {
    if (widget.latitude != null && widget.longitude != null) {
      _currentPosition = LatLng(widget.latitude!, widget.longitude!);
      _updateMarker();
    }
  }

  void _updateMarker() {
    if (_currentPosition == null) return;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Drag to update location',
        ),
        draggable: widget.interactive,
        onDragEnd: (newPosition) {
          setState(() {
            _currentPosition = newPosition;
            if (widget.onLocationChanged != null) {
              widget.onLocationChanged!(newPosition);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading location...'),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ✅ Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onCameraMove: (position) {
              // تحديث الموقع عند تحريك الخريطة (اختياري)
            },
          ),

          // ✅ زر العودة للموقع الحالي
          if (widget.interactive)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () async {
                  if (_mapController != null && _currentPosition != null) {
                    await _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _currentPosition!,
                          zoom: 15,
                        ),
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),

          // ✅ حالة الـ Online/Offline
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isOnline
                    ? AppColors.success.withOpacity(0.9)
                    : AppColors.error.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isOnline ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ معلومات الموقع
          Positioned(
            bottom: 16,
            left: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📍 ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ إصدار ويب متوافق
class DriverLocationMapWeb extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isOnline;

  const DriverLocationMapWeb({
    super.key,
    this.latitude,
    this.longitude,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading location...'),
            ],
          ),
        ),
      );
    }

    // ✅ استخدام iframe لـ Google Maps على الـ Web
    final String embedUrl =
        'https://www.google.com/maps/embed/v1/place?key=YOUR_GOOGLE_MAPS_API_KEY&q=${latitude},${longitude}&zoom=15';

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ✅ iframe للخريطة
          HtmlElementView(
            viewType: 'google-maps-iframe',
            // ملاحظة: تحتاج إلى تسجيل viewType مسبقاً
          ),
          // أو نستخدم Image.network كبديل مؤقت
          Image.network(
            'https://maps.googleapis.com/maps/api/staticmap?center=${latitude},${longitude}&zoom=15&size=600x300&markers=color:${isOnline ? 'green' : 'red'}%7C${latitude},${longitude}&key=YOUR_GOOGLE_MAPS_API_KEY',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Text('Unable to load map'),
                ),
              );
            },
          ),
          // ✅ حالة الـ Online/Offline
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.success.withOpacity(0.9)
                    : AppColors.error.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}