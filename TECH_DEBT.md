# AURA Technical Debt & Deferred Work

Known gaps, placeholders, and deferred work. Entries here are things the code
does **not** do — the README's Current Status table is the user-facing summary.

## 1. Non-functional components

These are registered in DI and appear in the architecture, but do not work. They
exist so the interfaces are stable; none of them should be counted as a feature.

| Component | Behaviour | To make real |
| :--- | :--- | :--- |
| `OnnxEmbeddingService` | Throws `EmbeddingModelUnavailableException` | Bundle `all-MiniLM-L6-v2.onnx` + `vocab.txt`; write a Dart WordPiece tokenizer; replace the throw with `session.run()` |
| `SemanticSearchEngine` | Returns `[]` (embedding failure is caught) | Depends on the above |
| Vector persistence | Not implemented | Persist vectors to SQLite with an ANN or brute-force cosine index |
| On-device inference | Not implemented | Requires an on-device LLM runtime |
| `BatteryService` | Returns `0.85` / `true` | `battery_plus` |
| `ThermalService` | Returns `false` | Platform channel to `PowerManager.getCurrentThermalStatus()` |
| `MemoryService` | Returns `true` | Platform channel to `ActivityManager.MemoryInfo` |
| Knowledge graph | UI scaffold only | Entity extraction + relationship modelling |

> **Resolved 2026-08-03.** An unused `Abstract*` AI layer (embedding engine,
> inference engine, chunking service, prompt builder, vector store, plus an
> `AIServiceRegistry` and its Riverpod providers) was registered in DI but had
> **no consumers anywhere in the codebase**. Chunking and prompt building were
> already handled by `DocumentChunkingService` and `PromptBuilderServiceImpl`,
> which are wired and tested. The dead layer was deleted rather than wired,
> since adapting it would have meant writing translation code so unused code
> could call working code.

## 2. Architectural debt

- **File copying overhead.** Import copies files wholesale into app storage.
  For large files this wastes space; URI referencing or scoped storage would be
  better.
- **Unbounded metadata cache.** `MetadataCache` holds objects indefinitely with
  no LRU eviction. This will leak across thousands of documents.
- **Not offline.** The only working generation path is Google Gemini. The
  "offline-first" goal is not met until on-device inference lands (roadmap v0.8).
- **`importFile(String path)` is unsupported** on the repository interface — the
  picker flow calls `persistImportedFile` instead. The interface should be
  changed to match reality rather than keeping a method that always fails.

## 3. Testing debt

- Coverage is roughly **3% by line count** (884 test lines against 19,475 source
  lines).
- **No widget tests and no integration tests.** The Create Workspace no-op bug
  survived to a tagged release because nothing exercised the UI.
- Existing tests cover search ranking, chunking, text preprocessing, and cosine
  similarity — all pure functions. Nothing covers repositories, viewmodels, or
  database code.

## 4. Dependency debt

- **`syncfusion_flutter_pdfviewer`** is under the Syncfusion Community License,
  not MIT. It is the only PDF viewer in use; `pdfx` is also present but only for
  thumbnails. Consolidating on `pdfx` would remove the licensing asymmetry, at
  the cost of rewriting `PdfEngineWrapper`.
- **`workmanager`** uses a deprecated `isInDebugMode` parameter.
- 69 packages have newer versions blocked by current constraints.

## 5. Minor known issues

- **PDF password protection**: detected, but shows an "Unsupported" state
  instead of a password prompt.
- **DOCX formatting**: the parser extracts text and headings but drops tables and
  inline images.
- **14 analyzer warnings** remain, mostly unused private fields and two
  `invalid_use_of_protected_member` uses of Riverpod's `state` in
  `action_commands.dart`.

## 6. UI migration debt (Step 6)

- **Library app-bar actions are a temporary compatibility exception.** Direction B
  does not authorise Global Search, Create Workspace, or Settings as Library
  app-bar actions; the blueprint's only app-bar mapping is
  `ImportFab -> AuraIconButton in app bar`, which belongs to the Course screen.
  They were retained because the old Home screen held the only entry points to
  those routes. Revisit in Step 7, where Search and Settings are migrated.
- **Continue Reading is omitted** from the Library under the blueprint's §7.4
  fallback: `lastViewedPage` / `lastScrollPosition` exist in the schema but
  nothing writes them, so durable reading-position persistence does not exist.
  The section returns once that persistence lands.
- **Course colors are derived, not stored.** `auraCourseColorForWorkspaceId`
  maps a workspace's stable id onto one of the eight design-system course
  colors. `Workspace.color` (legacy nullable ARGB) is unused and there is no
  authoritative course-color policy; replacing that one function is the whole
  migration when a policy exists.
- **`workspace_grid.dart` and `workspace_card.dart` are now unreferenced**
  following the retirement of `workspace_list_screen.dart`. They are left for
  the Step 9 legacy sweep.
- **`HomeScreen` retains its class and file name** while presenting the Library,
  to avoid router and test churn mid-migration.
