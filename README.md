# AURA — Adaptive Unified Repository Assistant

![AURA Banner](docs/images/banner_placeholder.png)

[![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev/)
[![Version](https://img.shields.io/badge/Version-v1.0.0-green.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-purple.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)]()

## Project Overview

**AURA (Adaptive Unified Repository Assistant)** is an AI-powered, 100% offline knowledge management and smart document intelligence system for Android and cross-platform desktop. Designed with privacy by design, AURA parses, indexes, embeds, and executes Retrieval-Augmented Generation (RAG) over your local workspace documents without sending any data to external servers.

---

## Key Features

- **AI-Powered Offline RAG & Chat:** Ask questions directly to your documents using locally executed ONNX embeddings and context builder engines.
- **Hybrid Search Engine:** Combines dense semantic vector search with SQLite-backed indexed BM25 keyword matching for high-precision document retrieval.
- **Workspace Management:** Create, organize, pin, tag, and manage multi-document workspaces with background file indexing.
- **High-Performance Document Viewers:** Native rendering for PDFs, Markdown, Plain Text, and Images.
- **Diagnostics & Health System:** System telemetry monitoring storage usage, battery impact, thermal states, and embedding index status.
- **Offline First & Secure:** Zero network dependencies. Encrypted database storage using SQLCipher.

---

## Architecture

AURA is built following **Clean Architecture** principles and the **MVVM (Model-View-ViewModel)** design pattern:

```
lib/
├── core/                  # Core utilities, encrypted database, routing, and DI
├── features/              # Feature modules
│   ├── ai/                # Embeddings (ONNX), RAG, and Personalization
│   ├── diagnostics/       # System health, telemetry, and index diagnostics
│   ├── document_metadata/ # File metadata extraction and caching
│   ├── document_viewer/   # High-performance viewer registry and widgets
│   ├── home/              # Main dashboard and navigation
│   ├── search/            # Hybrid ranking, keyword engine, and semantic search
│   ├── settings/          # System preferences and configuration
│   └── workspace/         # Workspace management and background indexing
└── main.dart
```

---

## Technologies Used

- **Framework:** Flutter / Dart
- **State Management:** Riverpod (`flutter_riverpod`, `riverpod_generator`)
- **Database:** Encrypted SQLite (`sqflite_sqlcipher`, `flutter_secure_storage`)
- **AI / Embeddings:** ONNX Runtime (`flutter_onnxruntime`)
- **OCR:** Google MLKit Text Recognition (`google_mlkit_text_recognition`)
- **Dependency Injection:** `get_it`
- **Routing:** `go_router`
- **Background Processing:** `workmanager`
- **Serialization:** `freezed`, `json_serializable`

---

## Screenshots

| Dashboard | Document Viewer | Search & RAG |
| :---: | :---: | :---: |
| ![Dashboard](docs/images/screenshot_dashboard.png) | ![Viewer](docs/images/screenshot_viewer.png) | ![Search](docs/images/screenshot_search.png) |

---

## Build Instructions & Installation

### Prerequisites

- Flutter SDK (v3.24.0 or higher)
- Dart SDK (v3.5.0 or higher)
- Android Studio / Android SDK (API 24+)

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/aura.git
   cd aura
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if modifying generated models):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run static analysis and tests:**
   ```bash
   dart analyze
   flutter test
   ```

5. **Build release APK:**
   ```bash
   flutter build apk --release
   ```
   The generated APK will be located at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
