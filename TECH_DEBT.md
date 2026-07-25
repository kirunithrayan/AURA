# AURA Technical Debt & Deferred Work

This document tracks intentionally deferred features and known technical debt for future phases.

## 1. Architectural Debt

*   **File Copying Overhead**: Currently, importing files copies them entirely into application storage. For large files, this is inefficient. Future phases should support URI referencing or scoped storage access where possible.
*   **In-Memory Caching**: `MetadataCache` currently holds objects indefinitely. It needs an LRU (Least Recently Used) eviction policy to prevent memory leaks when managing thousands of documents.

## 2. Deferred Features (Future Phases)

| Feature | Planned Phase | Reason for Deferral |
| :--- | :--- | :--- |
| **Hybrid Search (Keyword + Semantic)** | Phase 5 | Requires local embedding engine and vector database integration, which is a major architectural addition. |
| **Document Search (Ctrl+F)** | Phase 5 | Depends on the full-text indexing system planned for Phase 5 to avoid blocking the main thread on large documents. |
| **AI Summarization & Insights** | Phase 6 | Requires stable integration with local LLMs (Llama/Mistral) via the AI abstraction layer. |
| **Knowledge Graph Visualization** | Phase 7 | Complex UI/UX rendering requirements (force-directed graphs) that distract from core viewer stability. |
| **Adaptive Background Scheduler** | Phase 8 | Requires complex WorkManager and battery/thermal monitoring logic. |

## 3. Minor Known Issues

*   **PDF Password Protection**: The PDF viewer currently detects password-protected files but simply shows an "Unsupported" error state. UI for password entry needs to be built.
*   **DOCX Formatting**: The DOCX parser extracts raw text and headings but loses complex formatting (tables, inline images). A full DOCX rendering engine is deferred indefinitely.
