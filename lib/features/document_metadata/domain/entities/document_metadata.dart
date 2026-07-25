import 'package:equatable/equatable.dart';

class DocumentMetadata extends Equatable {
  // Core Information
  final String id;
  final String workspaceId;
  final String fileName;
  final String? fileExtension;
  final String? mimeType;
  final String filePath;
  final int? fileSize;
  final String? sha256;

  // Timestamps
  final int createdAt;
  final int modifiedAt;
  final int importedAt;
  final int? lastOpenedAt;

  // Usage Statistics
  final int openCount;
  final int? lastViewedPage;
  final double? lastScrollPosition;

  // Document Information
  final int? pageCount;
  final String? resolution;
  final int? wordCount;
  final int? paragraphCount;
  final int? characterCount;

  // Status
  final bool isFavorite;
  final bool isPinned;
  final bool isArchived;

  const DocumentMetadata({
    required this.id,
    required this.workspaceId,
    required this.fileName,
    this.fileExtension,
    this.mimeType,
    required this.filePath,
    this.fileSize,
    this.sha256,
    required this.createdAt,
    required this.modifiedAt,
    required this.importedAt,
    this.lastOpenedAt,
    this.openCount = 0,
    this.lastViewedPage,
    this.lastScrollPosition,
    this.pageCount,
    this.resolution,
    this.wordCount,
    this.paragraphCount,
    this.characterCount,
    this.isFavorite = false,
    this.isPinned = false,
    this.isArchived = false,
  });

  DocumentMetadata copyWith({
    String? id,
    String? workspaceId,
    String? fileName,
    String? fileExtension,
    String? mimeType,
    String? filePath,
    int? fileSize,
    String? sha256,
    int? createdAt,
    int? modifiedAt,
    int? importedAt,
    int? lastOpenedAt,
    int? openCount,
    int? lastViewedPage,
    double? lastScrollPosition,
    int? pageCount,
    String? resolution,
    int? wordCount,
    int? paragraphCount,
    int? characterCount,
    bool? isFavorite,
    bool? isPinned,
    bool? isArchived,
  }) {
    return DocumentMetadata(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      sha256: sha256 ?? this.sha256,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      importedAt: importedAt ?? this.importedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      openCount: openCount ?? this.openCount,
      lastViewedPage: lastViewedPage ?? this.lastViewedPage,
      lastScrollPosition: lastScrollPosition ?? this.lastScrollPosition,
      pageCount: pageCount ?? this.pageCount,
      resolution: resolution ?? this.resolution,
      wordCount: wordCount ?? this.wordCount,
      paragraphCount: paragraphCount ?? this.paragraphCount,
      characterCount: characterCount ?? this.characterCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        fileName,
        fileExtension,
        mimeType,
        filePath,
        fileSize,
        sha256,
        createdAt,
        modifiedAt,
        importedAt,
        lastOpenedAt,
        openCount,
        lastViewedPage,
        lastScrollPosition,
        pageCount,
        resolution,
        wordCount,
        paragraphCount,
        characterCount,
        isFavorite,
        isPinned,
        isArchived,
      ];
}
