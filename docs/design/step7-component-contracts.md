# AURA Step 7 — Component & Screen Contracts (authoritative)

## 1. Purpose

This document is the authoritative contract for Step 7 of the AURA UI migration
(Course, Search, Settings). It exists because the migration blueprint names the
Step 7 components but never specifies them: the approved Component Library / UX /
IA specification it references was never saved to disk and is unrecoverable
(searched: full blueprint text, all repository documentation, complete git history
across every ref/tag/stash, and all project artifacts).

The decisions below were drafted from that gap and **explicitly approved on
2026-08-10**. Implementation follows this document; anything absent from it is not
authorised.

## 2. Authority hierarchy

Tags used throughout, strongest first:

- `[BLUEPRINT]` — stated in the AURA UI Migration Blueprint (`~/Documents/mad plan/AURA-UI-Migration-Blueprint.pdf`).
- `[REPOSITORY-VERIFIED]` — proven by committed code, cited by file.
- `[APPROVED]` — a design decision explicitly approved for Step 7 on 2026-08-10. Implementable.
- `[PROPOSED]` — drafted but **not** approved. Not implementable.
- `[UNDEFINED]` — no authoritative source. Must not be invented.
- `[DESIGN-SYSTEM-GAP]` — needs a token/system decision before it can be expressed.
- `[DEFERRED]` — deliberately out of Step 7.

`[APPROVED]` decisions are authority for Step 7 only; they do not claim blueprint
backing. Nothing here may be read back as `[BLUEPRINT]`.

## 3. Scope

`[BLUEPRINT]` Step 7, in full: *"Migrate `workspace_detail_screen`, `search_screen`,
`settings_screen`. Remove `filter_section`, `statistics_section`,
`workspace_insights_dashboard`. Verify: per-screen goldens; search behavior
unchanged; the fixes committed in `b39261e` still hold. Risk: medium — search is the
most behavior-sensitive."*

**In scope:** the three screens; the three deletions; four new components
(`AuraSearchField`, `AuraSuggestionList`, `AuraConfirmDialog`, `AuraPromptDialog`);
the `AuraDocumentTile` action model; Course pins; the Course app bar.

**Out of scope:** reader/viewer (Step 8), legacy sweep (Step 9), the Library screen,
database/DI/routing architecture, search engine internals.

## 4. AuraSearchField

`[BLUEPRINT]` §3.2/§4.3: `aura_search_bar` + `search_bar_widget` → **`AuraSearchField` ×2 variants**, "Consolidated".
`[BLUEPRINT]` §2.8: "Consolidate to one, rebind to tokens, **remove any mode selector**."

`[APPROVED]` Variants:

```dart
enum AuraSearchFieldVariant {
  /// Editable. Owns a cursor and keyboard. Replaces SearchBarWidget on Search.
  input,
  /// Read-only entry affordance; the whole field is one tappable node that
  /// navigates into Search.
  launcher,
}
```

`[APPROVED]` API:

```dart
AuraSearchField({
  Key? key,
  AuraSearchFieldVariant variant = AuraSearchFieldVariant.input,
  TextEditingController? controller,
  FocusNode? focusNode,
  String hintText = 'Search',
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  VoidCallback? onTap,      // required in practice for `launcher`
  VoidCallback? onClear,
  bool autofocus = false,
  bool enabled = true,
})
```

`[REPOSITORY-VERIFIED]` **Addendum (added during implementation).** `focusNode` was
not in the original written contract but is required to preserve the existing
Search behaviour: the screen unfocuses on submit, refocuses on clear, and uses the
focus state to decide whether suggestions are visible. Without it that behaviour
cannot be reproduced. No other parameter was added.

`[REPOSITORY-VERIFIED]` **Hard constraint:** `AuraAppBar.title` is a `String`
(`lib/core/widgets/aura_app_bar.dart`), so a search field **cannot** be placed inside
the committed app bar. `[APPROVED]` The field sits **below** the app bar. Changing
`AuraAppBar`'s contract is `[DEFERRED]`.

`[APPROVED]` Structure: leading `Icons.search` at `AuraIconTokens.sizeSm`
(`ExcludeSemantics`, never interactive); text in `AuraTypography.body`; trailing
clear `AuraIconButton` shown only when the field is non-empty and `variant == input`.
`launcher` renders the hint text only and exposes one tappable semantic node.

