import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/workspace/presentation/screens/workspace_list_screen.dart';
import '../../features/workspace/presentation/screens/workspace_detail_screen.dart';
import '../../features/workspace/presentation/screens/create_workspace_screen.dart';
import '../../features/document_viewer/presentation/screens/document_viewer_screen.dart';
import '../../features/ai_insights/presentation/screens/ai_insights_screen.dart';
import '../../features/knowledge_graph/presentation/screens/knowledge_graph_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// The central GoRouter configuration for AURA.
class AppRouter {
  AppRouter._();

  // Route Names
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String workspaces = 'workspaces';
  static const String workspaceDetail = 'workspaceDetail';
  static const String createWorkspace = 'createWorkspace';
  static const String documentViewer = 'documentViewer';
  static const String aiInsights = 'aiInsights';
  static const String knowledgeGraph = 'knowledgeGraph';
  static const String search = 'search';
  static const String settings = 'settings';

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workspaces',
        name: workspaces,
        builder: (context, state) => const WorkspaceListScreen(),
      ),
      GoRoute(
        path: '/workspaces/create',
        name: createWorkspace,
        builder: (context, state) => const CreateWorkspaceScreen(),
      ),
      GoRoute(
        path: '/workspaces/:id',
        name: workspaceDetail,
        builder: (context, state) => WorkspaceDetailScreen(
          workspaceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/document/:id',
        name: documentViewer,
        builder: (context, state) => DocumentViewerScreen(
          documentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/insights/:id',
        name: aiInsights,
        builder: (context, state) => AiInsightsScreen(
          documentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/graph/:workspaceId',
        name: knowledgeGraph,
        builder: (context, state) => KnowledgeGraphScreen(
          workspaceId: state.pathParameters['workspaceId']!,
        ),
      ),
      GoRoute(
        path: '/search',
        name: search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
