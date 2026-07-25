# Changelog

All notable changes to the AURA project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.5.0] - 2026-07-25 (Search Platform Release)

This release marks the completion of the AURA offline knowledge management foundation and search platform, preparing the system for the upcoming Phase 6 (AI Intelligence Platform).

### Added
**Phase 1: Core Architecture**
- Defined Clean Architecture boundaries (Presentation, Domain, Data, Core, Infrastructure).
- Implemented robust Dependency Injection using `get_it`.
- Configured Riverpod for reactive state management.
- Set up MVVM architecture for UI decoupling.
- Developed `AppTheme`, standardized spacing, and custom typography.

**Phase 2: Document Management**
- Created core Workspace management (create, list, delete workspaces).
- Implemented robust `WorkspaceLocalDatasource` backed by SQLite.
- Added file importing mechanisms and storage abstractions.

**Phase 3: Parser & Metadata**
- Introduced the `ParserRegistry` to handle extensible file parsing.
- Implemented text extraction capabilities.
- Added metadata generation (timestamps, tags, file extensions).
- Implemented a metadata caching layer for high performance.

**Phase 4: Viewer System**
- Integrated a high-performance offline document viewer.
- Added support for reading preferences (font size, themes).
- Implemented `DocumentViewerViewModel` and isolated viewer states.

**Phase 5: Search Platform**
- **5.1 Search Foundation:** Established Domain entities (`SearchQuery`, `SearchResult`) and Data repositories.
- **5.2 Search Indexing:** Implemented `BatchIndexingServiceImpl` for asynchronous, non-blocking indexing of documents.
- **5.3 Keyword Search:** Built the `KeywordSearchEngine` with exact match and snippet generation support.
- **5.4 Hybrid Search Orchestrator:** Implemented `AbstractHybridSearchOrchestrator` to concurrently run and merge results from multiple search engines seamlessly.
- **5.5 Search UI & UX:** Developed `SearchScreen` with instant-as-you-type feedback and advanced filtering options.

### Changed
**Phase 5.6 & 5.7: Performance, Scalability & Hardening**
- Hardened architecture by strictly enforcing layer boundaries (e.g., removing Data layer imports from Domain UseCases).
- Escaped SQL wildcards in SQLite queries to prevent malicious input.
- Introduced structured `SearchLogContext` for robust observability across search events.
- Created `SearchCacheConfiguration` for immutable, testable cache bounds.
- Developed a comprehensive `SearchFailure` exception hierarchy.