`[APPROVED]` No mode selector, no filter affordance, no sort affordance.
`[UNDEFINED]` `isLoading` / `errorText` presentation — not specified, not built.

## 5. AuraSuggestionList

`[BLUEPRINT]` §4.3: `AuraSearchBar + search_bar_widget → AuraSearchField + AuraSuggestionList`.

`[REPOSITORY-VERIFIED]` The suggestion model already exists and is reused unchanged
(`lib/features/search/domain/entities/search_suggestion.dart`):

```dart
enum SuggestionType { history, frequent, ai }
class SearchSuggestion { final String text; final SuggestionType type; }
```

`[APPROVED]` The component consumes `SearchSuggestion` directly. **No new enum is
introduced** — the repository's `SuggestionType` is the contract.

`[APPROVED]` API:

```dart
AuraSuggestionList({
  Key? key,
  required List<SearchSuggestion> suggestions,
  required ValueChanged<SearchSuggestion> onSelected,
  bool isLoading = false,
})
```

`[APPROVED]` Each row: leading glyph by `SuggestionType` (history → `Icons.history`,
frequent → `Icons.trending_up`, ai → `Icons.auto_awesome`), monochrome
`contentTertiary`; label in `AuraTypography.body`; one semantic node per row;
minimum height `AuraLayout.touchTargetMin`.

`[APPROVED]` Preserved unchanged: the existing suggestions provider/service, its
ranking, and its data path. `[UNDEFINED]` — maximum item count, history-clearing, and
per-row delete. Not invented, not built.

## 6. AuraConfirmDialog

`[BLUEPRINT]` §3.2: the four legacy dialogs collapse to `AuraConfirmDialog` + `AuraPromptDialog`.

`[APPROVED]` API:

```dart
class AuraConfirmDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    String? message,
    String cancelLabel = 'Cancel',
    bool destructive = false,
  });
}
```

Returns `true` on confirm, `false` on cancel, `null` on barrier/system-back dismissal;
callers treat `null` and `false` alike.

`[APPROVED]` Non-destructive treatment: confirm = `AuraButton(primary)`, cancel =
`AuraButton(text)`. `[BLUEPRINT]` §8 r7 ("one primary button per screen") — a modal is
the screen while it is up, so exactly one `primary` is correct.

`[DESIGN-SYSTEM-GAP]` **Destructive treatment.** `[REPOSITORY-VERIFIED]` the existing
`DeleteConfirmationDialog` renders its confirm as a `FilledButton` filled with
`colorScheme.error`, which `[REPOSITORY-VERIFIED]` maps DIRECT to
`AuraColors.statusError` (`lib/core/theme/app_theme.dart`, Step 3). The colour is
therefore approved and already shipping — but `AuraButton` exposes only
`primary`/`secondary`/`text` and no colour override, so **the destructive treatment
cannot be expressed through the design system as committed**. Per the Step 7 approval,
no new token and no new `AuraButton` variant may be created here.

`[DEFERRED]` Consequently `delete_confirmation_dialog.dart` is **not** migrated in
Step 7; it keeps its current behaviour and appearance. `AuraConfirmDialog` ships with
`destructive` in its signature, and until the gap is resolved `destructive: true`
affects wording/semantics only. This deliberately avoids a visual regression on the
only destructive confirmation in the app.

## 7. AuraPromptDialog

`[APPROVED]` A generic **single-input** modal, presented with `showDialog`
(`[BLUEPRINT]` §3.2 lists Dialogs and Sheets as separate families, so it must not be
built on `AuraSheet`).

`[APPROVED]` Must support: title; optional message; one text input (initial value,
hint, obscured + visibility toggle, keyboard type); a validation hook; submit;
cancel; **async submission**; error state; in-flight/busy state; and preservation of
the existing empty-input no-op.

```dart
AuraPromptDialog.show<T>({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  required Future<T?> Function(String value) onSubmit,
  String? message,
  String? initialValue,
  String? hintText,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String value)? validator, // null = accept; '' = reject silently
  String cancelLabel = 'Cancel',
});
```

