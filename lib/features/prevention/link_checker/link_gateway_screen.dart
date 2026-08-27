import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/browser_launcher.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/widgets/rakshak_button.dart';
import 'link_checker_screen.dart';

/// The Link Security Gateway: shown whenever a URL arrives at Rakshak
/// from OUTSIDE the app — tapped in another app (Android `ACTION_VIEW`)
/// or shared in (Android `ACTION_SEND`) — before anything is opened.
///
/// This is the "OTHER APP -> Android URL Intent -> RAKSHAK -> Gateway"
/// flow: the user explicitly chooses to check it, open it directly, or
/// cancel. Nothing is opened automatically just because a link arrived.
class LinkGatewayScreen extends StatelessWidget {
  const LinkGatewayScreen({super.key, required this.url, this.sourceAppLabel});

  final String url;
  final String? sourceAppLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = UrlUtils.normalize(url);
    final domain = normalized?.domain ?? 'Unable to determine domain';

    return Scaffold(
      appBar: AppBar(title: const Text('Check this link?')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Check this link',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    url,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (sourceAppLabel != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Received from $sourceAppLabel',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Rakshak can check this link for known security threats before opening it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            RakshakButton(
              label: 'Check Link',
              icon: Icons.shield_outlined,
              onPressed: () => context.pushReplacement(
                AppRoutes.linkChecker,
                extra: LinkCheckerLaunchArgs(
                  url: url,
                  sourceApp: sourceAppLabel,
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            RakshakButton(
              label: 'Open Directly',
              icon: Icons.open_in_new_rounded,
              variant: RakshakButtonVariant.secondary,
              onPressed: () async {
                final ok = await BrowserLauncher.openExternally(url);
                if (context.mounted) {
                  if (ok) {
                    context.pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open a browser for this link.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: Spacing.sm),
            RakshakButton(
              label: 'Cancel',
              variant: RakshakButtonVariant.text,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
