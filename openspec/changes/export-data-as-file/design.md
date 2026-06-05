# Design: Export Backup Data as a File (issue #109)

## 1. Context Recap

The current **Export data** action on `DataBackupPage` writes the entire backup JSON to the clipboard, forcing users to paste the payload into another app and losing formatting on most platforms. This change replaces that with a native share sheet delivering the JSON as a properly-named `.json` file. Domain stays platform-independent; only the Application boundary gains a small service. Issue: #109.

## 2. Architecture Overview

```text
              Presentation                Application          Domain            Data
              ─────────────               ────────────         ──────            ────
   ┌──┐  tap  ┌──────────────┐ callback ┌──────────────────┐ uses  ┌──────────┐ impl ┌──────────────────────┐
   │UI│──────▶│DataBackupPage├─────────▶│BackupShareService├──────▶│Clock     │─────▶│SystemClock          │
   │  │       │ (presentation│ share    │  (application)   │       │PathProv. │      │PathProviderPortImpl │
   │  │       │   _onShare)  │          │  buildBackup-    │       │ShareGw   │      │SharePlusGateway     │
   └──┘       └──────────────┘          │  FileName()      │       │ShareFile │      │  (XFile mapping)    │
                ▲                       └──────────────────┘       └──────────┘      └──────────────────────┘
                │ injects
        ┌───────┴───────┐
        │   HomePage    │  reads provider from main.dart
        └───────────────┘
```

Layer boundaries preserved: Presentation knows Application (via the `onSharePressed` callback signature); Application knows Domain ports; Data implements Domain ports and is the only layer that imports `share_plus`, `path_provider`, and `dart:io`.

## 3. Domain Ports (3 new abstractions)

All three live under `lib/features/backup/domain/ports/`. They are pure Dart, no Flutter imports.

### `clock.dart`

```dart
abstract class Clock {
  DateTime nowUtc();
}
```

**Rationale**: Service must produce a deterministic, timezone-free filename; tests need a fixed clock. Wrapping `DateTime.now()` is a classic seam.

### `path_provider_port.dart`

```dart
abstract class PathProviderPort {
  Future<String> getTemporaryPath();
}
```

**Rationale**: We need a writable, platform-agnostic location for the staged `.json` file. `path_provider` is already a declared dep, but the symbol must not leak into Domain.

### `share_gateway.dart`

```dart
/// Lightweight, platform-agnostic descriptor of a file to share.
/// Mapped to share_plus's XFile in the Data layer.
typedef ShareFile = ({String path, String mimeType});

abstract class ShareGateway {
  /// Present the native share sheet. Resolves when the user dismisses it.
  /// [fileNameOverrides] is applied positionally; must align 1:1 with [files].
  Future<void> shareFiles(
    List<ShareFile> files, {
    List<String>? fileNameOverrides,
  });
}
```

**Decision (XFile vs own `ShareFile`)**: we ship an **own `ShareFile` record** in Domain and map to `XFile` inside the Data layer.

| Option | Tradeoff | Decision |
|---|---|---|
| `ShareGateway.shareFiles(List<XFile>)` | One fewer mapping, but `XFile` is a `cross_file` type (transitive of `share_plus`); couples Domain to a plugin-shaped API surface. | Reject |
| `ShareGateway.shareFiles(List<ShareFile>)` | Domain stays a pure Dart record; Data layer is the only place that imports `package:cross_file/cross_file.dart`; tests are trivial. | **Adopt** |

**Test fakes** (each ~5 lines, co-located in their respective test files):

```dart
class FakeClock implements Clock {
  FakeClock([this._now = const _epoch()]);
  DateTime _now; DateTime nowUtc() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

class FakePathProvider implements PathProviderPort {
  FakePathProvider(this.path);
  final String path;
  final List<String> calls = [];
  Future<String> getTemporaryPath() async { calls.add('getTemporaryPath'); return path; }
}

class FakeShareGateway implements ShareGateway {
  final List<List<ShareFile>> shared = [];
  final List<List<String>?> overrides = [];
  Object? errorToThrow;
  Future<void> shareFiles(List<ShareFile> f, {List<String>? o}) async {
    shared.add(f); overrides.add(o);
    if (errorToThrow != null) throw errorToThrow!;
  }
}
```

