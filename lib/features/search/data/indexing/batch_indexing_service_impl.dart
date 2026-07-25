import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../workspace/domain/entities/workspace_file.dart';
import '../../domain/entities/optimization/batch_index_job.dart';
import '../../domain/services/batch_indexing_service.dart';
import '../../domain/repositories/search_event_bus.dart';
import '../../domain/entities/search_event.dart';
import '../../domain/repositories/search_logger.dart';
import '../../domain/entities/search_log_context.dart';
import 'search_index_service.dart';

class BatchIndexingServiceImpl implements BatchIndexingService {
  final SearchIndexService _indexService;
  final SearchEventBus _eventBus;
  final SearchLogger _logger;
  
  // In-memory job tracking for now. In a full isolate implementation, 
  // this would likely be persisted or communicated via ports.
  final Map<String, BatchIndexJob> _jobs = {};

  BatchIndexingServiceImpl(this._indexService, this._eventBus, this._logger);

  @override
  Future<String> enqueueBatch(List<WorkspaceFile> files, {int batchSize = 10}) async {
    final jobId = const Uuid().v4();
    final job = BatchIndexJob(
      jobId: jobId,
      files: files,
      status: BatchJobStatus.pending,
      createdAt: DateTime.now(),
    );
    
    _jobs[jobId] = job;
    
    // Fire and forget processing
    unawaited(_processBatch(jobId, batchSize));
    
    return jobId;
  }

  @override
  Future<BatchIndexJob?> getJobStatus(String jobId) async {
    return _jobs[jobId];
  }

  Future<void> _processBatch(String jobId, int batchSize) async {
    var job = _jobs[jobId];
    if (job == null) return;

    job = job.copyWith(status: BatchJobStatus.processing);
    _jobs[jobId] = job;

    _eventBus.publish(BatchIndexStarted(jobId: jobId, documentCount: job.files.length));

    int processedCount = 0;
    int failedCount = 0;

    try {
      for (int i = 0; i < job.files.length; i += batchSize) {
        final end = (i + batchSize < job.files.length) ? i + batchSize : job.files.length;
        final batch = job.files.sublist(i, end);

        // Process batch sequentially (or could be Future.wait for parallel)
        for (final file in batch) {
          try {
            await _indexService.indexDocument(file);
            processedCount++;
          } catch (e) {
            failedCount++;
            _logger.logWithContext(
              SearchLogContext(
                operation: 'BatchIndexDocument',
                success: false,
                workspaceId: file.workspaceId,
              ),
              errorMessage: e.toString(),
              extraData: {'jobId': jobId, 'fileId': file.id},
            );
          }
        }
        
        // Update job progress
        _jobs[jobId] = _jobs[jobId]!.copyWith(
          processedCount: processedCount,
          failedCount: failedCount,
        );
      }

      _jobs[jobId] = _jobs[jobId]!.copyWith(
        status: BatchJobStatus.completed,
        completedAt: DateTime.now(),
      );

      _eventBus.publish(BatchIndexCompleted(
        jobId: jobId,
        processedCount: processedCount,
        failedCount: failedCount,
      ));
    } catch (e) {
      _jobs[jobId] = _jobs[jobId]!.copyWith(
        status: BatchJobStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
      _eventBus.publish(BatchIndexFailed(jobId: jobId, error: e.toString()));
    }
  }
}
