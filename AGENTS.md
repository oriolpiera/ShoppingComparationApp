# AGENTS.md

## Project overview

This repository contains a Flutter mobile application focused on shopping price comparison and supermarket product tracking.

Target platforms:

* Android (primary)
* iOS (secondary)

Main goals:

* Maintain a clean and scalable architecture
* Keep UI responsive and mobile-friendly
* Prioritize offline-first thinking when possible
* Keep the app maintainable through strong testing practices

---

## General agent behavior

### Always

* Read existing code patterns before introducing new abstractions
* Read `CONTEXT.md` before making significant domain, naming, or workflow changes
* Prefer incremental changes over large rewrites
* Keep files small and focused
* Reuse existing widgets and utilities whenever possible
* Write tests for all business logic changes
* Run formatting, analyzer, and tests before finalizing changes
* Preserve backwards compatibility unless explicitly asked otherwise
* Optimize for readability and maintainability over cleverness

### Ask first

* Adding new dependencies
* Introducing new architectural layers
* Changing navigation structure
* Changing persistence strategy
* Large refactors
* State management migrations
* CI/CD modifications

### Never

* Commit secrets, API keys, `.env` files or signing keys
* Disable lint rules globally
* Ignore failing tests
* Add generated files manually
* Introduce unnecessary singleton patterns
* Use deprecated Flutter APIs when stable alternatives exist
* Push implementation fixes directly to `main` as the intended workflow

---

## GitHub workflow

Default workflow for code changes:

1. Create or confirm a GitHub issue first
2. Implement the change on a branch
3. Open a pull request linked to the issue
4. Stop before merge unless the user explicitly asks otherwise

Rules:

* Prefer `Issue -> PR -> user merges to main`
* Do not treat direct push to `main` as the normal path
* If a fix accidentally lands on `main`, create a retrospective issue for traceability

---

## Development commands

### Install dependencies

```bash
flutter pub get
```

### Run app

```bash
flutter run
```

### Run on specific device

```bash
flutter devices
flutter run -d <device-id>
```

### Static analysis

```bash
flutter analyze
```

### Format code

```bash
dart format .
```

### Run tests

```bash
flutter test
```

### Run a single test

```bash
flutter test test/path_to_test.dart
```

### Build APK

```bash
flutter build apk
```

### Build AppBundle

```bash
flutter build appbundle
```

---

## Architecture guidelines

Prefer a layered architecture:

* Presentation
* Application / State management
* Domain / Business logic
* Data layer

Business logic must never depend directly on Flutter UI.

Preferred dependency direction:

```text
UI -> State -> Domain -> Data
```

Keep domain logic platform-independent whenever possible.

---

## Flutter best practices

### Widgets

* Prefer small composable widgets
* Extract reusable UI early
* Avoid deeply nested widget trees
* Prefer `const` constructors whenever possible
* Avoid massive build methods
* One widget per responsibility

### State management

* Keep UI state local when possible
* Avoid global mutable state
* Business state should be testable without Flutter bindings
* Avoid putting business logic inside widgets

### Performance

* Minimize unnecessary rebuilds
* Use lazy lists for large collections
* Avoid expensive synchronous work on UI thread
* Cache derived values when appropriate
* Prefer immutable models

### Navigation

* Keep navigation centralized
* Avoid navigation logic inside reusable widgets

---

## Android best practices

### General

* Respect Android lifecycle behavior
* Handle app backgrounding safely
* Avoid blocking the main thread
* Test different screen sizes
* Support dark mode when possible

### Storage & permissions

* Request minimum permissions required
* Explain permission usage clearly
* Avoid unnecessary persistent storage
* Never store sensitive data insecurely

### Battery & network

* Minimize background processing
* Avoid aggressive polling
* Handle offline and slow network conditions gracefully

---

## Testing guidelines

Testing is mandatory for business logic.

### Preferred testing pyramid

1. Unit tests
2. Widget tests
3. Integration tests

