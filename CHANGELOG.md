# Changelog

All notable changes to the AURA project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.6.0] - 2026-08-02 (Accuracy Release)

A correction release. The previous tag was labelled v1.0.0 and documented several
placeholder components as complete features. This release removes those claims,
replaces placeholder behaviour that was masking real failures, and moves the
Gemini API key to runtime secure storage. Full detail in
[RELEASE_NOTES_v0.6.0.md](RELEASE_NOTES_v0.6.0.md).

### Fixed
- **Create Workspace** saved nothing — the Save button's `onPressed` was an empty
  callback. Now wired to the viewmodel with validation and error handling.
- **`OnnxEmbeddingService`** returned synthetic vectors from `text.hashCode`,
  scoring ~0.75 similarity between unrelated documents and feeding noise into
  hybrid ranking. It now throws `EmbeddingModelUnavailableException`, so semantic
  search returns nothing and hybrid search degrades cleanly to keyword-only.
- **`AiProviderFactoryImpl`** silently returned `StubLocalProvider` when the
  Gemini key was missing, so Ask AURA answered with placeholder text that read
  like a model response. It now throws `MissingApiKeyException`.

### Added
- `AiKeyStore` / `SecureAiKeyStore` — Gemini API key stored in the Android
  Keystore, entered via **Settings → AI Engine Configuration**, read at point of
  use. Replaces the compile-time `String.fromEnvironment` key.
- `AiKeyDialog` for entering, replacing, and removing the key.
- Explicit data-handling notice in Settings: Ask AURA transmits excerpts to
  Google.
- `LICENSE` (MIT) — previously linked from the README but absent.

### Changed
- Version corrected from 1.0.0 to 0.6.0.
- `README.md` rewritten with an explicit Working / Not working yet breakdown and
  a roadmap.
- `PROJECT_STATS.md` now reports measured figures; the prior version understated
  file count by roughly 30%.
- `StubLocalProvider` documented as a test fixture, reachable only via an
  explicit `providerName: 'stub'`.

### Removed
- `dartz` dependency — the project carried both `dartz` and `fpdart` for the same
  `Either` type. Five files migrated to `fpdart`.
- `RELEASE_NOTES_v1.0.0.md` and `GITHUB_RELEASE.md`, whose claims did not survive
  verification (a built APK that did not exist, "31/31 passing" while 2 failed,
  "0 compilation errors" against 6).
- Three untracked scratch files from an automated debugging session.

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