## 4. Application Service Contract

`lib/features/backup/application/backup_share_service.dart`:

```dart
class BackupShareException implements Exception {
  BackupShareException(this.userMessage, {this.cause});
  final String userMessage;
  final Object? cause;
  @override String toString() => 'BackupShareException: $userMessage';
}

String buildBackupFileName(DateTime nowUtc) {
  // yyyyMMddTHHmmssZ — compact, UTC, ASCII-safe, no colons.
  final s = '${nowUtc.year.toString().padLeft(4, '0')}'
      '${nowUtc.month.toString().padLeft(2, '0')}'
      '${nowUtc.day.toString().padLeft(2, '0')}T'
      '${nowUtc.hour.toString().padLeft(2, '0')}'
      '${nowUtc.minute.toString().padLeft(2, '0')}'
      '${nowUtc.second.toString().padLeft(2, '0')}Z';
  return 'shopping-backup-$s.json';
}

class BackupShareService {
  BackupShareService({
    required this.clock,
    required this.pathProvider,
    required this.shareGateway,
  });
  final Clock clock;
  final PathProviderPort pathProvider;
  final ShareGateway shareGateway;

  bool _inFlight = false;
  bool get isInFlight => _inFlight;

  Future<void> shareBackupJson(String json) async {
    if (_inFlight) return; // UI also disables; defense in depth.
    _inFlight = true;
    final basename = buildBackupFileName(clock.nowUtc());
    String? stagedPath;
    try {
      final dir = await pathProvider.getTemporaryPath();
      stagedPath = '$dir/$basename';
      // File system write lives in Data; service stays pure.
      // The Data impl calls this method through a thin writer port,
      // OR we accept the slight Data leak here via a FileWriter port.
      // Chosen: FileWriterPort — see Section 4a.
      throw UnimplementedError('see FileWriterPort');
    } catch (e, st) {
      throw BackupShareException(
        'Could not share the backup file. Try again or use Copy JSON.',
        cause: e,
      );
    } finally {
      _inFlight = false;
      if (stagedPath != null) {
        await _safeDelete(stagedPath);
      }
    }
  }
}
```

### 4a. FileWriterPort (fourth port, omitted from proposal)

The proposal listed 3 ports. Adding a `FileWriterPort` keeps the service **truly pure Dart** (no `dart:io`):

```dart
abstract class FileWriterPort {
  Future<void> writeString(String path, String contents);
  Future<void> deleteIfExists(String path);
}
```

Rationale: `docs/architecture.md` line 39 — "The domain layer must not depend on Flutter." The service sits in Application (which may import Dart core) but importing `dart:io` from an Application service that the widget test suite also exercises forces the test runner through extra zone plumbing. Cost: one more port + fake. Net benefit: alignment with the project's strict-layer rule.

### Error wrapping

`BackupShareException` carries a user-facing message safe to surface in a snackbar. The page's existing `_runBusyAction` shows a generic `Backup action failed: $error`; with the share path we surface the wrapped message verbatim.

### File lifecycle

```
write  →  share  →  delete (in finally)
```

Encoded as a `try/finally`; the `deleteIfExists` is best-effort (`catch (_)`) so a cleanup failure never masks the original share error.

### Concurrency

Single-flight guard via `_inFlight`. The widget also disables both buttons while `_isBusy = true` (existing pattern). Double-tap is therefore a UI no-op, not a race.

## 5. Sequence Diagram (Happy Path)