`[APPROVED]` Migratable consumer in Step 7: **`JumpToPageDialog`**
(`[REPOSITORY-VERIFIED]` numeric keyboard, initial value = current page, `int.tryParse`
+ range validation, submit-on-enter) — expressible with no behaviour loss.

`[DEFERRED]` **`AiKeyDialog` is not migrated in Step 7.** `[REPOSITORY-VERIFIED]` it
carries a third, destructive "Remove" action rendered in `colorScheme.error`, which
hits the same `[DESIGN-SYSTEM-GAP]` as §6. It gates the Gemini demo, so it keeps its
current implementation and behaviour verbatim.

`[DEFERRED]` **`EditWorkspaceDialog` is not migrated** — it has two fields (name +
description) and a single-input contract cannot absorb it. A two-field contract is
`[UNDEFINED]`.

## 8. AuraDocumentTile action model

`[APPROVED]` **Option A3 — optional trailing overflow action.**

- Tapping the tile opens the document (unchanged).
- An optional trailing overflow `AuraIconButton` opens an `AuraSheet` action surface.
- Pin/unpin lives in that action surface.
- Long-press is **not** the only action mechanism.
- **No** persistent pin/state badge on the tile (`[BLUEPRINT]` §8 r11).
- Two-line title behaviour preserved (`[BLUEPRINT]` §8 r9).

`[APPROVED]` API addition — one optional parameter, nothing else changes:

```dart
AuraDocumentTile({
  ...existing parameters unchanged...,
  VoidCallback? onMoreActions,   // null (default) => no trailing control rendered
})
```

`[APPROVED]` Because the parameter defaults to `null`, tiles that pass nothing render
exactly as committed. `[REPOSITORY-VERIFIED]` consequence: Library Recent tiles and
the Step 5 component specimens are unchanged, so **no committed golden regenerates**.

`[APPROVED]` Semantics: when `onMoreActions != null` the tile exposes **two** nodes —
the tile ("Open {title}") and the overflow button ("More actions for {title}") — via
`explicitChildNodes`. This satisfies `[BLUEPRINT]` §8's only accessibility requirement,
"correct semantics and label". See §15 and the correction in
`step5-component-contracts.md`: the single-node rule was never blueprint authority.

`[APPROVED]` The overflow control is an `AuraIconButton` and therefore carries a
tooltip (`[BLUEPRINT]` §8 r8, asserted at construction) and a 48dp target.

`[APPROVED]` Variant support: `listRow`, `searchResult`, `recent`.
`[DEFERRED]` `gridCell` — its `Column` layout has no trailing slot, and
`[REPOSITORY-VERIFIED]` `file_grid_tile.dart` has zero consumers, so no surface needs
it. `onMoreActions` is ignored for `gridCell`.

`[APPROVED]` The action surface uses the committed `AuraSheet.show(...)` with
`AuraSheetVariant.metadata` and rows built from `AuraButton(variant: text, icon: ...)`.
`[REPOSITORY-VERIFIED]` no `AuraSheet` API change is required.

`[APPROVED]` Actions offered: **pin/unpin only**. `[BLUEPRINT]` §2.11/§3.1 defer
`ai_insights/**` from v1.0, so the legacy inline "insights" action is removed and not
re-created. No other document action is invented.

## 9. Course pins

`[BLUEPRINT]` §4.3, the only sentence about pins: *"`PinnedDocumentsSection` | Pins move inside Course | Section retired"*.

`[APPROVED]` **Option B — pins are a Course section, composed at the screen.**

- When pinned files exist: `AuraSectionHeader('Pinned')` followed by
  `AuraDocumentTile(variant: listRow, onMoreActions: ...)` rows.
- Then `AuraSpacing.sectionGap`, then `AuraSectionHeader('Documents')` and the full
  list. `[BLUEPRINT]` §8 r11 — the existing `'All Documents (N)'` count is removed.
- Inter-tile gaps use `AuraSpacing.componentGap`, owned by the screen
  (`[BLUEPRINT]` §8 r6, matching the committed `AuraRecentSection` pattern).
- Unpin is reached through the §8 action surface.

