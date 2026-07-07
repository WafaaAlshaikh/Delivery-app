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

  void _updateMarkers() {
    _markers.clear();

    if (widget.order.business.latitude != null &&
        widget.order.business.longitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('business'),
          position: LatLng(
            widget.order.business.latitude!,
            widget.order.business.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Restaurant'),
        ),
      );
    }

    if (widget.order.deliveryAddress.latitude != null &&
        widget.order.deliveryAddress.longitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: LatLng(
            widget.order.deliveryAddress.latitude!,
            widget.order.deliveryAddress.longitude!,
          ),
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
    } else if (widget.order.business.latitude != null &&
        widget.order.business.longitude != null) {
      points.add(LatLng(
        widget.order.business.latitude!,
        widget.order.business.longitude!,
      ));
    }

    if (widget.order.deliveryAddress.latitude != null &&
        widget.order.deliveryAddress.longitude != null) {
      points.add(LatLng(
        widget.order.deliveryAddress.latitude!,
        widget.order.deliveryAddress.longitude!,
      ));
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

    final initialPosition = widget.driverLocation ??
        (widget.order.business.latitude != null &&
                widget.order.business.longitude != null
            ? LatLng(
                widget.order.business.latitude!,
                widget.order.business.longitude!,
              )
            : const LatLng(30.0444, 31.2357)); 

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