```text
User   DataBackupPage            HomePage              BackupShareService   PathProviderPort   ShareGateway   FileWriterPort
 │           │                       │                          │                   │                │              │
 │  tap      │                       │                          │                   │                │              │
 ├──────────▶│ onSharePressed(json)  │                          │                   │                │              │
 │           ├──────────────────────▶│ shareBackupJson(json)    │                   │                │              │
 │           │                       ├─────────────────────────▶│ build name        │                │              │
 │           │                       │                          │ nowUtc()          │                │              │
 │           │                       │                          ├──────────────────▶│                │              │
 │           │                       │                          │ getTemporaryPath  │                │              │
 │           │                       │                          │◀──────────────────┤                │              │
 │           │                       │                          ├─────────────────────────────────────▶│ writeString  │
 │           │                       │                          │◀─────────────────────────────────────┤              │
 │           │                       │                          ├──────────────────shareFiles─────────────────────────────────────▶│
 │           │                       │                          │◀─────────────────(user dismisses)────┤              │
 │           │                       │                          ├──────────────────deleteIfExists──────────────────────────────▶│
 │           │                       │◀───────── resolves ──────┤                   │                │              │
 │           │◀────── resolves ──────┤                          │                   │                │              │
 │ snackbar  │                       │                          │                   │                │              │
 │◀──────────┤                       │                          │                   │                │              │
```

## 6. Wiring

### `lib/app/app.dart` (composition root)

`PriceComparatorApp` gains a constructor parameter `BackupShareService? shareService` (nullable for backward compat / preview builds) and an internal default builder:

```dart
class PriceComparatorApp extends StatelessWidget {
  const PriceComparatorApp({super.key, this.shareService});
  final BackupShareService? shareService;

  @override
  Widget build(BuildContext context) {
    final resolvedService = shareService ?? _defaultShareService();
    return MaterialApp(
      title: 'Price Comparator',
      theme: ThemeData(useMaterial3: true),
      home: HomePage(shareService: resolvedService),
    );
  }

  static BackupShareService _defaultShareService() => BackupShareService(
        clock: SystemClock(),
        pathProvider: PathProviderPortImpl(),
        shareGateway: SharePlusGateway(),
        fileWriter: FileWriterPortImpl(),
      );
}
```

`main.dart` stays a 4-liner. `HomePage` reads `widget.shareService` and passes it into `DataBackupPage`. Production wiring is centralized in `app.dart`; tests inject a `FakeShareService` (a 4-line subclass with captured calls).

### `lib/features/home/presentation/home_page.dart`

- Add `final BackupShareService shareService;` field on `_HomePageState`.
- Replace line 69 `DataBackupPage(repository: repository)` with `DataBackupPage(repository: repository, shareService: shareService)`.

### `lib/features/backup/presentation/data_backup_page.dart`

| Element | Before | After |
|---|---|---|
| Import `package:flutter/services.dart` | yes (for `Clipboard`) | **yes — still needed** for the secondary `Copy JSON` action |
| Constructor | `copyToClipboard`, `onExported` | adds `shareService` (or `onSharePressed` callback) |
| Primary button | `FilledButton.icon` "Export data" (clipboard) | `FilledButton.icon` "Share backup file" |
| Secondary action | none | `TextButton` "Copy JSON to clipboard" |
| Card copy | "...copied to the clipboard so you can save it wherever you want." | "...shared as a `.json` file you can save or send to another app." |
| Snackbar | "Backup JSON copied to clipboard" | "Backup file ready to share" (and existing "copied" message for the secondary action) |

`onSharePressed` is preferred over injecting the service into the widget (widget stays testable without a real `BackupShareService`):

```dart
DataBackupPage(
  repository: repository,
  shareService: shareService, // optional; falls back to no-op in widget tests
  copyToClipboard: (j) async => Clipboard.setData(ClipboardData(text: j)),
  onExported: ...,
)
```

## 7. Testing Strategy (Detailed)

### Application unit tests — `test/features/backup/application/backup_share_service_test.dart`

Strict TDD per `docs/testing.md`. Fakes from §3. Required test names (per spec):

1. `buildBackupFileName returns compact UTC timestamp for fixed DateTime`
2. `buildBackupFileName uses only ASCII characters safe for filenames`
3. `buildBackupFileName pads single-digit fields to two digits`
4. `buildBackupFileName does not include colons or locale characters`
5. `shareBackupJson writes JSON to the path returned by PathProviderPort`
6. `shareBackupJson invokes ShareGateway with the staged file and basename override`
7. `shareBackupJson deletes the staged file after a successful share`
8. `shareBackupJson deletes the staged file when ShareGateway throws`
9. `shareBackupJson wraps path-provider errors in BackupShareException`
10. `shareBackupJson wraps share-gateway errors in BackupShareException`
11. `shareBackupJson ignores re-entrant calls while a share is in flight`

