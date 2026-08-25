import 'package:flutter/material.dart';

import '../../data/models/case_record.dart';
import '../../data/models/risk_level.dart';
import '../theme/design_tokens.dart';

/// Generic status chip — used for case statuses and other enumerable
/// states that aren't risk levels (which get [RakshakRiskBadge] instead).
class RakshakStatusChip extends StatelessWidget {
  const RakshakStatusChip({super.key, required this.status});

  final CaseStatus status;

  Color _color(ColorScheme scheme) => switch (status) {
    CaseStatus.draft => scheme.outline,
    CaseStatus.submitted => scheme.primary,
    CaseStatus.forwarded => scheme.primary,
    CaseStatus.underReview => scheme.secondary,
    CaseStatus.additionalInfoRequired => scheme.tertiary,
    CaseStatus.underInvestigation => scheme.secondary,
    CaseStatus.resolved => scheme.primary,
    CaseStatus.closed => scheme.outline,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _color(scheme);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Risk badge for link-checking results — the single most important
/// status indicator in the app, so it gets its own component with a
/// consistent emoji + label + color contract everywhere it's used.
class RakshakRiskBadge extends StatelessWidget {
  const RakshakRiskBadge({super.key, required this.level, this.dense = false});

  final RiskLevel level;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = level.color(brightness);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? Spacing.sm : Spacing.lg,
        vertical: dense ? 4 : Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, size: dense ? 16 : 20, color: color),
          const SizedBox(width: 6),
          Text(
            dense ? level.shortLabel : level.label,
            style:
                (dense
                        ? Theme.of(context).textTheme.labelMedium
                        : Theme.of(context).textTheme.titleSmall)
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
