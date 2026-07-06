// lib/widgets/maps/map_utils.dart
import 'package:flutter/foundation.dart';

class MapUtils {
  static bool get isWeb => kIsWeb;

  static String get apiKey {
    return 'AIzaSyAEGm-gX39A5x7DA9a0qSg6mEbYNmqAPPk&libraries';
  }

  static String getStaticMapUrl({
    required double latitude,
    required double longitude,
    double zoom = 15,
    int width = 600,
    int height = 300,
    String color = 'red',
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude&'
        'zoom=$zoom&'
        'size=${width}x$height&'
        'markers=color:$color%7C$latitude,$longitude&'
        'key=$apiKey';
  }

  static String getEmbedMapUrl({
    required double latitude,
    required double longitude,
    double zoom = 15,
  }) {
    return 'https://www.google.com/maps/embed/v1/place?'
        'key=$apiKey&'
        'q=$latitude,$longitude&'
        'zoom=$zoom';
  }

  static String getDirectionsUrl({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    return 'https://www.google.com/maps/dir/$fromLat,$fromLng/$toLat,$toLng';
  }
}