# ShoppingComparationApp

App to compare groceries product prices.

## Current bootstrap (Issues #1, #2, #3)

### Flutter base structure
- `lib/app/` → app shell and routing entry
- `lib/core/` → shared infrastructure (database, services)
- `lib/features/` → feature-first modules (supermarkets, products, prices)

### Isar models
- `lib/features/supermarkets/data/models/supermarket.dart`
- `lib/features/products/data/models/product.dart`
- `lib/features/prices/data/models/price_entry.dart`

### CI/CD preview workflow
- `.github/workflows/preview.yml`

PR workflow does:
1. `flutter pub get`
2. `build_runner` code generation
3. `flutter test`
4. `flutter build web --dart-define=WEB_PREVIEW=true`
5. Deploy preview channel to Firebase Hosting and comment URL on PR

### Required GitHub secrets
- `FIREBASE_SERVICE_ACCOUNT`
- `FIREBASE_PROJECT_ID`

### Firebase config files
- `firebase.json`
- `.firebaserc` (replace project id placeholder)
