import 'package:equatable/equatable.dart';
import '../../../../workspace/domain/entities/workspace_file.dart';

enum BatchJobStatus { pending, processing, completed, failed }

class BatchIndexJob extends Equatable {

  const BatchIndexJob({
    required this.jobId,
    required this.files,
    this.status = BatchJobStatus.pending,
    this.processedCount = 0,
    this.failedCount = 0,
    required this.createdAt,
    this.completedAt,
    this.error,
  });
  final String jobId;
  final List<WorkspaceFile> files;
  final BatchJobStatus status;
  final int processedCount;
  final int failedCount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;

  BatchIndexJob copyWith({
    BatchJobStatus? status,
    int? processedCount,
    int? failedCount,
    DateTime? completedAt,
    String? error,
  }) => BatchIndexJob(
      jobId: jobId,
      files: files,
      status: status ?? this.status,
      processedCount: processedCount ?? this.processedCount,
      failedCount: failedCount ?? this.failedCount,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
    );

  @override
  List<Object?> get props => [
        jobId,
        files,
        status,
        processedCount,
        failedCount,
        createdAt,
        completedAt,
        error,
      ];
}
