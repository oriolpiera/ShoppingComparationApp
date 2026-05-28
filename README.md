# ShoppingComparationApp

App to compare grocery product prices.

## Repository scaffolding conventions

The project follows a **feature-first** structure with separation between UI, domain logic, and data access.

### Top-level Flutter layout

- `lib/main.dart` → process entrypoint (`runApp`)
- `lib/app/` → app shell (theme, root widget wiring)
- `lib/core/` → shared cross-feature infrastructure
- `lib/features/` → isolated feature modules
- `test/` → automated tests

### Feature module convention

Each feature should keep layers separated:

- `presentation/` → screens and widgets (UI only)
- `domain/` → entities and business rules
- `data/` → repositories, datasources, mappers

Example (current `home` feature):

- `lib/features/home/presentation/home_page.dart`
- `lib/features/home/domain/entities/home_section.dart`
- `lib/features/home/data/repositories/home_sections_repository.dart`

## Current status

- App boots through `PriceComparatorApp`
- Root screen delegated to `HomePage`
- Base folders are ready for adding new features without mixing UI and business logic

## PR web preview workflow

Pull requests trigger `.github/workflows/preview.yml`, which runs:
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter test`
- `flutter build web --release --dart-define=WEB_PREVIEW=true`
- Firebase Hosting preview deploy
- PR comment with the preview URL

### Required GitHub secrets

Configure these repository secrets for preview deploys:
- `FIREBASE_SERVICE_ACCOUNT`: service account JSON for Firebase Hosting deploy
- `FIREBASE_PROJECT_ID`: Firebase project id

## Android release APK workflow

Publishing a GitHub Release triggers `.github/workflows/release-android-apk.yml` (also runnable manually via `workflow_dispatch`), which runs:
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter create . --platforms android`
- `flutter build apk --release`
- Upload `build/app/outputs/flutter-apk/*.apk` as an Actions artifact

### Signing strategy

Current workflow builds a release APK with the default Android signing available in CI (no custom upload keystore configured yet).

If you want Play Store-ready signing, add your own keystore and `key.properties` wiring for the Android project, then provide the required secrets in GitHub Actions.
