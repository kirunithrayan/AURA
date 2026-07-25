# Release Notes - AURA v0.5.0

## Overview
AURA v0.5.0 marks the highly anticipated release of the production-ready Offline Search Platform. Over the last five development phases, the foundation of AURA has been established, focusing strictly on architectural purity, robust document parsing, and high-performance offline indexing.

This release does not include generative AI features; instead, it provides the bulletproof foundation required before the intelligent models are integrated.

## Completed Features
- **Document Management:** Create, delete, and organize local workspaces effortlessly.
- **Dynamic Parsers:** Extensible file parsers to handle extracting content and metadata from multiple file types completely offline.
- **Native Document Viewer:** Highly optimized document viewer with customizable reading preferences.

## Search Platform (Phase 5)
- **Hybrid Orchestration:** Introduced an advanced `HybridSearchOrchestrator` designed to merge disparate search engine results concurrently.
- **Instant Keyword Search:** Implemented a blazing-fast SQLite-backed `KeywordSearchEngine`.
- **Search UI:** Responsive search screen with real-time feedback, highlighting, and complex metadata filters (date ranges, tags, file types).

## Performance Improvements & Production Hardening
- **Batch Indexing:** File indexing operates via a non-blocking `BatchIndexingServiceImpl`, ensuring the UI never stutters during mass document imports.
- **LRU Caching:** Introduced configurable memory caching to prevent redundant disk I/O and query parsing.
- **Architecture Validation:** Strict adherence to Clean Architecture. The Domain layer is entirely decoupled from implementation details.
- **Security:** Hardened SQLite queries against malicious wildcards and injection vectors.
- **Observability:** Centralized, structured logging via `SearchLogContext` and decoupled event emission via `SearchEventBus`.

## Architecture Highlights
- Fully implemented **Clean Architecture** (Presentation, Domain, Data, Core, Infrastructure layers).
- Decoupled State Management using **Riverpod**.
- Dependency Injection handled via **GetIt** Service Locator.
- Extensive use of the **Repository Pattern** and interfaces for maximum testability.

## Known Limitations
- Search currently relies purely on strict keyword matching (TF-IDF/SQLite FTS style). Semantic understanding is not yet available.
- Supported file types are currently limited to those implemented in the core parser registry (e.g., text, markdown).
- Vector embeddings and chunking are disabled in this build.

## Next Milestone: Phase 6 (AI Intelligence Platform)
The next major release cycle (v1.0.0) will introduce:
- Local LLM Integration
- Vector Embeddings for Semantic Search
- Retrieval-Augmented Generation (RAG)
- AI-driven Document Summarization
