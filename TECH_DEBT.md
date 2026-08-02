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
| `StubVectorStore` | Throws `UnimplementedError` | Persist vectors to SQLite with an ANN or brute-force cosine index |
| `StubChunkingService` | Throws `UnimplementedError` | `DocumentChunkingService` already works — wire it in and delete the stub |
| `StubInferenceEngine` | Throws `UnimplementedError` | Requires on-device LLM runtime |
| `StubPromptBuilder` | Throws `UnimplementedError` | `PromptBuilderServiceImpl` already works — wire it in and delete the stub |
| `BatteryService` | Returns `0.85` / `true` | `battery_plus` |
| `ThermalService` | Returns `false` | Platform channel to `PowerManager.getCurrentThermalStatus()` |
| `MemoryService` | Returns `true` | Platform channel to `ActivityManager.MemoryInfo` |
| Knowledge graph | UI scaffold only | Entity extraction + relationship modelling |

> Two of these — the chunking service and prompt builder — have working
> implementations sitting alongside the stub. Wiring them is a small change and
> should be the first cleanup.

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
