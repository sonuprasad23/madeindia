import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/case_record.dart';
import '../../data/models/link_check_result.dart';
import '../../data/models/risk_level.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/case_repository.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/link_repository.dart';
import '../../features/location/current_location_controller.dart';

/// Synthetic baseline counts representing a larger simulated user base —
/// clearly demo data, blended with live counts from this session's actual
/// repositories so admin/citizen actions visibly move the numbers.
class _Baseline {
  static const totalUsers = 12482;
  static const activeCasesBaseline = 1294;
  static const incidentsTodayBaseline = 283;
  static const linksCheckedBaseline = 42891;
  static const highRiskLinksBaseline = 1842;
  static const evidenceUploadedBaseline = 15204;
}

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cases = ref.watch(caseRepositoryProvider);
    final links = ref.watch(linkRepositoryProvider);
    final evidence = ref.watch(evidenceRepositoryProvider);
    final threatDomains = ref.watch(threatDomainRepositoryProvider);

    final activeCases =
        _Baseline.activeCasesBaseline +
        cases
            .where(
              (c) =>
                  c.status != CaseStatus.closed &&
                  c.status != CaseStatus.resolved,
            )
            .length;
    final linksChecked = _Baseline.linksCheckedBaseline + links.length;
    final highRiskLinks =
        _Baseline.highRiskLinksBaseline +
        links.where((l) => l.riskLevel == RiskLevel.dangerous).length +
        threatDomains.where((d) => d.status == RiskLevel.dangerous).length;
    final evidenceUploaded =
        _Baseline.evidenceUploadedBaseline + evidence.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakshak Admin — Overview'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.md,
            children: [
              _StatTile(
                label: 'Total Users',
                value: _Baseline.totalUsers.toString(),
              ),
              _StatTile(label: 'Active Cases', value: activeCases.toString()),
              _StatTile(
                label: 'Incidents Today',
                value: _Baseline.incidentsTodayBaseline.toString(),
              ),
              _StatTile(label: 'Links Checked', value: linksChecked.toString()),
              _StatTile(
                label: 'High-Risk Links',
                value: highRiskLinks.toString(),
              ),
              _StatTile(
                label: 'Evidence Uploaded',
                value: evidenceUploaded.toString(),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ChartCard(
                  title: 'Case status distribution',
                  child: _CaseStatusChart(cases: cases),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _ChartCard(
                  title: 'Link risk distribution (this session)',
                  child: _LinkRiskChart(links: links),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LinkChecksBreakdownCard(links: links)),
              const SizedBox(width: Spacing.md),
              const Expanded(child: _LocationStatisticsCard()),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'All figures on this screen are synthetic demo data blended with this session\'s activity — not connected to a real user base.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkChecksBreakdownCard extends StatelessWidget {
  const _LinkChecksBreakdownCard({required this.links});
  final List<LinkCheckResult> links;

  static const _baseline = {
    RiskLevel.safe: 30,
    RiskLevel.suspicious: 8,
    RiskLevel.dangerous: 4,
    RiskLevel.unknown: 3,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = {
      for (final level in RiskLevel.values) level: _baseline[level] ?? 0,
    };
    for (final l in links) {
      counts[l.riskLevel] = (counts[l.riskLevel] ?? 0) + 1;
    }
    final total = counts.values.fold(0, (a, b) => a + b);

    return RakshakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link Checks',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: $total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          for (final level in RiskLevel.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(level.emoji),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      level.shortLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${counts[level]}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Aggregated/demo only — never shows a precise per-user location. The
/// only real signal is which STATE this device's own location (if shared)
/// falls into, folded into a synthetic state-level distribution.
class _LocationStatisticsCard extends ConsumerWidget {
  const _LocationStatisticsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = ref.watch(currentLocationProvider).info;

    final states = <String, int>{
      'Maharashtra': 412,
      'Gujarat': 287,
      'Karnataka': 233,
      'Delhi (NCT)': 198,
      'Uttar Pradesh': 176,
    };
    if (location?.state != null) {
      states[location!.state!] = (states[location.state!] ?? 0) + 1;
    }
    final sorted = states.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RakshakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Statistics',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aggregated by state only — never exact coordinates',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          for (final entry in sorted.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key, style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    '${entry.value}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 200,
      child: RakshakCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RakshakCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(height: 180, child: child),
        ],
      ),
    );
  }
}

class _CaseStatusChart extends StatelessWidget {
  const _CaseStatusChart({required this.cases});
  final List<CaseRecord> cases;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final counts = <CaseStatus, int>{};
    for (final c in cases) {
      counts[c.status] = (counts[c.status] ?? 0) + 1;
    }
    // Demo baseline so the chart never looks empty before any complaint is submitted.
    if (counts.isEmpty) {
      counts[CaseStatus.underReview] = 3;
      counts[CaseStatus.underInvestigation] = 2;
      counts[CaseStatus.resolved] = 1;
    }
    final colors = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.outline,
    ];
    final entries = counts.entries.toList();

    return PieChart(
      PieChartData(
        sections: [
          for (var i = 0; i < entries.length; i++)
            PieChartSectionData(
              value: entries[i].value.toDouble(),
              title: entries[i].value.toString(),
              color: colors[i % colors.length],
              radius: 60,
              titleStyle: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 24,
      ),
    );
  }
}

class _LinkRiskChart extends StatelessWidget {
  const _LinkRiskChart({required this.links});
  final List<LinkCheckResult> links;

  @override
  Widget build(BuildContext context) {
    final counts = {for (final level in RiskLevel.values) level: 0};
    for (final l in links) {
      counts[l.riskLevel] = (counts[l.riskLevel] ?? 0) + 1;
    }
    // Demo baseline distribution.
    final baseline = {
      RiskLevel.safe: 30,
      RiskLevel.suspicious: 8,
      RiskLevel.dangerous: 4,
      RiskLevel.unknown: 3,
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final level =
                    RiskLevel.values[value.toInt() % RiskLevel.values.length];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    level.shortLabel,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: [
          for (var i = 0; i < RiskLevel.values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY:
                      (baseline[RiskLevel.values[i]] ?? 0).toDouble() +
                      (counts[RiskLevel.values[i]] ?? 0).toDouble(),
                  color: RiskLevel.values[i].color(
                    Theme.of(context).brightness,
                  ),
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
