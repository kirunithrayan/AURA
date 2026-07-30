import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/services/recommendation_service.dart';

import '../../../../../core/di/injection_container.dart';

final recommendationsProvider = FutureProvider.family<List<Recommendation>, String>((ref, workspaceId) async {
  final service = sl<RecommendationService>();
  return service.getRecommendations(workspaceId);
});