`[APPROVED]` **No new component.** No `AuraPinnedSection` is created; screen
composition is preferred. (An `AuraPinnedSection` is a plausible identity for the
deferred "fourth section", but that is arithmetic inference, not authority, and is not
built on.)

`[APPROVED]` **No data-layer change.** `workspace_files.is_pinned`, `PinDocument`/
`UnpinDocument`, `getPinnedDocuments`, and `PinnedDocumentsService` are untouched
(`[BLUEPRINT]` §8 r14, "preserve architecture").

`[APPROVED]` `pinned_documents_section.dart` is retired **only after** verifying its
consumers (`[REPOSITORY-VERIFIED]` sole consumer today: `workspace_detail_screen.dart`)
and migrating its behaviour faithfully.

`[APPROVED]` Search results drop the passive `isPinned`/`isFavorite` indicators
(`[REPOSITORY-VERIFIED]` currently hardcoded `Colors.blue`/`Colors.amber`, violating
`[BLUEPRINT]` §8 r1). Pin state remains visible where it is meaningful — grouped at the
top of Course.

## 10. Course app bar

`[BLUEPRINT]` §4.3: `ImportFab → AuraIconButton in app bar`, "No FAB in approved spec".
`[REPOSITORY-VERIFIED]` `ImportFab` is used by `workspace_detail_screen.dart`, so this
mapping is a **Course** mapping.

`[REPOSITORY-VERIFIED]` **Forced collision:** Course already has three actions
(Ask AURA, Knowledge Graph, Sort). Adding Import makes four and trips the max-three
assert in `aura_app_bar.dart`.

`[APPROVED]` Resolution — keep exactly three:

| Action | Decision |
|---|---|
| Ask AURA | KEEP |
| Sort | KEEP (migrated to `AuraSheet(variant: sort)`; `[BLUEPRINT]` §3.2 maps `file_sort_sheet` into `AuraSheet ×variants`) |
| Import | ADD (replaces the FAB) |
| Knowledge Graph | **REMOVE the Course entry point** |

`[APPROVED]` Rationale: `[BLUEPRINT]` §2.11 defers `ai/knowledge_graph/**` from v1.0.
`[APPROVED]` Only the app-bar entry point is removed. The screen, route, and all
knowledge-graph infrastructure are left intact — `[BLUEPRINT]` schedules unrouting for
Step 9, and "deferred is not deleted".

## 11. Search composition

`[APPROVED]` Target composition:

1. `AuraAppBar(variant: nested, title: 'Search')` — `[REPOSITORY-VERIFIED]` the screen
   has **no app bar today** and therefore no back affordance on a pushed route.
2. `AuraSearchField(variant: input)` below the app bar.
3. `AuraSuggestionList` while suggestions are showing.
4. Results as `AuraDocumentTile(variant: searchResult)`.
5. Empty / no-results via `AuraEmptyState`; loading and error states exactly as the
   existing `SearchViewModel` already exposes them.

`[BLUEPRINT]` Removed: `FilterSection` ("Approved search has no filters") and
`StatisticsSection` ("Statistics prohibited"). `[REPOSITORY-VERIFIED]` each has exactly
one consumer, and the statistics timing figure is a hardcoded mock
(`Duration(milliseconds: 450)` with an in-source comment admitting it), so nothing real
is lost.

`[APPROVED]` Preserved unchanged: the search engines, `SearchViewModel`, search
history, suggestions, `SearchCache`, query normalisation, the existing
`SemanticsService` announcements, and result navigation. `[APPROVED]` No search
architecture change. `[REPOSITORY-VERIFIED]` `SearchViewModel.updateFilter` simply
becomes unused; the filter defaults to empty and query building is unaffected.

## 12. Settings composition

`[APPROVED]` A conservative 1:1 migration. `[REPOSITORY-VERIFIED]` today: one header
card, three titled sections, six rows (four static, two interactive), no viewmodel, no
theme or reading controls, and exactly one persisted value (the Gemini key).

`[APPROVED]`

- All three sections and all six rows preserved, in order. Nothing added, nothing removed.
- Section titles rendered with `AuraSectionHeader`.
- Rows restyled to tokens: `AuraTypography.body` / `caption`, `contentPrimary` /
  `contentSecondary`, `surfaceRaised`, `AuraRadius.md`, `AuraSpacing.componentPadding`.
  Hardcoded `Colors.green` status glyphs move to `statusSuccess`; the hardcoded radius
  and avatar size move to tokens.
