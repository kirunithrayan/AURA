# Project Statistics

Measured on 2026-08-03, after v0.6.0. Regenerate with the commands noted below
rather than editing by hand.

## Codebase Size

| Metric | Value |
| :--- | ---: |
| Dart files (total) | 360 |
| Dart files (excluding generated `.g.dart` / `.freezed.dart`) | 351 |
| Lines of Dart (total) | 20,474 |
| Lines of Dart (excluding generated) | 19,096 |

Down from 382 files / 21,871 lines at v0.6.0: an unused `Abstract*` AI
abstraction layer with no consumers was deleted (see [TECH_DEBT.md](TECH_DEBT.md)).

```bash
find lib -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l
```

## Quality Gates

| Metric | Value |
| :--- | ---: |
| Analyzer errors | 0 |
| Analyzer warnings | 0 |
| Analyzer info-level lints | 14 |
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
| GetIt registrations | 82 |
| Screens | 15 |
| ViewModels | 12 |
| Database tables | 9 |

## Implementation Status

Not every registered component is functional. The following are placeholders
that throw `UnimplementedError` or return fixed values, and are counted above
only as scaffolding:

- `BatteryService`, `ThermalService`, `MemoryService`
- `OnnxEmbeddingService` (throws `EmbeddingModelUnavailableException` until a
  model and tokenizer are added)

See the Current Status table in [README.md](README.md) for the full breakdown.
