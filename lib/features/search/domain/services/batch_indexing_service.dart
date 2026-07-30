import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import '../entities/optimization/batch_index_job.dart';

abstract class BatchIndexingService {
  /// Queue files for batch indexing. Returns a job ID.
  Future<String> enqueueBatch(List<WorkspaceFile> files, {int batchSize = 10});

  /// Get the status of an ongoing or completed job.
  Future<BatchIndexJob?> getJobStatus(String jobId);
}