- The Gemini API-key row keeps its exact behaviour and continues to open the existing
  `AiKeyDialog` (see §7).
- Existing navigation (diagnostics route) unchanged.

`[APPROVED]` No new settings, preferences, theme controls, reading controls, or AI
settings are invented.

## 13. Library compatibility exception

`[APPROVED]` The Step 6 temporary exception — Search, Create Workspace, and Settings
actions in the Library app bar — **is retained through Step 7, unchanged.**

`[BLUEPRINT]` Step 7's text never mentions the Library, `home_screen.dart`, or any
app-bar action, so removal is not required. `[UNDEFINED]` The blueprint contains no
information-architecture or navigation section at all — no bottom nav, drawer, tab
shell, or root-destination list — so no replacement placement exists to migrate to.
`[BLUEPRINT]` §5.2 additionally requires routes stay reachable.

`[DEFERRED]` Final placement of these three entry points, pending an IA decision.

## 14. Token mappings

All Step 7 work resolves against committed tokens. No new token is created.

| Surface | Token |
|---|---|
| Screen background | `colors.surfaceBackground` |
| Raised rows / fields / sheets | `colors.surfaceRaised`, `colors.surfaceOverlay` |
| Borders / dividers | `colors.borderDefault`, `colors.divider`, `AuraBorders.hairline` |
| Primary / disabled action | `colors.actionPrimary`, `colors.actionDisabled`, `colors.contentOnAction` |
| Text | `contentPrimary` / `contentSecondary` / `contentTertiary` / `contentDisabled` |
| Status glyphs | `statusSuccess`, `statusError` |
| Selection | `colors.selectionBackground` |
| Type | `AuraTypography.titleLg/titleMd/titleSm/body/label/caption` |
| Spacing | `AuraSpacing.screenMargin/sectionGap/groupGap/componentPadding/componentGap/gapTight` |
| Radius | `AuraRadius.sm/md/lg` |
| Icons | `AuraIconTokens.sizeSm/sizeMd` |
| Targets / chrome | `AuraLayout.touchTargetMin`, `AuraLayout.appBarHeight` |
| Motion | `AuraMotion.standard` (≤300ms ceiling) |

## 15. Accessibility requirements

`[BLUEPRINT]` §8, definition of done, per component: *"Renders every variant and every
state; light and dark verified; 200% text scale without clipping; correct semantics and
label; reduced-motion path; contrast verified; golden test committed; zero design
decisions required at the call site."* This is the **complete** accessibility authority;
no stricter rule may be attributed to the blueprint.

`[APPROVED]` Step 7 obligations:

- Minimum 48dp targets (`AuraLayout.touchTargetMin`) on every interactive element,
  including suggestion rows and the tile overflow control.
- Every icon-only button carries a tooltip (`[BLUEPRINT]` §8 r8).
- `AuraDocumentTile` with an overflow action exposes two correctly-labelled nodes (§8).
- 200% text scale without clipping on all three screens; the tile's two-line title must
  still wrap before eliding with the overflow control present.
- No information conveyed by colour alone (drives the removal of the passive
  pin/favourite colour indicators in search results).
- `[APPROVED]` The existing search `SemanticsService` announcements are preserved verbatim.
- `[REPOSITORY-VERIFIED]` Pre-existing gap to fix opportunistically: `AuraDocumentTile`'s
  `onLongPress` currently has no screen-reader affordance.

## 16. Golden requirements

`[BLUEPRINT]` Step 7 requires per-screen goldens. `[APPROVED]` Minimum matrix, using the
existing Step 2 harness only — no new dependency, no new font loader:

| Surface | States | Why |
|---|---|---|
| Course | populated (pinned + documents), empty; light + dark; 200% | pins section and app-bar change are the largest visual deltas |
| Search | suggestions, results, no-results; light + dark; 200% | most behavior-sensitive screen |
| Settings | default, key-set vs key-unset; light + dark; 200% | key state is the only dynamic content |
| AuraSearchField | input (empty, filled), launcher; light + dark; 200% | two approved variants |
| AuraSuggestionList | populated (all three kinds); light + dark; 200% | one row per `SuggestionType` |
| AuraConfirmDialog | default; light + dark | destructive path deferred, so not captured |
| AuraPromptDialog | default, error, busy; light + dark | three approved states |
| AuraDocumentTile | listRow **with** overflow; light + dark; 200% | new optional control |

