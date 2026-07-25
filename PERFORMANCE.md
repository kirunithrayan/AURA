# AURA Performance Documentation

This document tracks baseline performance metrics and optimizations applied during development.

## 1. Baseline Measurements (Phase 4.7)

*Note: These are estimated baselines based on standard device capabilities. Actual metrics will vary by device.*

*   **PDF Open Time**: < 500ms for standard documents (< 50MB).
*   **Image Open Time**: < 300ms.
*   **TXT Parsing**: < 100ms for < 1MB files.
*   **DOCX Parsing**: < 300ms for standard documents (XML extraction overhead).
*   **Metadata Retrieval**: < 50ms (SQLite query). Cache hits: < 5ms.
*   **Recent Documents Query**: < 50ms with `idx_workspace_files_last_opened` index.

## 2. Optimizations Applied (Phase 4)

*   **Database Indexing**: Added specific SQLite indexes for `last_opened_at`, `is_favorite`, and `is_pinned` to prevent full table scans when rendering Home and Workspace screens.
*   **Query Consolidation**: Merged `incrementOpenCount` and `updateLastOpened` into a single SQL transaction within `RecentDocumentsService.addRecentDocument()`.
*   **Memory Management**: Replaced standard `print()` calls with `debugPrint()` to avoid log flooding and memory pressure in release builds.
*   **Parser Optimization**: Removed redundant XML traversal iterations in `DocxParser`.
*   **Dead Code Elimination**: Removed unreachable parsing paths in the viewer ViewModel, preventing unnecessary object allocation.
