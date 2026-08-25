import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/rakshak_surfaces.dart';
import '../../data/models/incident.dart';
import '../../data/repositories/incident_repository.dart';

IconData iconForCategory(IncidentCategory category) => switch (category) {
  IncidentCategory.financialFraud => Icons.currency_rupee_rounded,
  IncidentCategory.phishing => Icons.phishing_rounded,
  IncidentCategory.socialMediaHarassment => Icons.forum_outlined,
  IncidentCategory.cyberbullying => Icons.sentiment_very_dissatisfied_outlined,
  IncidentCategory.fakeProfile => Icons.person_off_outlined,
  IncidentCategory.accountHacking => Icons.lock_open_outlined,
  IncidentCategory.threatBlackmail => Icons.report_gmailerrorred_outlined,
  IncidentCategory.ransomware => Icons.enhanced_encryption_outlined,
  IncidentCategory.onlineShoppingFraud => Icons.shopping_bag_outlined,
  IncidentCategory.investmentFraud => Icons.trending_up_rounded,
  IncidentCategory.upiFraud => Icons.qr_code_2_rounded,
  IncidentCategory.cardFraud => Icons.credit_card_off_outlined,
  IncidentCategory.identityTheft => Icons.badge_outlined,
  IncidentCategory.emailFraud => Icons.mark_email_unread_outlined,
  IncidentCategory.cryptocurrencyFraud => Icons.currency_bitcoin_rounded,
  IncidentCategory.other => Icons.more_horiz_rounded,
};

/// Entry point for incident reporting — "What happened?" — the first
/// question every complaint flow starts with.
class IncidentCategoryScreen extends ConsumerWidget {
  const IncidentCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.lg,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Text(
              'What happened?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(Spacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Spacing.md,
                crossAxisSpacing: Spacing.md,
                childAspectRatio: 1.3,
              ),
              itemCount: IncidentCategory.values.length,
              itemBuilder: (context, index) {
                final category = IncidentCategory.values[index];
                return RakshakCard(
                  onTap: () async {
                    final incident = await ref
                        .read(incidentRepositoryProvider.notifier)
                        .create(category);
                    if (context.mounted) {
                      context.push('${AppRoutes.incidentForm}/${incident.id}');
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        iconForCategory(category),
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