`[REPOSITORY-VERIFIED]` No existing golden is expected to change: `onMoreActions`
defaults to `null`, so the Step 5 tile specimens and the Step 6 Library baselines render
identically. Any baseline that does change must be investigated, not regenerated.

## 17. Migration compatibility

| New | Replaces | Consumers | Note |
|---|---|---|---|
| `AuraSearchField` | `aura_search_bar` (0 consumers), `search_bar_widget` (1) | Search | core `aura_search_bar` is already dead |
| `AuraSuggestionList` | `suggestion_section` (1) | Search | provider unchanged |
| `AuraConfirmDialog` | — | new | `delete_confirmation_dialog` migration `[DEFERRED]` (§6) |
| `AuraPromptDialog` | `jump_to_page_dialog` (1) | Viewer | `ai_key_dialog`, `edit_workspace_dialog` `[DEFERRED]` (§7) |
| `AuraDocumentTile` + overflow | `file_list_tile` (Course), `search_result_card` (Search) | Course, Search | `file_grid_tile` is dead code |

`[APPROVED]` Deletion candidates, each verified single-consumer: `filter_section`,
`statistics_section`, `workspace_insights_dashboard`, `pinned_documents_section`.
`[DEFERRED]` `file_grid_tile.dart` (dead) — Step 9 sweep.

## 18. Explicitly deferred

- `delete_confirmation_dialog` migration — blocked by the destructive gap (§6).
- `ai_key_dialog` migration — destructive tertiary action; protects the Gemini flow (§7).
- `edit_workspace_dialog` — two fields; contract `[UNDEFINED]` (§7).
- `gridCell` overflow placement — no consumer (§8).
- Library app-bar exception resolution — no IA authority (§13).
- Knowledge-graph unrouting and dead-code removal — Step 9 (§10).
- `AuraAppBar` title-as-widget — out of scope (§4).
- `AuraContinueSection`, the fourth section component, `AuraReaderToolbar` — unchanged from Step 5.

## 19. Design-system gaps

1. `[DESIGN-SYSTEM-GAP]` **Destructive action treatment.** `statusError` exists and is
   already used, but `AuraButton` cannot express it (no destructive variant, no colour
   override). Blocks §6 and part of §7. Needs either an approved `AuraButton` variant or
   an approved destructive role. **No token invented.**
2. `[DESIGN-SYSTEM-GAP]` **Scrim colour.** `AuraOpacity.scrim` (0.32) exists but there is
   no scrim *colour* role; `AuraSheet` uses the framework default barrier. Pre-existing;
   §8 increases sheet usage and therefore its visibility.
3. `[DESIGN-SYSTEM-GAP]` **1.75px icon stroke.** `[BLUEPRINT]` §2.7 requires it; no
   variable icon font is bundled. Pre-existing; inherited by the new overflow and
   suggestion glyphs.
4. `[DESIGN-SYSTEM-GAP]` **Suggestion animation.** The existing 300ms `AnimatedSwitcher`
   exceeds `AuraMotion`'s 280ms ceiling. Either adopt `AuraMotion.deliberate` or record
   the deviation.

## 20. Implementation order

1. Build the four components + their goldens — mutually independent, parallelisable.
2. Add `onMoreActions` to `AuraDocumentTile` + the shared document action sheet.
3. **Course** — highest risk: app-bar recomposition, pins section, tile actions, deletions.
4. **Search** — most behavior-sensitive: deletions, field/suggestions swap, app bar.
5. **Settings** — lowest risk: 1:1 token restyle.
6. Per-screen goldens.
7. Full validation: `flutter analyze` (14-info baseline), `flutter test`,
   `flutter test test/golden`, `flutter build bundle`.
8. Commit — one Step 7 commit, or one per screen. Never stage `.gitignore`.

Settings is independent of everything and may be done at any point.
