import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../admin/auth/admin_auth_controller.dart';
import '../../admin/auth/admin_login_screen.dart';
import '../../admin/complaints/admin_cases_screen.dart';
import '../../admin/content/admin_content_screen.dart';
import '../../admin/dashboard/admin_dashboard_screen.dart';
import '../../admin/links/admin_links_screen.dart';
import '../../admin/settings/admin_settings_screen.dart';
import '../../admin/shared/admin_shell.dart';
import '../../admin/users/admin_users_screen.dart';
import '../../data/models/link_check_result.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/cases/case_detail_screen.dart';
import '../../features/cases/cases_list_screen.dart';
import '../../features/complaints/complaint_review_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/evidence/evidence_detail_screen.dart';
import '../../features/evidence/evidence_vault_screen.dart';
import '../../features/incidents/incident_category_screen.dart';
import '../../features/incidents/incident_form_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/prevention/awareness/awareness_screen.dart';
import '../../features/prevention/link_checker/link_checker_screen.dart';
import '../../features/prevention/link_checker/link_gateway_screen.dart';
import '../../features/prevention/link_checker/link_history_screen.dart';
import '../../features/prevention/link_checker/link_result_screen.dart';
import '../../features/prevention/prevention_home_screen.dart';
import '../../features/prevention/qr_scanner/qr_scanner_screen.dart';
import '../../features/prevention/safe_viewer/safe_viewer_screen.dart';
import '../../features/profile/identity_documents_screen.dart';
import '../../features/profile/profile_edit_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/social_identities_screen.dart';
import '../../features/settings/settings_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final isAdminSignedIn = ref.watch(adminAuthProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isAdminRoute =
          path.startsWith('/admin') && path != AppRoutes.adminLogin;
      if (isAdminRoute && !isAdminSignedIn) return AppRoutes.adminLogin;
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.protect,
            builder: (context, state) => const PreventionHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.report,
            builder: (context, state) => const IncidentCategoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.cases,
            builder: (context, state) => const CasesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.linkGateway,
        builder: (context, state) {
          final extra = state.extra as Map<String, String?>;
          return LinkGatewayScreen(
            url: extra['url']!,
            sourceAppLabel: extra['sourceApp'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.linkChecker,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is LinkCheckerLaunchArgs) {
            return LinkCheckerScreen(
              initialUrl: extra.url,
              sourceApp: extra.sourceApp,
            );
          }
          return LinkCheckerScreen(initialUrl: extra as String?);
        },
      ),
      GoRoute(
        path: AppRoutes.linkCheckerResult,
        builder: (context, state) =>
            LinkResultScreen(result: state.extra as LinkCheckResult),
      ),
      GoRoute(
        path: AppRoutes.linkHistory,
        builder: (context, state) => const LinkHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.safeViewer,
        builder: (context, state) =>
            SafeViewerScreen(result: state.extra as LinkCheckResult),
      ),
      GoRoute(
        path: AppRoutes.awareness,
        builder: (context, state) => const AwarenessScreen(),
      ),

      GoRoute(
        path: '${AppRoutes.incidentForm}/:incidentId',
        builder: (context, state) =>
            IncidentFormScreen(incidentId: state.pathParameters['incidentId']!),
      ),
      GoRoute(
        path: '${AppRoutes.complaintReview}/:incidentId',
        builder: (context, state) => ComplaintReviewScreen(
          incidentId: state.pathParameters['incidentId']!,
        ),
      ),

      GoRoute(
        path: '${AppRoutes.caseDetail}/:caseId',
        builder: (context, state) =>
            CaseDetailScreen(caseId: state.pathParameters['caseId']!),
      ),

      GoRoute(
        path: AppRoutes.evidenceVault,
        builder: (context, state) => const EvidenceVaultScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.evidenceDetail}/:evidenceId',
        builder: (context, state) => EvidenceDetailScreen(
          evidenceId: state.pathParameters['evidenceId']!,
        ),
      ),

      GoRoute(
        path: AppRoutes.citizenProfileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.identityDocuments,
        builder: (context, state) => const IdentityDocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.socialIdentities,
        builder: (context, state) => const SocialIdentitiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.assistant,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return AssistantScreen(
            seedQuestion: extra?['seedQuestion'],
            focusedCaseId: extra?['focusedCaseId'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),

      GoRoute(
        path: AppRoutes.adminLogin,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(currentPath: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminCases,
            builder: (context, state) => const AdminCasesScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminLinks,
            builder: (context, state) => const AdminLinksScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminContent,
            builder: (context, state) => const AdminContentScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminSettings,
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
