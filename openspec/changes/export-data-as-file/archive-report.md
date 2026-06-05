# Archive Report — `export-data-as-file` (issue #109, PR #110)

**Status**: Archived (cycle closed)
**Archived at**: 2026-06-05
**Cycle**: SDD change `sdd/export-data-as-file`

## What shipped

The **Data Backup** page on the **Supermarket Visit** flow now offers a primary **Share backup file** action that delivers the full schema-v1 backup JSON through the native share sheet as a properly-named `.json` file. The previous clipboard-only export is retained as a secondary fallback action.

User-visible behavior change on `DataBackupPage`:

- Primary `FilledButton` **Share backup file** → writes a timestamped JSON to the temporary directory and opens the OS share sheet.
- Secondary `TextButton` **Copy JSON to clipboard** → keeps the legacy clipboard behavior as a fallback.
- New snackbar copy: *Backup file ready to share* on success; user-friendly failure copy on error.
- Both buttons stay disabled while the in-flight call resolves.

## Domain language

Per `CONTEXT.md`, the spec uses the canonical terms: **Supermarket Visit**, **Product Family**, **Catalog Product**, **Price Record**, **Shopping Need Entry**, **Measurement Unit**. The exported JSON envelope (schema v1) covers the user's **Supermarkets**, **Product Families**, **Catalog Products**, **Price Records**, and **Shopping Need Entries** — the same shape the clipboard path produced, byte-identical so existing imports keep working with no migration.

## Architecture

First time the `backup` feature gets a real layered structure:

```
lib/features/backup/
├── domain/
│   └── ports/
│       ├── clock.dart                  (Clock — Domain port)
│       ├── file_writer_port.dart       (FileWriterPort — Domain port)
│       ├── path_provider_port.dart     (PathProviderPort — Domain port)
│       └── share_gateway.dart          (ShareFile record + ShareGateway)
├── application/
│   └── backup_share_service.dart       (BackupShareService + buildBackupFileName)
├── data/
│   ├── file_writer_port_impl.dart      (FileWriterPortImpl)
│   ├── path_provider_port_impl.dart    (PathProviderPortImpl)
│   ├── share_plus_gateway.dart         (SharePlusGateway — maps ShareFile → XFile)
│   └── system_clock.dart               (SystemClock)
└── presentation/
    └── data_backup_page.dart           (modified — new primary + secondary actions)
```

Layer rule (per `docs/architecture.md` and the layer-rule unit test):

- **Domain** (`domain/`): pure Dart, no Flutter, no `dart:io`, no `share_plus`, no `path_provider`. ✓
- **Application** (`application/`): no `dart:io`, no `share_plus`, no `path_provider`. Enforced at the test-time source-text level by unit test 11 (`shareBackupJson_doesNotImportDartIoInApplicationLayer`). ✓
- **Data** (`data/`): the only layer that imports `dart:io`, `path_provider`, and `share_plus`. ✓
- **Presentation** (`presentation/`): depends on Application (for `BackupShareException`) and Domain (for ports). ✓

Wiring:

- `lib/app/app.dart` (`PriceComparatorApp`) holds an optional `BackupShareService? shareService` constructor param + `_defaultShareService()` builder.
- `lib/features/home/presentation/home_page.dart` builds the closure `(json) => shareService.shareBackupJson(json)` and passes it as `onSharePressed` to `DataBackupPage`.
- `lib/main.dart` is untouched (4-liner, calls `runApp(PriceComparatorApp())`).

## Deps added

Exactly one line in `pubspec.yaml`:

```yaml
share_plus: ^13.1.0
```

Justification: Flutter Favorite, single API for native share sheet on Android (`ACTION_SEND`) and iOS (`UIActivityViewController`); no special Android permissions; ships its own `FileProvider` via manifest merge; no `Info.plist` changes required. `path_provider: ^2.1.5` was already declared and is now its first real consumer.

`pubspec.lock` is gitignored in this project (per `.gitignore` line 4) and was NOT committed, in line with the project policy recorded in `AGENTS.md` ("Never add generated files manually").

## Test deltas

| Checkpoint | Tests | Notes |
|---|---|---|
| Baseline (pre-change on `main` at `ae0beed`) | 101 passed, 0 failed | Drift persistence + import + UI regression suite |
| After commit 2 (ports only) | 101 passed | No new tests; pure interfaces |
| After commit 3 (service + unit tests) | 112 passed, 0 failed | 11 new service tests (RED → GREEN → REFACTOR) |
| After commit 4 (data impls) | 112 passed | Trivial wrappers; no new tests |
| **Final on main at `6315c42`** | **119 passed, 0 failed** | 11 unit + 10 widget tests (6 new share + 2 copy regression + 2 import preserved) |

`flutter analyze --no-fatal-infos`: 0 issues. `dart format`: clean. CI web preview checks: both green at merge time.

## Verify verdict (preserved for the historical record)

`verify-report` (engram `#606`): **PASS WITH 1 WARNING**.

| Warning | Concern | Disposition |
|---|---|---|
| TDD discipline not observable from commit log | Commits `0ee54f3` and `0073af4` bundle implementation + tests in the SAME commit; no separate RED commit. The 11th unit test `shareBackupJson_doesNotImportDartIoInApplicationLayer` is a strong in-file process guard, but in-file, not in the commit log. | Process concern, NOT a code-correctness concern. Does NOT block archive. Documented here as a known follow-up; the change is NOT being reopened. |

