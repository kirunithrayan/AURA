# Project Statistics

Measured on 2026-08-03, after v0.6.0; codebase-size and test figures
re-measured 2026-08-12 following the Steps 0–9 UI migration and subsequent
accessibility cleanup. Regenerate with the commands noted below rather than
editing by hand.

## Codebase Size

| Metric | Value |
| :--- | ---: |
| Dart files (total) | 382 |
| Dart files (excluding generated `.g.dart` / `.freezed.dart`) | 373 |
| Lines of Dart (total) | 22,584 |
| Lines of Dart (excluding generated) | 21,206 |

At the v0.6.0 accuracy release this table read 360 total / 351 excluding
generated (20,474 / 19,096 lines), itself down from a pre-release 382 files /
21,871 lines after an unused `Abstract*` AI abstraction layer with no
consumers was deleted — see [TECH_DEBT.md](TECH_DEBT.md). The current figures
above are higher again because they include the Steps 0–9 design-system/UI
migration and the accessibility work that followed it — growth, not a
regression of that cleanup.

```bash
find lib -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l
```

## Quality Gates

| Metric | Value |
| :--- | ---: |
| Analyzer errors | 0 |
| Analyzer warnings | 0 |
| Analyzer info-level lints | 14 |
| Tests passing | 230 / 230 |
| Test files | 31 |
| Lines of test code | ~5,020 |
| Approximate line coverage | ~3% (v0.6.0 baseline; not remeasured since) |

Coverage was concentrated in search ranking, document chunking, and text
preprocessing at the v0.6.0 baseline. Widget-test coverage has since grown
substantially — onboarding, reader auto-hide, bottom-toolbar and page-counter
accessibility, and Explain with AURA all have dedicated widget tests — but a
current line-coverage percentage has not been computed, and integration/
full-flow and on-device testing remain limited. Tracked in
[TECH_DEBT.md](TECH_DEBT.md).

## Architecture Components

| Component | Count |
| :--- | ---: |
| GetIt registrations | 82 |
| Screens | 15 |
| ViewModels | 12 |
| Database tables | 15 |

## Implementation Status

Not every registered component is functional. The following are placeholders
that throw `UnimplementedError` or return fixed values, and are counted above
only as scaffolding:

- `BatteryService`, `ThermalService`, `MemoryService`
- `OnnxEmbeddingService` (throws `EmbeddingModelUnavailableException` until a
  model and tokenizer are added)

See the Current Status table in [README.md](README.md) for the full breakdown.
