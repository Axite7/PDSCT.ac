import 'package:geolocator/geolocator.dart';

class LocationService {
  // PDSCT College coordinates (Chhatarpur, MP)
  // Update these to the actual college coordinates
  static const double collegeLat = 24.7535;
  static const double collegeLng = 79.5880;
  static const double allowedRadiusMeters = 200.0; // 200m radius

  /// Check and request location permissions
  static Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Check if user is within the college campus
  static Future<Map<String, dynamic>> isWithinCampus() async {
    final position = await getCurrentLocation();

    if (position == null) {
      return {
        'isWithin': false,
        'distance': -1.0,
        'message': 'Location permission denied',
      };
    }

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      collegeLat,
      collegeLng,
    );

    return {
      'isWithin': distance <= allowedRadiusMeters,
      'distance': distance,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'message': distance <= allowedRadiusMeters
          ? 'You are within campus'
          : 'You are ${(distance / 1000).toStringAsFixed(1)} km away from campus',
    };
  }

  /// Get distance from campus in meters
  static Future<double> getDistanceFromCampus() async {
    final position = await getCurrentLocation();
    if (position == null) return -1;

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      collegeLat,
      collegeLng,
    );
  }
}