## Merge and PR

- **Merge commit**: `6315c42eff24283888223081c83b6c8fedb26482`
- **PR**: <https://github.com/oriolpiera/ShoppingComparationApp/pull/110> (state: `MERGED`, merged at `2026-06-05T20:18:52Z`)
- **PR title**: `feat(backup): export data as a shareable .json file (#109)`
- **PR stats**: 17 files changed, 1221 insertions(+), 27 deletions(-), under the 400-line review budget.
- **Commits on the feature branch (5, all conventional)**:
  1. `70b5189` — `build: add share_plus ^13.1.0 dependency`
  2. `96a50b8` — `feat(backup): add Clock, PathProviderPort, ShareGateway, FileWriterPort domain ports`
  3. `0ee54f3` — `feat(backup): add BackupShareService with TDD unit tests`
  4. `504e6ad` — `feat(backup): add SystemClock, PathProviderPortImpl, SharePlusGateway, FileWriterPortImpl data implementations`
  5. `0073af4` — `feat(backup): wire share action into DataBackupPage with widget tests; keep copy as secondary`

## Follow-up

- **Issue #111**: [feat: import backup from a file (companion to #109)](https://github.com/oriolpiera/ShoppingComparationApp/issues/111) — companion import path via the OS file picker. Symmetric round-trip for the export flow shipped here. Was listed as a non-goal in `openspec/changes/export-data-as-file/design.md` to keep the export PR focused.
- iPad `sharePositionOrigin` plumbing: TODO comment in `SharePlusGateway`; track when the `ios/` folder lands.
- `compute()` for large payloads: documented as a follow-up if real users hit UI-thread jank on big backups.

## Retrospective

The cycle took the **backup** feature from a single-file presentation page to a properly layered feature with a clean Domain → Application → Data → Presentation boundary, without touching the persistence layer (`lib/features/persistence/`) or the existing import flow. The "share vs copy" UX change is conservative (primary share, secondary copy), so existing users keep their fallback. The 5-commit PR was small enough to sit well under the 400-line review budget and is fully reversible by removing three new files and one `pubspec.yaml` line. The one nit from `verify` (impl+tests in the same commit) is a process artifact of how the apply phase landed, not a correctness gap — the test code itself is high quality and the 11th test is a strong source-text layer-rule guard. Picking up issue #111 in a new SDD cycle will benefit from the Domain port pattern already established here.

## Artifact traceability (engram IDs)

| Phase | Topic key | Observation ID |
|---|---|---|
| Init | `sdd-init-somenergia/shoppingcomparationapp` | `#598` |
| Proposal | `sdd/export-data-as-file/proposal` | `#601` |
| Spec | `sdd/export-data-as-file/spec` | `#602` (8 requirements, 14 scenarios) |
| Design | `sdd/export-data-as-file/design` | `#603` |
| Tasks | `sdd/export-data-as-file/tasks` | `#604` (18 tasks) |
| Apply progress | `sdd/export-data-as-file/apply-progress` | `#605` (final state) |
| Verify report | `sdd/export-data-as-file/verify-report` | `#606` (PASS + 1 warning) |
| **Archive report** | `sdd/export-data-as-file/archive-report` | (this observation) |

## Local artifacts on main

| Path | Status |
|---|---|
| `openspec/changes/export-data-as-file/specs/backup-share/spec.md` | Present on main (delta spec, 128 lines) |
| `openspec/changes/export-data-as-file/design.md` | Present on main (design, 353 lines) |
| `openspec/changes/export-data-as-file/tasks.md` | NOT in PR (kept in engram as `#604`) |
| `openspec/changes/export-data-as-file/verify-report.md` | NOT in PR (kept in engram as `#606`) |
| `openspec/changes/export-data-as-file/archive-report.md` | This file (uncommitted; left for the user to commit if desired) |
| `openspec/changes/archive/2026-06-05-export-data-as-file/` | NOT created — project uses flat engram layout (see below) |

## OpenSpec layout — flat / no canonical home

This project uses a **flat openspec layout**: the `openspec/` tree is a PR-reviewable mirror of engram artifacts, not a source of truth. There is no `openspec/specs/{domain}/spec.md` canonical home, no `openspec/config.yaml`, and no `openspec/changes/archive/` directory. Engram is the source of truth for all SDD artifacts (per the init context in `#598` and `sdd-archive` "IF mode is `engram`: skip filesystem sync").

Per the archive instructions for this change: *"If the project uses a flat openspec layout (no canonical home for merged specs), document that and skip the copy."* — that decision is recorded here. No copy of the delta spec was made to a canonical `openspec/specs/backup-share/spec.md` location because no such canonical home exists in this project. The delta spec lives in `openspec/changes/export-data-as-file/specs/backup-share/spec.md` and in engram topic `sdd/export-data-as-file/spec` (`#602`).

## Git state at archive time

- Current branch: `main`
- HEAD: `6315c42eff24283888223081c83b6c8fedb26482` (the PR #110 merge commit)
- Working tree: clean on main after fast-forward; this `archive-report.md` is the only untracked file in the tree (left for the user to commit if desired).
- Local feature branch `issue/109-export-data-as-file` still exists and is now identical to main (safe to delete). NOT deleted by the archive step — left for the user, per archive instructions.

## Next cycle

Pick up issue #111 (file-picker import) in a new SDD cycle. The Domain port pattern established here (4 ports for share, will likely become 2 more for pick + read) is the template.
