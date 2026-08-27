import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/current_location_info.dart';

/// Outcome of a permission check/request, used to decide what the
/// dashboard's Location Card should show — never repeatedly prompts once
/// permission has been permanently denied.
enum LocationPermissionOutcome {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// One-shot location retrieval — no background/continuous tracking.
///
/// This deliberately mirrors the app's other service-boundary pattern
/// (see `LinkAnalysisService`, `SafeViewerService`-equivalent doc
/// comments): a thin, swappable wrapper around a platform capability, with
/// every method safe to call repeatedly and never throwing to its caller.
class LocationService {
  LocationService({Geocoding? geocoding}) : _providedGeocoding = geocoding;

  final Geocoding? _providedGeocoding;

  // Resolved lazily, only when a lookup actually happens — never as a
  // side effect of constructing this service (e.g. via a Riverpod
  // provider's build()), since constructing a Geocoding() eagerly can
  // throw in contexts with no registered platform plugin, such as a
  // plain widget test that never actually requests a location.
  Geocoding? _geocoding;
  Geocoding get _resolvedGeocoding =>
      _geocoding ??= _providedGeocoding ?? Geocoding();

  Future<LocationPermissionOutcome> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionOutcome.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationPermissionOutcome.granted,
      LocationPermission.deniedForever =>
        LocationPermissionOutcome.deniedForever,
      LocationPermission.denied ||
      LocationPermission.unableToDetermine => LocationPermissionOutcome.denied,
    };
  }

  /// Retrieves the current position once and reverse-geocodes it. Returns
  /// null (never throws) if the position or geocoding lookup fails —
  /// callers should treat that as "location unavailable", not an error to
  /// surface raw.
  Future<CurrentLocationInfo?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      String? city;
      String? state;
      String? pincode;
      try {
        final placemarks = await _resolvedGeocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = (place.locality?.isNotEmpty ?? false) ? place.locality : null;
          state = (place.administrativeArea?.isNotEmpty ?? false)
              ? place.administrativeArea
              : null;
          pincode = (place.postalCode?.isNotEmpty ?? false)
              ? place.postalCode
              : null;
        }
      } catch (_) {
        // Reverse geocoding failed (no network, no provider on this
        // device, etc.) — coordinates are still meaningful on their own.
      }

      return CurrentLocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        retrievedAt: DateTime.now(),
        city: city,
        state: state,
        pincode: pincode,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