### Unit tests

Must cover:

* Use cases
* Services
* Repositories
* Parsing/mapping logic
* Edge cases
* Error handling

### Widget tests

Use for:

* Critical UI flows
* Stateful widgets
* Validation behavior
* Navigation triggers

### Integration tests

Use for:

* End-to-end flows
* Persistence behavior
* Critical user journeys

### TDD guidelines

Preferred workflow:

1. Write failing test
2. Implement minimal solution
3. Refactor safely

Tests should:

* Be deterministic
* Avoid timing dependencies
* Avoid real network calls
* Use mocks/fakes only where useful
* Focus on observable behavior

---

## Code style conventions

### Dart style

* Follow official Dart formatting
* Prefer final variables
* Prefer immutable data structures
* Avoid dynamic unless strictly necessary
* Use explicit types for public APIs

### Naming

* Use clear descriptive names
* Avoid abbreviations
* Widgets: `SomethingCard`
* Services: `SomethingService`
* Repositories: `SomethingRepository`
* Models: singular nouns

### Files

* One primary class per file
* Keep files focused
* Avoid files larger than ~300-400 lines when possible

---

## Dependency management

Before adding dependencies:

* Prefer Flutter/Dart SDK solutions first
* Prefer actively maintained packages
* Verify package popularity and maintenance
* Avoid overlapping libraries

When adding a dependency:

* Explain why
* Keep versions compatible
* Avoid unnecessary transitive complexity

---

## Error handling

* Fail gracefully
* Never silently swallow exceptions
* Log meaningful debugging information
* Show user-friendly messages
* Separate user-facing errors from technical logs

---

## Accessibility & UX

* Support dynamic text sizes where possible
* Use semantic labels when appropriate
* Maintain good touch target sizes
* Avoid low-contrast UI
* Keep interactions predictable

---

## Security

* Never hardcode secrets
* Use secure storage for sensitive data
* Validate all external input
* Treat local storage as potentially inspectable
* Avoid exposing internal stack traces to users

---

## Pull request checklist

Before finalizing work:

* Code formatted
* Analyzer passes
* Tests pass
* No debug prints left
* No dead code added
* Documentation updated if needed
* New behavior covered by tests

---

## Agent-specific guidance

When modifying existing code:

1. First understand existing architecture
2. Follow existing patterns unless clearly problematic
3. Prefer consistency over personal preference
4. Minimize unrelated changes
5. Explain tradeoffs when introducing complexity

If uncertain:

* Ask instead of guessing
* Prefer conservative changes

---

## Documentation references

Agents working on this repository must read and follow the project context and the documentation inside the `docs/` directory before making significant architectural, domain, naming, or testing changes.

### Domain context

Canonical file:

```text
CONTEXT.md
```

Use this file for:

* Domain vocabulary
* Naming decisions
* Relationship rules
* Resolved product and shopping concepts

Do not create or rely on duplicate lowercase `context.md` files. `CONTEXT.md` is the source of truth.

### Architecture

See:

```text id="xjew2q"
docs/architecture.md
```

This document defines:

* Layer responsibilities
* Dependency direction
* Feature organization
* State management principles
* Error handling strategy
* Scalability guidelines
* Performance expectations

All new code should align with the architecture guidelines unless explicitly instructed otherwise.

### Testing

See:

```text id="gbq9e1"
docs/testing.md
```

This document defines:

* Testing philosophy
* TDD workflow
* Unit/widget/integration testing strategy
* CI expectations
* Deterministic testing rules
* Mocking guidelines
* Regression prevention practices

All business logic changes should include appropriate tests following these guidelines.

### In case of conflict

Priority order:

```text id="c8zv1u"
AGENTS.md
docs/architecture.md
docs/testing.md
Existing code conventions
```

When existing code conflicts with the documented architecture:

* Prefer incremental migration
* Avoid massive rewrites
* Discuss large architectural changes before implementing them
