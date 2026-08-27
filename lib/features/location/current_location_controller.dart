import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_providers.dart';
import '../../core/services/location_service.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/models/current_location_info.dart';

enum LocationCardStatus {
  notAsked,
  requesting,
  granted,
  denied,
  deniedForever,
  unavailable,
}

class LocationCardState {
  const LocationCardState({
    this.status = LocationCardStatus.notAsked,
    this.info,
  });

  final LocationCardStatus status;
  final CurrentLocationInfo? info;

  LocationCardState copyWith({
    LocationCardStatus? status,
    CurrentLocationInfo? info,
  }) =>
      LocationCardState(status: status ?? this.status, info: info ?? this.info);
}

/// Drives the Home dashboard's Location Card. Location is retrieved
/// once per user action (tapping "Allow Location") — never automatically
/// on app launch, and never tracked continuously in the background.
class CurrentLocationController extends Notifier<LocationCardState> {
  final LocationService _service = LocationService();

  @override
  LocationCardState build() {
    final raw = ref
        .read(localStorageProvider)
        .getString(StorageKeys.savedLocationInfo);
    if (raw == null) return const LocationCardState();
    try {
      final info = CurrentLocationInfo.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return LocationCardState(status: LocationCardStatus.granted, info: info);
    } catch (_) {
      return const LocationCardState();
    }
  }

  Future<void> requestLocation() async {
    state = state.copyWith(status: LocationCardStatus.requesting);

    final outcome = await _service.ensurePermission();
    switch (outcome) {
      case LocationPermissionOutcome.granted:
        final info = await _service.getCurrentLocation();
        if (info == null) {
          state = state.copyWith(status: LocationCardStatus.unavailable);
          return;
        }
        state = LocationCardState(
          status: LocationCardStatus.granted,
          info: info,
        );
        await ref
            .read(localStorageProvider)
            .setString(
              StorageKeys.savedLocationInfo,
              jsonEncode(info.toJson()),
            );
      case LocationPermissionOutcome.denied:
        state = state.copyWith(status: LocationCardStatus.denied);
      case LocationPermissionOutcome.deniedForever:
        state = state.copyWith(status: LocationCardStatus.deniedForever);
      case LocationPermissionOutcome.serviceDisabled:
        state = state.copyWith(status: LocationCardStatus.unavailable);
    }
  }

  Future<void> openSettingsForDenied() async {
    if (state.status == LocationCardStatus.unavailable) {
      await _service.openLocationSettings();
    } else {
      await _service.openAppSettings();
    }
  }

  void dismissPrompt() {
    if (state.status == LocationCardStatus.notAsked) return;
    state = state.copyWith(status: LocationCardStatus.notAsked);
  }

  Future<void> clearSavedLocation() async {
    await ref.read(localStorageProvider).remove(StorageKeys.savedLocationInfo);
    state = const LocationCardState();
  }
}

final currentLocationProvider =
    NotifierProvider<CurrentLocationController, LocationCardState>(
      CurrentLocationController.new,
    );
