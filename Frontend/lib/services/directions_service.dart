// lib/services/directions_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static const String _apiKey = 'AIzaSyAEGm-gX39A5x7DA9a0qSg6mEbYNmqAPPk&libraries';

  Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving', 
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=$mode'
      '&key=$_apiKey'
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return _parseDirections(data);
      } else {
        throw Exception('Directions API error: ${data['status']}');
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Map<String, dynamic> _parseDirections(Map<String, dynamic> data) {
    final route = data['routes'][0];
    final leg = route['legs'][0];
    
    final points = _decodePolyline(route['overview_polyline']['points']);
    
    return {
      'points': points,
      'distance': leg['distance']['text'],
      'distanceValue': leg['distance']['value'], 
      'duration': leg['duration']['text'],
      'durationValue': leg['duration']['value'], 
      'startAddress': leg['start_address'],
      'endAddress': leg['end_address'],
    };
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}