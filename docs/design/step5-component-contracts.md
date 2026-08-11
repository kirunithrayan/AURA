# AURA Step 5 — Component Contracts (as implemented)

Status legend:
- **EXPLICIT** — directly supported by the AURA UI Migration Blueprint or committed repository.
- **COMPAT** — an existing API/behavior preserved for source compatibility.
- **APPROVED** — a decision explicitly approved for this implementation (see the Step 5 implementation prompt).
- **PROPOSED** — an implementation proposal, approved here but not stated by the Blueprint. Not to be read back as original design authority.
- **BLOCKED** — insufficient authority; deliberately not invented.

This document was written during Step 5 implementation (Aug 2026). It is **not** part of the original approved design specification; the authoritative Component Library / UX / IA spec the Blueprint references was never recovered. New components live in `lib/core/widgets/` alongside the existing ones (the committed Step 4 used in-place migration, not the Blueprint's Legacy-rename strategy), so new components are placed there for consistency — an implementation call, not a Blueprint instruction.

## Scope implemented
`AuraAppBar` (compat refactor), `AuraSectionHeader`, `AuraButton`, `AuraIconButton`, `AuraMonogram`, `AuraDocumentTile` (visual only — action contract BLOCKED), `AuraCourseTile`, `AuraCourseGridSection`, `AuraRecentSection`, `AuraEmptyState` (compat), `AuraSheet`.

## Deferred / Blocked
- **AuraDocumentTile action contract** — BLOCKED at the time of Step 5; **RESOLVED in Step 7** (see `step7-component-contracts.md`). The tile shipped tappable (whole-tile `onTap`/`onLongPress`) with no inline actions, because the interaction model was an unmade design decision rather than something to invent.

  > **CORRECTION (recorded 2026-08-10).** This entry originally read: *"The Blueprint requires one focusable node with no nested interactive elements."* **That attribution was wrong.** The migration blueprint contains no such requirement — full-text search for `focusable`, `nested interactive`, and `semantic node` returns no normative match. The blueprint's entire per-component accessibility clause is: *"Renders every variant and every state; light and dark verified; 200% text scale without clipping; correct semantics and label; reduced-motion path; contrast verified; golden test committed; zero design decisions required at the call site."* (§8, Definition of done, per component.)
  >
  > The single-merged-`Semantics`-node structure in `aura_document_tile.dart` is therefore a **Step 5 implementation decision**, not a blueprint mandate. Blocking inline actions in Step 5 was still correct — the model was genuinely undefined — but the stated reason over-claimed blueprint authority. The rest of the Step 5 decisions below are unchanged.
- **AuraContinueSection** — DEFERRED. Depends on durable reading-position persistence (Blueprint §7.4), not confirmed present.
- **Fourth section component** — DEFERRED. Identity not establishable from authoritative material. Not invented.
- **AuraReaderToolbar** — DEFERRED to Step 8 (reader/viewer subsystem, out of Step 5 scope).
- **AuraIconButton 1.75px stroke** — BLOCKED. No variable icon font asset exists (`pubspec.yaml` bundles only Inter + Source Serif 4). Material Icons are used; the stroke requirement is not silently claimed as met. Missing asset: an approved 1.75px-stroke variable icon font.

## Per-component contracts

### AuraAppBar — COMPAT refactor
- Adds `AuraAppBarVariant { root, nested, contextual }` — variant **names** EXPLICIT (§2.8); per-variant behavior PROPOSED (all three currently render the shared left-aligned, shadowless bar).
- Keeps `title`, `actions`, `leading` (COMPAT). Deprecates `centerTitle` (ignored; DS is always left-aligned).
- EXPLICIT: max 3 actions (debug `assert`), 24dp title inset (`titleSpacing: AuraSpacing.groupGap`), height 56 (`AuraLayout.appBarHeight`), title `AuraTypography.titleLg` + `contentPrimary`.

### AuraSectionHeader — PROPOSED (name EXPLICIT)
- `AuraSectionHeader({required String title, Widget? action})`.
- Title `AuraTypography.titleMd` (PROPOSED tier) + `contentPrimary`. Parent owns surrounding gaps (EXPLICIT §8). No counts/badges (EXPLICIT §11).

### AuraButton — variant values PROPOSED
- `AuraButtonVariant { primary, secondary, text }` (values APPROVED). Default `secondary` (APPROVED).
- `AuraButton({required String label, required VoidCallback? onPressed, AuraButtonVariant variant, IconData? icon})`. `onPressed == null` ⇒ disabled.
- Tokens: primary fill `actionPrimary`/`actionDisabled`, text `contentOnAction`; secondary `borderStrong` hairline + `contentPrimary`; text `actionPrimary`. Radius `sm`, min height `touchTargetMin` (48), label `AuraTypography.label`.
- One-primary-per-screen is a **screen-level** rule; not asserted in the widget (APPROVED).

### AuraIconButton — tooltip EXPLICIT
- `AuraIconButton({required IconData icon, required String tooltip, required VoidCallback? onPressed, double size = AuraIconTokens.sizeMd})`.
- Tooltip required (EXPLICIT §8), 24dp icon (EXPLICIT), 48dp target (EXPLICIT). Stroke 1.75 BLOCKED (no asset).

### AuraMonogram — PROPOSED minimal
- `AuraCourseColor { slate, sage, clay, plum, ochre, teal, rose, moss }` (EXPLICIT 8 → `courseX`).
- `AuraMonogramSize { sm, md, lg }` (PROPOSED → `AuraSpacing.s32/s40/s48`).
- `AuraMonogram({required String label, required AuraCourseColor color, AuraMonogramSize size})`.
- Fill `courseX` at `AuraOpacity.tint` (EXPLICIT "monogram tint"); glyph `courseX`; rounded square `AuraRadius.md` (PROPOSED); initials 1–2 chars from `label` (PROPOSED); type `AuraTypography.titleSm` (PROPOSED).

### AuraDocumentTile — visual only (action BLOCKED)
- `AuraDocumentTileVariant { listRow, gridCell, searchResult, recent }` — count 4 EXPLICIT, **names PROPOSED**.
- `AuraFileType { pdf, doc, txt, image, unknown }` (PROPOSED, monochrome glyph).
- `AuraDocumentTile({required String title, required AuraFileType fileType, required VoidCallback onTap, AuraDocumentTileVariant variant, String? subtitle, VoidCallback? onLongPress, bool selected})`.
- One semantic node with composed label — **PROPOSED (Step 5 implementation decision), not EXPLICIT**; see the correction under "Deferred / Blocked". The blueprint requires only "correct semantics and label". Title `titleSm`, 2-line before elide, grows at 200% (EXPLICIT §8 r9). Monochrome glyph `contentTertiary` (EXPLICIT §2.7). No file size / counts (EXPLICIT §8 r10/r11). Normalized display data, no repo access in the widget (EXPLICIT §8 r13).
- **No inline actions** as shipped in Step 5 — the action contract was BLOCKED then, and is **resolved in Step 7** by an approved optional trailing overflow action (`step7-component-contracts.md` §8).

### AuraCourseTile — 2 variant names PROPOSED
- `AuraCourseTileVariant { grid, list }` — count 2 EXPLICIT, names PROPOSED (maps existing `isListMode`).
- `AuraCourseTile({required String name, required AuraCourseColor color, required VoidCallback onTap, AuraCourseTileVariant variant, VoidCallback? onLongPress})`.
- Flat (`AuraElevation.flat` / `surfaceBackground`, EXPLICIT §4.4). Embeds `AuraMonogram` (EXPLICIT pairing). No document count (EXPLICIT §11).

### AuraCourseGridSection — name EXPLICIT
- `AuraCourseData({required String name, required AuraCourseColor color, required VoidCallback onTap, VoidCallback? onLongPress})` (PROPOSED adapter model, avoids repo access in the widget).
- `AuraCourseGridSection({required List<AuraCourseData> courses, AuraSectionHeader? header})`. 16dp gutter (`AuraSpacing.s16`, EXPLICIT §4.4). Section owns gaps.

### AuraRecentSection — name PROPOSED, concept EXPLICIT
- `AuraRecentDocumentData({required String title, required AuraFileType fileType, String? subtitle, required VoidCallback onTap, VoidCallback? onLongPress})` (PROPOSED adapter).
- `AuraRecentSection({required List<AuraRecentDocumentData> documents, AuraSectionHeader? header})`. Renders `AuraDocumentTile(variant: recent)`. Section owns gaps (`componentGap`).

### AuraSheet — variants PROPOSED
- `AuraSheetVariant { standard, sort, settings, metadata }` (names PROPOSED). Variant is declared but drives no bespoke behavior yet (deferred, documented — not fake functionality).
- `AuraSheet.show<T>({required BuildContext context, required Widget child, String? title, AuraSheetVariant variant, bool isScrollControlled})`.
- `surfaceOverlay`, top corners `AuraRadius.lg` (EXPLICIT §2.1), divider handle. Focus/inertness/back handled by `showModalBottomSheet`. Existing `AuraBottomSheet` is left intact (its one consumer is unchanged). Precise scrim-opacity token mapping deferred (default modal barrier used; no scrim-color token exists — not invented).
