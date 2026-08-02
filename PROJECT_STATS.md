# Project Statistics

Measured at the v0.6.0 tag. Regenerate with the commands noted below rather than
editing by hand.

## Codebase Size

| Metric | Value |
| :--- | ---: |
| Dart files (total) | 382 |
| Dart files (excluding generated `.g.dart` / `.freezed.dart`) | 367 |
| Lines of Dart (total) | 21,871 |
| Lines of Dart (excluding generated) | 19,475 |

```bash
find lib -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l
```

## Quality Gates

| Metric | Value |
| :--- | ---: |
| Analyzer errors | 0 |
| Analyzer warnings | 14 |
| Analyzer info-level lints | 15 |
| Tests passing | 31 / 31 |
| Test files | 12 |
| Lines of test code | 884 |
| Approximate line coverage | ~3% |

Coverage is low and concentrated in search ranking, document chunking, and text
preprocessing. Widget and integration tests are a known gap tracked in
[TECH_DEBT.md](TECH_DEBT.md).

## Architecture Components

| Component | Count |
| :--- | ---: |
| GetIt registrations | 88 |
| Screens | 15 |
| ViewModels | 12 |
| Database tables | 9 |

## Implementation Status

Not every registered component is functional. The following are placeholders
that throw `UnimplementedError` or return fixed values, and are counted above
only as scaffolding:

- `StubVectorStore`, `StubChunkingService`, `StubInferenceEngine`,
  `StubPromptBuilder`, `StubEmbeddingEngine`
- `BatteryService`, `ThermalService`, `MemoryService`
- `OnnxEmbeddingService` (throws `EmbeddingModelUnavailableException` until a
  model and tokenizer are added)

See the Current Status table in [README.md](README.md) for the full breakdown.
