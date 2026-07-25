# AURA - Smart Document Intelligence System

![AURA Banner](docs/images/banner_placeholder.png)

[![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev/)
[![Version](https://img.shields.io/badge/Version-v0.5.0-green.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-purple.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)]()

## Overview

AURA is an AI-powered Offline Knowledge Management and Smart Document Intelligence System. It is designed to index, parse, search, and eventually intelligently analyze large amounts of local documentation without requiring an internet connection.

This repository holds the **v0.5.0 Production Ready Offline Search Platform**. It completes the foundation of the platform before integrating generative AI intelligence.

## Features

- **Local Document Management:** Organize, tag, and manage massive collections of local documents.
- **Advanced Parsers:** Modular parser registry supporting metadata extraction across various file types.
- **Robust Viewer System:** High-performance local document viewer.
- **Hybrid Search Orchestrator:** Concurrent, scalable search engine execution.
- **Keyword Search:** Blazing fast SQLite-backed indexed search with snippet highlighting.
- **Offline First:** 100% offline functionality. Privacy by design.

## Architecture

AURA strictly follows **Clean Architecture** principles to separate concerns into Presentation, Domain, Data, Core, and Infrastructure layers.

- **State Management:** Riverpod
- **Architecture Pattern:** MVVM (Model-View-ViewModel)
- **Data Access:** Repository Pattern
- **Dependency Injection:** GetIt

For a deep dive into the architecture, please see the [Architecture Documentation](docs/architecture/ARCHITECTURE.md).

## Technology Stack

- **Framework:** Flutter / Dart
- **Database:** SQLite (sqflite_sqlcipher)
- **State Management:** flutter_riverpod
- **Dependency Injection:** get_it
- **Routing:** go_router
- **Data Classes:** freezed, json_serializable

## Folder Structure

```
lib/
├── ai/                # Future AI Engine (Phase 6)
├── core/              # Core utilities, themes, routing, and DI
├── features/          # Application Features
│   ├── document_metadata/
│   ├── document_viewer/
│   ├── home/
│   ├── search/        # Search Subsystem
│   └── workspace/     
└── main.dart
```

## Installation & Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/aura.git
   cd aura
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run build runner (for generated code):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

## Screenshots

| Dashboard | Document Viewer | Search |
| :---: | :---: | :---: |
| ![Dashboard](docs/images/screenshot_dashboard.png) | ![Viewer](docs/images/screenshot_viewer.png) | ![Search](docs/images/screenshot_search.png) |

## Current Progress & Completed Modules

- [x] **Phase 1:** Core Architecture & Theming
- [x] **Phase 2:** Workspace & Document Management
- [x] **Phase 3:** Parsers & Metadata Extraction
- [x] **Phase 4:** High-Performance Viewer
- [x] **Phase 5:** Production Search Platform

## Roadmap (Future AI Features)

**Phase 6 (Next Milestone):** AI Intelligence Platform
- Local LLM Integration
- Vector Embeddings & Semantic Search
- Retrieval Augmented Generation (RAG)
- AI Summarization & Chat-with-Document

## Contributors

Contributions, issues, and feature requests are welcome! See the [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. (Note: MIT License is highly recommended for this project to encourage community contribution and commercial integration).
