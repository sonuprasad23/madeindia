import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum RakshakTimelineState { done, current, upcoming }

class RakshakTimelineEntry {
  const RakshakTimelineEntry({
    required this.title,
    this.subtitle,
    this.state = RakshakTimelineState.upcoming,
    this.onExplain,
  });

  final String title;
  final String? subtitle;
  final RakshakTimelineState state;
  final VoidCallback? onExplain;
}

/// Vertical status timeline — used for both incident event timelines and
/// case status progress.
class RakshakTimeline extends StatelessWidget {
  const RakshakTimeline({super.key, required this.entries});

  final List<RakshakTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;

        Color dotColor;
        Widget dot;
        switch (entry.state) {
          case RakshakTimelineState.done:
            dotColor = scheme.primary;
            dot = CircleAvatar(
              radius: 10,
              backgroundColor: dotColor,
              child: Icon(Icons.check, size: 12, color: scheme.onPrimary),
            );
          case RakshakTimelineState.current:
            dotColor = scheme.secondary;
            dot = CircleAvatar(radius: 10, backgroundColor: dotColor);
          case RakshakTimelineState.upcoming:
            dotColor = scheme.outlineVariant;
            dot = CircleAvatar(
              radius: 10,
              backgroundColor: scheme.surface,
              child: CircleAvatar(radius: 5, backgroundColor: dotColor),
            );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  dot,
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: entry.state == RakshakTimelineState.upcoming
                            ? scheme.outlineVariant.withValues(alpha: 0.5)
                            : scheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight:
                                        entry.state ==
                                            RakshakTimelineState.upcoming
                                        ? FontWeight.w400
                                        : FontWeight.w600,
                                    color:
                                        entry.state ==
                                            RakshakTimelineState.upcoming
                                        ? scheme.onSurfaceVariant
                                        : scheme.onSurface,
                                  ),
                            ),
                            if (entry.subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  entry.subtitle!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (entry.onExplain != null)
                        IconButton(
                          icon: const Icon(
                            Icons.help_outline_rounded,
                            size: 20,
                          ),
                          tooltip: 'What does this mean?',
                          onPressed: entry.onExplain,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
