// lib/widgets/maps/live_location_map.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';
import '../../data/models/order_model.dart';

class LiveLocationMap extends StatefulWidget {
  final OrderModel order;
  final LatLng? driverLocation;
  final bool isLoading;

  const LiveLocationMap({
    super.key,
    required this.order,
    this.driverLocation,
    this.isLoading = false,
  });

  @override
  State<LiveLocationMap> createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    _updatePolylines();
  }

  @override
  void didUpdateWidget(LiveLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLocation != widget.driverLocation) {
      _updateMarkers();
      _animateToDriver();
    }
  }

  LatLng? _getBusinessLocation() {
    if (widget.order.business != null) {
      final business = widget.order.business!;
      if (business.latitude != null && business.longitude != null) {
        return LatLng(business.latitude!, business.longitude!);
      }
    }
    return null;
  }

  LatLng? _getDeliveryLocation() {
    if (widget.order.deliveryAddressDetail != null) {
      final address = widget.order.deliveryAddressDetail!;
      if (address.latitude != null && address.longitude != null) {
        return LatLng(address.latitude!, address.longitude!);
      }
    }
    return null;
  }

  void _updateMarkers() {
    _markers.clear();

    final businessLocation = _getBusinessLocation();
    if (businessLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('business'),
          position: businessLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Restaurant'),
        ),
      );
    }

    final deliveryLocation = _getDeliveryLocation();
    if (deliveryLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: deliveryLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    if (widget.driverLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      );
    }
  }

  void _updatePolylines() {
    _polylines.clear();

    final List<LatLng> points = [];

    if (widget.driverLocation != null) {
      points.add(widget.driverLocation!);
    } else {
      final businessLocation = _getBusinessLocation();
      if (businessLocation != null) {
        points.add(businessLocation);
      }
    }

    final deliveryLocation = _getDeliveryLocation();
    if (deliveryLocation != null) {
      points.add(deliveryLocation);
    }

    if (points.length >= 2) {
      _polylines.add(
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
      );
    }
  }

  void _animateToDriver() {
    if (_mapController != null && widget.driverLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.driverLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        color: Colors.grey.shade100,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    LatLng initialPosition;
    
    if (widget.driverLocation != null) {
      initialPosition = widget.driverLocation!;
    } else {
      final businessLocation = _getBusinessLocation();
      if (businessLocation != null) {
        initialPosition = businessLocation;
      } else {
        final deliveryLocation = _getDeliveryLocation();
        if (deliveryLocation != null) {
          initialPosition = deliveryLocation;
        } else {
          initialPosition = const LatLng(30.0444, 31.2357);
        }
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 14,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _animateToDriver();
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
    );
  }
}