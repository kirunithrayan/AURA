import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workspace_insight.dart';
import '../../domain/services/workspace_insights_service.dart';

import '../../../../../core/di/injection_container.dart';

final workspaceInsightsProvider = FutureProvider.family<WorkspaceInsight, String>((ref, workspaceId) async {
  final service = sl<WorkspaceInsightsService>();
  return service.generateInsight(workspaceId);
});
