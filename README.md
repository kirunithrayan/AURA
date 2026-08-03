# AURA — Adaptive Unified Repository Assistant

[![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev/)
[![Version](https://img.shields.io/badge/Version-v0.6.0-orange.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-purple.svg)]()
[![Status](https://img.shields.io/badge/Status-In_Development-yellow.svg)]()

**AURA** is a document knowledge workspace for Android. You import documents into
workspaces, search across them, read them in-app, and — once configured with an
API key — ask questions about them.

> **Project status: in development (v0.6.0).**
> Document management, search, and viewing are implemented and working.
> On-device AI is **not** implemented yet — see [Current Status](#current-status)
> below for exactly what does and does not work. This section is deliberately
> explicit so the codebase is not mistaken for a finished product.

---

## Current Status

### Working

| Area | Detail |
| :--- | :--- |
| **Workspace management** | Create, rename, tag, pin, and delete multi-document workspaces |
| **Document import** | Copy files into app-private storage with metadata extraction and hashing |
| **Keyword search** | Real inverted-index pipeline: tokenizing, stop-word filtering, BM25-style matching, snippet generation with highlights |
| **Document viewers** | PDF, Markdown, plain text, and images, with per-document reading state |
| **Encrypted storage** | SQLite via SQLCipher (AES-256); key held in Android Keystore |
| **Diagnostics screen** | Index counts, search latency, cache metrics |

### Not working yet

| Area | Detail |
| :--- | :--- |
| **On-device embeddings** | `OnnxEmbeddingService` throws `EmbeddingModelUnavailableException`. Needs the MiniLM `.onnx` file plus a Dart WordPiece tokenizer. |
| **Semantic search** | Depends on embeddings. Returns no results, so hybrid search degrades to keyword-only. |
| **Ask AURA (RAG)** | Retrieval and prompt assembly are implemented, but generation requires a **Google Gemini API key** supplied by the user. Without one, the feature reports the missing key rather than answering. |
| **Device telemetry** | `BatteryService`, `ThermalService`, and `MemoryService` return fixed values. The adaptive scheduler that would consume them is not built. |
| **Knowledge graph** | UI scaffold only. |
| **Vector persistence** | Embeddings are not stored; there is no vector index yet. Blocked on on-device embeddings. |

### Privacy and data handling

This is **not** a fully offline app today, and the code does not claim to be.

- Your documents, index, and database **never leave the device**.
- Keyword search, viewing, and workspace management run **entirely locally**.
- **Ask AURA is the exception.** It sends the retrieved document excerpts and
  your question to **Google's Gemini API**. It is off unless you add your own
  API key in Settings.
- Your API key is stored in the Android Keystore. It is never compiled into the
  binary and never leaves the device.

Making AURA fully offline is the goal of the next milestone (see
[Roadmap](#roadmap)).

---

## Architecture

Clean Architecture with MVVM:

```
lib/
├── core/                  # Encrypted database, DI, routing, theme, text engine
├── features/
│   ├── ai/                # Embeddings, RAG, knowledge graph, personalization
│   ├── diagnostics/       # Index health and performance metrics
│   ├── document_metadata/ # Metadata extraction and caching
│   ├── document_viewer/   # Viewer registry and format wrappers
│   ├── home/              # Dashboard and navigation
│   ├── search/            # Query processing, engines, ranking, filters
│   ├── settings/          # Preferences and AI configuration
│   └── workspace/         # Workspace CRUD and file import
└── services/              # Platform-facing services
```

Each feature is split into `domain/` (entities, interfaces, failures),
`data/` (implementations, data sources), and `presentation/`
(screens, widgets, viewmodels). Dependencies point inward.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the dependency graph and data flow.

---

## Tech Stack

| Concern | Choice |
| :--- | :--- |
| Framework | Flutter 3.44 / Dart 3.5 |
| State management | Riverpod |
| Dependency injection | GetIt (88 registrations) |
| Database | SQLite + SQLCipher |
| Secure storage | `flutter_secure_storage` (Android Keystore) |
| Error handling | `fpdart` (`Either<Failure, T>`) |
| Routing | `go_router` |
| PDF rendering | `syncfusion_flutter_pdfviewer`, `pdfx` (thumbnails) |
| Cloud LLM | `google_generative_ai` (Gemini) — optional, user-supplied key |
| Planned on-device ML | `flutter_onnxruntime` (not yet active) |

> **Licensing note:** `syncfusion_flutter_pdfviewer` is distributed under the
> Syncfusion Community License, not MIT. AURA's own source is MIT, but this
> dependency carries its own terms — review them before any commercial use.

---

## Build Instructions

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Android SDK, API 24+

### Steps

```bash
git clone https://github.com/kirunithrayan/AURA.git
cd AURA
flutter pub get
```

Run code generation if you modify Freezed or Riverpod models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Verify:

```bash
flutter analyze && flutter test
```

Build a release APK:

```bash
flutter build apk --release
```

### Enabling Ask AURA

1. Get a free API key from [Google AI Studio](https://aistudio.google.com/).
2. Launch AURA and open **Settings → AI Engine Configuration**.
3. Paste the key and save.

The key is stored in the Android Keystore on that device only. There is no
build-time configuration and no key in the repository.

---

## Project Metrics

| Metric | Value |
| :--- | :--- |
| Dart files (excluding generated) | 367 |
| Lines of Dart (excluding generated) | ~19,500 |
| Test files | 12 |
| Lines of test code | ~880 |
| Analyzer errors | 0 |
| Tests passing | 31 / 31 |

Test coverage is low (~3% by line count) and concentrated in search ranking,
chunking, and text preprocessing. Widget and integration tests are a known gap.

---

## Roadmap

| Milestone | Goal |
| :--- | :--- |
| **v0.7** | Dart WordPiece tokenizer + bundled MiniLM model → real on-device embeddings |
| **v0.8** | Local LLM inference, removing the Gemini dependency for a genuinely offline RAG path |
| **v0.9** | Real battery/thermal/memory platform channels and the adaptive indexing scheduler |
| **v1.0** | Widget and integration test coverage; knowledge graph implementation |

See [TECH_DEBT.md](TECH_DEBT.md) for known issues and deferred work.

---

## License

MIT — see [LICENSE](LICENSE). Third-party dependencies carry their own licenses;
see the licensing note above.
