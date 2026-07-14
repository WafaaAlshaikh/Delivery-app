// lib/widgets/maps/driver_location_map.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
    if (dart.library.html) 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
    as google_maps_web;
import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../services/directions_service.dart';

class DriverLocationMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final bool isOnline;
  final Function(LatLng)? onLocationChanged;
  final bool interactive;
  
  final LatLng? destinationLatLng;  
  final String? destinationLabel;   
  final bool showRoute;            
  final double? radius;            

  const DriverLocationMap({
    super.key,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.onLocationChanged,
    this.interactive = true,
    this.destinationLatLng,
    this.destinationLabel,
    this.showRoute = false,
    this.radius,
  });

  @override
  State<DriverLocationMap> createState() => _DriverLocationMapState();
}

class _DriverLocationMapState extends State<DriverLocationMap> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  bool _isInitialized = false;
  bool _isLoadingRoute = false;
  Map<String, dynamic>? _routeInfo;

  final DirectionsService _directionsService = DirectionsService();

  @override
  void initState() {
    super.initState();
    _updatePosition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isInitialized = true;
      });
      if (widget.showRoute && widget.destinationLatLng != null) {
        _loadRoute();
      }
      if (widget.radius != null && widget.radius! > 0) {
        _updateCircle();
      }
    });
  }

  @override
  void didUpdateWidget(DriverLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _updatePosition();
    }
    if (oldWidget.destinationLatLng != widget.destinationLatLng ||
        oldWidget.showRoute != widget.showRoute) {
      if (widget.showRoute && widget.destinationLatLng != null) {
        _loadRoute();
      }
    }
    if (oldWidget.radius != widget.radius) {
      _updateCircle();
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
            if (widget.showRoute && widget.destinationLatLng != null) {
              _loadRoute();
            }
          });
        },
      ),
    );

    if (widget.destinationLatLng != null && widget.showRoute) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destinationLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: widget.destinationLabel ?? 'Destination',
          ),
        ),
      );
    }
  }

  Future<void> _loadRoute() async {
    if (_currentPosition == null || widget.destinationLatLng == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final result = await _directionsService.getDirections(
        origin: _currentPosition!,
        destination: widget.destinationLatLng!,
      );

      setState(() {
        _routeInfo = result;
        _updatePolyline(result['points']);
        _isLoadingRoute = false;
      });
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      print('❌ Error loading route: $e');
    }
  }

  void _updatePolyline(List<LatLng> points) {
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppColors.primary,
        width: 5,
        patterns: [
          PatternItem.dash(10),
          PatternItem.gap(5),
          PatternItem.dash(10),
        ],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  void _updateCircle() {
    if (_currentPosition == null || widget.radius == null || widget.radius! <= 0) {
      return;
    }

    _circles.clear();
    _circles.add(
      Circle(
        circleId: const CircleId('coverage_radius'),
        center: _currentPosition!,
        radius: widget.radius!,
        fillColor: AppColors.primary.withOpacity(0.1),
        strokeColor: AppColors.primary.withOpacity(0.4),
        strokeWidth: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    if (_isInitialized && _currentPosition != null) {
      _updateMarkerWithTranslation(context);
    }

    if (_currentPosition == null) {
      return _buildLoadingWidget(tr);
    }

    return _buildMapWidget(tr);
  }

  Widget _buildLoadingWidget(AppLocalizations tr) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(tr.t('loading_location')),
          ],
        ),
      ),
    );
  }

  Widget _buildMapWidget(AppLocalizations tr) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.showRoute && widget.destinationLatLng != null) {
                _fitBounds();
              }
            },
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onCameraMove: (position) {},
          ),

          if (_routeInfo != null && widget.showRoute)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
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
                    _RouteInfoItem(
                      icon: Icons.directions_car,
                      label: 'Distance',
                      value: _routeInfo!['distance'],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    _RouteInfoItem(
                      icon: Icons.access_time,
                      label: 'ETA',
                      value: _routeInfo!['duration'],
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: _routeInfo != null && widget.showRoute ? 80 : 16,
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
                    widget.isOnline 
                        ? tr.t('online').toUpperCase() 
                        : tr.t('offline').toUpperCase(),
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

          if (widget.interactive)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _zoomToMyLocation,
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),

          if (_isLoadingRoute)
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading route...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _fitBounds() async {
    if (_mapController == null || _currentPosition == null || widget.destinationLatLng == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentPosition!.latitude < widget.destinationLatLng!.latitude
            ? _currentPosition!.latitude
            : widget.destinationLatLng!.latitude,
        _currentPosition!.longitude < widget.destinationLatLng!.longitude
            ? _currentPosition!.longitude
            : widget.destinationLatLng!.longitude,
      ),
      northeast: LatLng(
        _currentPosition!.latitude > widget.destinationLatLng!.latitude
            ? _currentPosition!.latitude
            : widget.destinationLatLng!.latitude,
        _currentPosition!.longitude > widget.destinationLatLng!.longitude
            ? _currentPosition!.longitude
            : widget.destinationLatLng!.longitude,
      ),
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  Future<void> _zoomToMyLocation() async {
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
  }

  void _updateMarkerWithTranslation(BuildContext context) {
    if (_currentPosition == null) return;
    final tr = context.tr;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: tr.t('your_location'),
          snippet: tr.t('drag_to_update'),
        ),
        draggable: widget.interactive,
        onDragEnd: (newPosition) {
          setState(() {
            _currentPosition = newPosition;
            if (widget.onLocationChanged != null) {
              widget.onLocationChanged!(newPosition);
            }
            if (widget.showRoute && widget.destinationLatLng != null) {
              _loadRoute();
            }
          });
        },
      ),
    );

    if (widget.destinationLatLng != null && widget.showRoute) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destinationLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: widget.destinationLabel ?? 'Destination',
          ),
        ),
      );
    }
  }
}

class _RouteInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RouteInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}