`FakeFileWriter` skeleton:

```dart
class FakeFileWriter implements FileWriterPort {
  final List<String> writes = [];
  final Map<String, String> contents = {};
  final List<String> deletes = [];
  Future<void> writeString(String p, String c) async { writes.add(p); contents[p] = c; }
  Future<void> deleteIfExists(String p) async { deletes.add(p); }
}
```

### Widget tests — `test/features/backup/presentation/data_backup_page_test.dart`

The page gains an optional `shareService` parameter; the test file injects a `FakeShareService` (4-line subclass that captures calls). Required test names:

1. `share action invokes injected shareService with the exported json`
2. `share action shows "Backup file ready to share" snackbar on success`
3. `share action surfaces BackupShareException message in snackbar`
4. `share action calls onExported after a successful share`
5. `share action disables both buttons while busy`
6. `share action does nothing when no shareService is injected (defensive default)`
7. `copy json button still works and shows the legacy snackbar`
8. `import action confirms replacement before replacing data` (existing — untouched)
9. `import action requires pasted json` (existing — untouched)
10. `page renders without crashing when only repository is supplied`

**Regression gate**: the existing `export action exposes repository backup json` test must pass unmodified. Because we keep `copyToClipboard` as the *secondary* callback, the original test path remains exercised when the widget is constructed without a `shareService` (or when the test only checks the copy snackbar).

## 8. Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Android storage permissions | Low | `share_plus` ships its own `FileProvider`; no `WRITE_EXTERNAL_STORAGE` on Android 10+. Verified by `flutter build apk`. |
| Filename collision on same-second double-tap | Low | Compact UTC + single-flight guard; the share target handles "replace?". If it ever matters, switch to `microsecondsSinceEpoch` suffix. |
| Large payloads on UI thread | Low for v1 | `AppDataBackup.toJsonString` is sync and small (<5 MB at 10k records). Document `compute()` as a follow-up. |
| iPad `sharePositionOrigin` requirement | Low | TODO comment in `SharePlusGateway`; harmless on Android. Track when iOS folder lands. |
| `share_plus` SDK floor bumping past Dart 4.0 | Low | Pin `^13.1.0`; revisit on upgrade. |
| Test hermeticity if widget imports `dart:io` | Med | Resolved by extracting `FileWriterPort` (4a) — Application stays pure Dart. |
| `BackupShareService` accidentally leaks `dart:io` via `File` | Med | Code review checklist item: grep `dart:io` in `application/` returns zero. |
| Loss of clipboard-only behaviour | Low | Secondary `TextButton` "Copy JSON" preserves the fallback. |

## 9. Rollback

Revert the `share_plus` line in `pubspec.yaml` and run `flutter pub get`. Delete the four new `lib/features/backup/{domain/ports,application,data}/` files (interface, service, two impls). Revert the constructor + button changes in `data_backup_page.dart` and the `shareService` plumbing in `home_page.dart` and `app.dart`. No data migration; the JSON payload format is unchanged, so the clipboard fallback is fully restored.

## 10. PR Slicing & Commits

**Single PR** — ~200 LoC new code + ~80 LoC tests. Under the 400-line review budget. No chained PRs needed.

Commit plan (conventional commits, each green on its own):

1. `build: add share_plus ^13.1.0 dependency`
2. `feat(backup): add Clock, PathProviderPort, ShareGateway, FileWriterPort domain ports`
3. `feat(backup): add BackupShareService with failing-first unit tests (TDD)`
4. `feat(backup): add SystemClock, PathProviderPortImpl, SharePlusGateway, FileWriterPortImpl data implementations`
5. `feat(backup): wire share action into DataBackupPage with widget tests; keep copy as secondary`

Per project rules: branch off a fresh `Issue -> PR` flow (AGENTS.md §"GitHub workflow"); do not push to `main` directly.
