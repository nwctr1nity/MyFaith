import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';

enum DeviceLocationFailure { serviceDisabled, permissionDenied, unavailable }

class DeviceLocationException implements Exception {
  const DeviceLocationException(this.failure);

  final DeviceLocationFailure failure;
}

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });

  final double latitude;
  final double longitude;
  final String timeZone;
}

/// Reads an approximate position and the device time zone. City-level
/// accuracy is enough: prayer times change by about a minute per 25 km.
Future<DeviceLocation> readDeviceLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const DeviceLocationException(DeviceLocationFailure.serviceDisabled);
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const DeviceLocationException(DeviceLocationFailure.permissionDenied);
  }

  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 20),
      ),
    );
  } on Exception {
    position = await Geolocator.getLastKnownPosition();
  }
  if (position == null) {
    throw const DeviceLocationException(DeviceLocationFailure.unavailable);
  }

  final zone = await FlutterTimezone.getLocalTimezone();
  return DeviceLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    timeZone: zone.identifier,
  );
}
