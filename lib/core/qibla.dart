import 'package:adhan_dart/adhan_dart.dart' as adhan;

/// Bearing to the Kaaba in degrees clockwise from true north.
double qiblaBearing(double latitude, double longitude) =>
    adhan.Qibla.qibla(adhan.Coordinates(latitude, longitude));

/// Signed smallest angle from [from] to [to], in the range (-180, 180].
double angleDifference(double from, double to) {
  var diff = (to - from) % 360;
  if (diff > 180) diff -= 360;
  if (diff <= -180) diff += 360;
  return diff;
}
