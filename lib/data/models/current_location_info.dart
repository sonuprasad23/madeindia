/// A one-shot snapshot of the device's current location, reverse-geocoded
/// into a human-readable place where possible.
///
/// This is deliberately distinct from [CitizenProfile]'s registered
/// address/jurisdiction — "where you are right now" is never the same
/// thing as "where you're registered" or "your suggested jurisdiction",
/// and the UI must never blur that line.
class CurrentLocationInfo {
  const CurrentLocationInfo({
    required this.latitude,
    required this.longitude,
    required this.retrievedAt,
    this.city,
    this.state,
    this.pincode,
  });

  final double latitude;
  final double longitude;
  final DateTime retrievedAt;

  /// Only ever populated from a real reverse-geocoding lookup — never
  /// fabricated. Null means the lookup didn't return that field.
  final String? city;
  final String? state;
  final String? pincode;

  bool get hasPlaceName => city != null || state != null;

  String get displayLabel {
    if (city != null && state != null) return '$city, $state';
    if (city != null) return city!;
    if (state != null) return state!;
    return '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}';
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'retrievedAt': retrievedAt.toIso8601String(),
    'city': city,
    'state': state,
    'pincode': pincode,
  };

  factory CurrentLocationInfo.fromJson(Map<String, dynamic> json) =>
      CurrentLocationInfo(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        retrievedAt: DateTime.parse(json['retrievedAt'] as String),
        city: json['city'] as String?,
        state: json['state'] as String?,
        pincode: json['pincode'] as String?,
      );
}
