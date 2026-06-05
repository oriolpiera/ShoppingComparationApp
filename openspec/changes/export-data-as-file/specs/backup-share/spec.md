# Spec: backup-share

> Delta for change `export-data-as-file` (issue #109), proposal engram #601.
> Replaces `DataBackupPage` clipboard-only export with a native share-sheet flow.
> Domain language: see `CONTEXT.md` (Supermarket Visit, Product Family, Catalog Product, Price Record, Shopping Need Entry, Measurement Unit).

## Purpose

Replace the clipboard-only export on the Data Backup page with a primary action that delivers the full backup JSON as a properly-named file through the native share sheet, keeping the clipboard path as a secondary fallback. Tied to issue #109.

## Requirements

### Requirement: Share backup JSON via native share sheet

The Data Backup page SHALL offer a primary action that exports the full schema-v1 backup JSON as a file delivered through the native share sheet, replacing the previous clipboard-only `Export data` button.

#### Scenario: User shares a complete backup
- **GIVEN** the user is on the Data Backup page and the persistence layer can produce a valid schema-v1 backup JSON
- **WHEN** the user taps the primary "Share backup file" action
- **THEN** a file named `shopping-backup-<UTC>.json` is written to the temporary directory
- **AND** the file content equals the JSON returned by `repository.exportBackupJson()`
- **AND** the share sheet is presented with the file attached, MIME type `application/json`
- **AND** the temporary file is deleted after the share completes (success or failure)
- **AND** both buttons stay disabled until the in-flight call resolves

### Requirement: Filename is compact UTC and filesystem-safe

The share service SHALL build the filename from a `Clock`-provided UTC `DateTime` in the form `shopping-backup-yyyyMMddTHHmmssZ.json`, ASCII-only, no colons or slashes.

#### Scenario: Filename is correct and deterministic
- **GIVEN** a `DateTime` of `2026-06-05T18:40:50Z`
- **WHEN** `buildBackupFileName(now)` is called
- **THEN** the result equals `shopping-backup-20260605T184050Z.json` and contains only `[a-zA-Z0-9.-]`
- **AND** for a fixed `Clock`, two invocations produce the same basename, never empty or null

#### Scenario: Custom fileName override is honored
- **GIVEN** the caller passes a non-null `fileName` to the share service
- **THEN** the share sheet receives that override as `fileNameOverrides`
- **AND** the on-disk file still uses the timestamped basename

### Requirement: Clipboard fallback is retained

The Data Backup page SHALL keep a secondary "Copy JSON to clipboard" action that writes the same backup JSON to the clipboard.

#### Scenario: Secondary action still copies the JSON
- **WHEN** the user taps "Copy JSON to clipboard"
- **THEN** the JSON from `repository.exportBackupJson()` is written to the clipboard
- **AND** the snackbar shows the legacy "Backup JSON copied to clipboard" message
- **AND** `onExported` is still invoked
- **AND** when no `copyToClipboard` callback is injected, the existing `Clipboard.setData` default still works

### Requirement: Share failures surface a user-friendly snackbar

A share failure SHALL be a non-fatal user-facing error: snackbar shown, page stays interactive, in-flight state cleared, no partial file left behind.

#### Scenario: Any failure path
- **GIVEN** either the injected `onSharePressed` callback throws OR the injected `PathProviderPort` throws on `getTemporaryPath`
- **WHEN** the user has tapped "Share backup file"
- **THEN** a snackbar shows a user-friendly failure message
- **AND** busy state is cleared, `onExported` is NOT called, and no file remains in the temporary directory
- **AND** if `PathProvider` failed, the share sheet is never presented

### Requirement: Domain layer remains platform-independent

The Domain layer SHALL expose only abstract ports for the new share capability. The Application layer SHALL NOT import `dart:io`, `package:share_plus`, or `package:path_provider`. The Data layer SHALL be the only place those imports are allowed.

#### Scenario: Application service is pure Dart
- **GIVEN** `lib/features/backup/application/backup_share_service.dart`
- **THEN** it does not import `dart:io`, `package:share_plus`, or `package:path_provider`
- **AND** it depends only on the abstract Domain ports `ShareGateway`, `Clock`, and `PathProviderPort`
- **AND** those three ports are declared as abstract classes with no platform code in the Domain layer

### Requirement: Backup JSON payload is byte-identical to the current export

The share service SHALL write the exact `String` returned by `repository.exportBackupJson()`. The JSON schema, key order, and formatting MUST be byte-identical so existing backups remain importable with no migration.

#### Scenario: File content equals the repository export string
- **GIVEN** `exportBackupJson()` returns a known fixed string
- **WHEN** the share service is invoked
- **THEN** the bytes written equal that string exactly
- **AND** the file is not re-encoded, not pretty-printed, and not re-serialized
- **AND** `test/features/persistence/data/drift_persistence_repository_backup_test.dart` stays green unchanged

### Requirement: Test coverage under strict TDD

Strict TDD is ON. Every requirement SHALL map to at least one passing test, written before its implementation, deterministic, independent of real time, network, or device plugins. Tests live in `test/features/backup/`.

#### Scenario: Unit tests for the share service
- **GIVEN** `test/features/backup/application/backup_share_service_test.dart`
- **THEN** it contains at minimum the following passing test cases:
  - `buildBackupFileName_usesCompactUtcTimestamp_fromFixedClock`
  - `buildBackupFileName_containsOnlyAsciiFilenameSafeCharacters`
  - `shareBackupJson_writesJsonToPathProviderTemporaryDirectory`
  - `shareBackupJson_invokesShareGatewayWithApplicationJsonMime`
  - `shareBackupJson_passesMatchingFilenameOverrideToShareGateway`
  - `shareBackupJson_deletesTemporaryFileOnSuccess`
  - `shareBackupJson_deletesTemporaryFileOnShareFailure`
  - `shareBackupJson_propagatesPathProviderFailureWithoutWritingFile`
  - `shareBackupJson_propagatesShareFailure`
  - `shareBackupJson_honorsCustomFileNameOverride`
  - `shareBackupJson_doesNotImportDartIoInApplicationLayer`

#### Scenario: Widget tests for the Data Backup page
- **GIVEN** `test/features/backup/presentation/data_backup_page_test.dart`
- **THEN** it contains at minimum the following passing test cases (legacy clipboard tests are preserved as regressions):
  - `shareAction_invokesOnSharePressedWithRepositoryJson`
  - `shareAction_showsShareReadySnackbarOnSuccess`
  - `shareAction_stillInvokesOnExportedOnSuccess`
  - `shareAction_showsFailureSnackbarWhenOnSharePressedThrows`
  - `shareAction_doesNotInvokeOnExportedOnFailure`
  - `shareAction_disablesButtonsWhileInFlight`
  - `copyJsonAction_stillCopiesToClipboardViaInjectedCallback` (regression)
  - `copyJsonAction_stillCopiesToClipboardViaDefaultImplementation` (regression)
  - `importAction_confirmsReplacementBeforeReplacingData` (preserved)
  - `importAction_requiresPastedJson` (preserved)

### Requirement: PR reviewability and rollback safety

The change SHALL be reviewable in a single PR under 400 changed lines, SHALL be fully reversible by removing the new files and the single `pubspec.yaml` line, and SHALL add exactly one runtime dependency.

#### Scenario: Single dependency line is added
- **THEN** exactly one new line appears under `dependencies:`: `share_plus: ^13.1.0`
- **AND** no other runtime or dev dependency is added or removed

#### Scenario: Rollback restores the prior clipboard-only behavior
- **GIVEN** the change is reverted (one `pubspec.yaml` line removed, three new `lib/features/backup/` files removed, presentation wiring reverted)
- **WHEN** `flutter pub get` is run
- **THEN** the page returns to the prior clipboard-only behavior with no data migration needed
