import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rakshak_button.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import 'current_location_controller.dart';

/// Home dashboard card for the device's current, one-shot location.
///
/// Deliberately separate from the citizen profile's registered address /
/// suggested jurisdiction (see Profile) — this shows where the device is
/// right now, not where the user is registered, and the two are never
/// conflated in copy or layout.
class LocationCard extends ConsumerWidget {
  const LocationCard({super.key});

  void _showDetails(BuildContext context, WidgetRef ref) {
    final info = ref.read(currentLocationProvider).info;
    if (info == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Current Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info.city != null) _row(context, 'City', info.city!),
            if (info.state != null) _row(context, 'State', info.state!),
            if (info.pincode != null) _row(context, 'Pincode', info.pincode!),
            _row(
              context,
              'Coordinates',
              '${info.latitude.toStringAsFixed(4)}, ${info.longitude.toStringAsFixed(4)}',
            ),
            _row(
              context,
              'Retrieved',
              AppFormatters.dateTime(info.retrievedAt),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'This is your current location, not your registered address or '
              'suggested jurisdiction (see Profile) — those are separate and are '
              'not automatically updated from this.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationState = ref.watch(currentLocationProvider);
    final controller = ref.read(currentLocationProvider.notifier);

    switch (locationState.status) {
      case LocationCardStatus.notAsked:
        return RakshakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Your Current Location',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Rakshak uses your location to show your current location and help '
                'identify relevant local information such as your area and possible '
                'jurisdiction.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: RakshakButton(
                      label: 'Allow Location',
                      onPressed: controller.requestLocation,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: RakshakButton(
                      label: 'Not Now',
                      variant: RakshakButtonVariant.text,
                      onPressed: controller.dismissPrompt,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case LocationCardStatus.requesting:
        return const RakshakCard(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Center(child: CircularProgressIndicator()),
          ),
        );

      case LocationCardStatus.granted:
        final info = locationState.info!;
        return RakshakCard(
          onTap: () => _showDetails(context, ref),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
                child: const Icon(Icons.location_on_rounded),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Current Location',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      info.displayLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Current location detected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showDetails(context, ref),
                child: const Text('View'),
              ),
            ],
          ),
        );

      case LocationCardStatus.denied:
      case LocationCardStatus.deniedForever:
      case LocationCardStatus.unavailable:
        return RakshakCard(
          child: Row(
            children: [
              Icon(
                Icons.location_disabled_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location unavailable',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      locationState.status == LocationCardStatus.unavailable
                          ? 'Location services appear to be off.'
                          : 'Permission was not granted.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: locationState.status == LocationCardStatus.denied
                    ? controller.requestLocation
                    : controller.openSettingsForDenied,
                child: const Text('Enable Location'),
              ),
            ],
          ),
        );
    }
  }
}
