// lib/widgets/maps/map_utils.dart
import 'package:flutter/foundation.dart';

class MapUtils {
  // ✅ تحديد ما إذا كان الجهاز ويب
  static bool get isWeb => kIsWeb;

  // ✅ الحصول على Google Maps API Key من البيئة
  static String get apiKey {
    // في الإنتاج، استخدم متغير بيئة
    return 'YOUR_GOOGLE_MAPS_API_KEY';
  }

  // ✅ إنشاء URL لـ Static Map (للويب)
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

  // ✅ إنشاء URL لـ Embed Map (للويب)
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

  // ✅ إنشاء URL لـ Directions (فتح في المتصفح)
  static String getDirectionsUrl({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    return 'https://www.google.com/maps/dir/$fromLat,$fromLng/$toLat,$toLng';
  }
}