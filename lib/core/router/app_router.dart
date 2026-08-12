import 'app_routes.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/workspace/presentation/screens/workspace_detail_screen.dart';
import '../../features/workspace/presentation/screens/create_workspace_screen.dart';
import '../../features/document_viewer/presentation/screens/document_viewer_screen.dart';
import '../../features/ai/rag/presentation/screens/ask_aura_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';


/// The central GoRouter configuration for AURA.
class AppRouter {
  AppRouter._();


  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workspaces/create',
        name: AppRoutes.createWorkspace,
        builder: (context, state) => const CreateWorkspaceScreen(),
      ),
      GoRoute(
        path: '/workspaces/:id',
        name: AppRoutes.workspaceDetail,
        builder: (context, state) => WorkspaceDetailScreen(
          workspaceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/document/:id',
        name: AppRoutes.documentViewer,
        builder: (context, state) => DocumentViewerScreen(
          documentId: state.pathParameters['id']!,
        ),
      ),
      // AI Insights is deferred from v1.0 and therefore unrouted. The screen
      // and its code remain on disk so re-enabling it is a routing change.

      GoRoute(
        path: '/ask/:workspaceId',
        name: AppRoutes.askAura,
        builder: (context, state) => AskAuraScreen(
          workspaceId: state.pathParameters['workspaceId']!,
        ),
      ),

      // Knowledge Graph is deferred from v1.0 and therefore unrouted. The
      // screen and its code remain on disk so re-enabling it is a routing
      // change.

      GoRoute(
        path: '/search',
        name: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Diagnostics is deferred from v1.0 (not user-facing) and therefore
      // unrouted. The screen and its code remain on disk so re-enabling it is a
      // routing change.
    ],
  );
}
