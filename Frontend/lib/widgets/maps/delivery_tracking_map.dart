// lib/widgets/maps/delivery_tracking_map.dart
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class DeliveryTrackingMap extends StatefulWidget {
  final LatLng? driverLocation;
  final LatLng? businessLocation;
  final LatLng? customerLocation;
  final int status;

  const DeliveryTrackingMap({
    super.key,
    this.driverLocation,
    this.businessLocation,
    this.customerLocation,
    required this.status,
  });

  @override
  State<DeliveryTrackingMap> createState() => _DeliveryTrackingMapState();
}

class _DeliveryTrackingMapState extends State<DeliveryTrackingMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    _updateRoute();
  }

  @override
  void didUpdateWidget(DeliveryTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.status != widget.status) {
      _updateMarkers();
      _updateRoute();
    }
  }

  void _updateMarkers() {
    final tr = AppLocalizations.of(context);
    final markers = <Marker>{};

    if (widget.businessLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('business'),
          position: widget.businessLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(title: tr?.t('restaurant') ?? 'Restaurant'),
        ),
      );
    }

    if (widget.customerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: widget.customerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(title: tr?.t('customer') ?? 'Customer'),
        ),
      );
    }

    if (widget.driverLocation != null) {
      final isDelivered = widget.status >= 8;
      final color = isDelivered 
          ? BitmapDescriptor.hueGreen 
          : BitmapDescriptor.hueBlue;
      
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(color),
          infoWindow: InfoWindow(
            title: isDelivered 
                ? '${tr?.t('delivered') ?? 'Delivered'} ✅' 
                : '${tr?.t('driver') ?? 'Driver'} 🚗',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _updateRoute() {
    final points = <LatLng>[];
    
    if (widget.businessLocation != null) {
      points.add(widget.businessLocation!);
    }
    
    if (widget.driverLocation != null) {
      points.add(widget.driverLocation!);
    }
    
    if (widget.customerLocation != null) {
      points.add(widget.customerLocation!);
    }

    if (points.length >= 2) {
      _routePoints = points;
      
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: AppColors.primary,
            width: 4,
            patterns: [
              PatternItem.dash(20),
              PatternItem.gap(10),
            ],
          ),
        };
      });
    }
  }

  void _animateToFit() {
    if (_mapController == null) return;
    
    final bounds = <LatLng>[];
    if (widget.businessLocation != null) bounds.add(widget.businessLocation!);
    if (widget.customerLocation != null) bounds.add(widget.customerLocation!);
    if (widget.driverLocation != null) bounds.add(widget.driverLocation!);
    
    if (bounds.length >= 2) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              bounds.map((p) => p.latitude).reduce((a, b) => a < b ? a : b) - 0.01,
              bounds.map((p) => p.longitude).reduce((a, b) => a < b ? a : b) - 0.01,
            ),
            northeast: LatLng(
              bounds.map((p) => p.latitude).reduce((a, b) => a > b ? a : b) + 0.01,
              bounds.map((p) => p.longitude).reduce((a, b) => a > b ? a : b) + 0.01,
            ),
          ),
          50,
        ),
      );
    }
  }

  String _calculateDistance(LatLng? from, LatLng? to) {
    if (from == null || to == null) return '--';
    
    try {
      const double R = 6371; 
      final double dLat = _toRadians(to.latitude - from.latitude);
      final double dLon = _toRadians(to.longitude - from.longitude);
      final double a = 
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_toRadians(from.latitude)) * Math.cos(_toRadians(to.latitude)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
      final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      final double distance = R * c;
      
      return distance < 1 
          ? '${(distance * 1000).toInt()}m'
          : '${distance.toStringAsFixed(1)}km';
    } catch (e) {
      return '--';
    }
  }

  double _toRadians(double degree) {
    return degree * 3.141592653589793 / 180;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    if (widget.businessLocation == null || widget.customerLocation == null) {
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(tr.t('loading_map')), 
            ],
          ),
        ),
      );
    }

    final cameraPosition = CameraPosition(
      target: widget.driverLocation ?? widget.businessLocation!,
      zoom: 13,
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: cameraPosition,
          onMapCreated: (controller) {
            _mapController = controller;
            _animateToFit();
          },
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
        ),
        
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DistanceInfo(
                  icon: Icons.storefront_outlined,
                  label: tr.t('store'),
                  distance: _calculateDistance(
                    widget.driverLocation,
                    widget.businessLocation,
                  ),
                ),
                const VerticalDivider(),
                _DistanceInfo(
                  icon: Icons.location_on_outlined,
                  label: tr.t('customer'), 
                  distance: _calculateDistance(
                    widget.driverLocation,
                    widget.customerLocation,
                  ),
                ),
                const VerticalDivider(),
                _DistanceInfo(
                  icon: Icons.route_outlined,
                  label: tr.t('total'), 
                  distance: _calculateDistance(
                    widget.businessLocation,
                    widget.customerLocation,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _animateToFit,
            child: const Icon(Icons.center_focus_strong, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _DistanceInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String distance;

  const _DistanceInfo({
    required this.icon,
    required this.label,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.ink500),
        const SizedBox(height: 2),
        Text(
          distance,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}