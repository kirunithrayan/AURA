# AURA v0.6.0 — Release Notes

**Theme: make the codebase tell the truth.**

v0.6.0 is a correction release. The previous tag was labelled v1.0.0 and its
notes described several features as complete that were in fact placeholders.
This release removes those claims, replaces the placeholder behaviour that was
masking real failures, and makes the one AI path that can work actually work.

There is no new user-facing feature here. The value is that what the app reports
about itself is now accurate.

---

## Corrected: version and status

The project is **v0.6.0, in development** — not v1.0.0. The prior tag was
premature: it shipped a Code of Conduct, Security Policy, and "1.0" release notes
against a build whose Create Workspace button was a no-op.

---

## Fixed

### Create Workspace saved nothing
The Save button's `onPressed` was an empty callback. Workspace creation is now
wired to `WorkspaceListViewModel.addWorkspace()`, with validation, a progress
indicator, error surfacing, and navigation on success.

### Fabricated embeddings were poisoning search
`OnnxEmbeddingService` returned synthetic vectors built from `text.hashCode`.
Because every component was non-negative and followed the same ramp, **any two
unrelated documents scored ~0.75 cosine similarity** — above the 0.55 relevance
threshold. Semantic search therefore matched everything and fed pure noise into
hybrid ranking, degrading the keyword engine that actually worked.

It now throws `EmbeddingModelUnavailableException`. `SemanticSearchEngine`
already handled embedding failure by returning no results, so hybrid search
degrades cleanly to keyword-only — which is both honest and measurably better.

### Missing API key silently returned placeholder text
`AiProviderFactoryImpl` fell back to `StubLocalProvider` whenever the Gemini key
was absent, so "Ask AURA" answered with the literal string
`"This is a stub response from StubLocalProvider."` — indistinguishable from a
model response to anyone demoing the app.

The fallback is removed. A missing key now raises `MissingApiKeyException` and
the UI directs the user to Settings. `StubLocalProvider` is reachable only via an
explicit `providerName: 'stub'` config and is documented as a test fixture.

### API key was compile-time only
The key came from `String.fromEnvironment('GEMINI_API_KEY')`, which bakes a
credential into the binary and is empty in any normal build.

Added `AiKeyStore` / `SecureAiKeyStore`, backed by `flutter_secure_storage`
(Android Keystore). The key is entered by the user in **Settings → AI Engine
Configuration**, read at the point of use, and never compiled in.

---

## Changed

- **Settings** shows real AI configuration state — whether a key is present, and
  an explicit data-handling notice that Ask AURA transmits excerpts to Google.
- **`importFile(path)`** no longer carries a stray comment containing an
  assistant's internal monologue. It documents why the path-based signature is
  unsupported and points to the picker flow.
- **Dropped `dartz`.** The project depended on both `dartz` and `fpdart` for the
  same `Either` type. Five files migrated to `fpdart`; `dartz` removed.
- **Documentation rewritten.** `README.md` now carries an explicit
  Working / Not working yet table. `PROJECT_STATS.md` reports measured figures
  (the prior version understated file count by ~30%).

---

## Removed

- `RELEASE_NOTES_v1.0.0.md` and `GITHUB_RELEASE.md`. Their claims did not survive
  verification: they reported a built APK that did not exist, "31/31 tests
  passing" while 2 failed, "0 compilation errors" against 6, and "real-time
  thermal, memory and battery monitoring" backed by three functions returning
  constants.
- Three untracked scratch files left over from an automated debugging session
  (`test/ui_test.dart`, `test/viewmodel_test.dart`, `test_workspace.dart`).

---

## Known limitations

Unchanged in this release, and now documented rather than implied away:

- On-device embeddings and semantic search are **not functional**. Requires a
  bundled MiniLM model and a Dart WordPiece tokenizer.
- Ask AURA requires a user-supplied Gemini API key and **sends excerpts to
  Google**. AURA is not a fully offline application today.
- `BatteryService`, `ThermalService`, and `MemoryService` return fixed values.
- The knowledge graph is a UI scaffold.
- Test coverage is ~3%; there are no widget or integration tests.

---

## Verification

```
flutter analyze   →  0 errors, 14 warnings, 15 info
flutter test      →  31/31 passing
```

Both figures were produced by running the commands, not by assertion.
