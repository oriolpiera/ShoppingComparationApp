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
