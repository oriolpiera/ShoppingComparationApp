# Testing Strategy

## Goals

The testing strategy aims to:

* Prevent regressions
* Enable safe refactoring
* Improve maintainability
* Increase confidence in releases
* Detect bugs early

The application should remain testable at all architectural layers.

---

# Testing philosophy

## Prioritize behavior

Tests should validate:

* Observable behavior
* Business rules
* User-visible outcomes

Avoid testing:

* Internal implementation details
* Private methods directly
* Flutter framework internals

---

# Testing pyramid

Preferred distribution:

```text
                 Unit tests
              Widget tests
           Integration tests

Most tests should be unit tests.

---

# Unit tests

## Purpose

Validate isolated business logic quickly and deterministically.

## Must cover

* Use cases
* Services
* Repositories
* Value objects
* Parsers
* Mappers
* Validation rules
* Edge cases
* Error handling

## Requirements

Unit tests must:

* Run fast
* Avoid Flutter bindings when possible
* Avoid real network calls
* Avoid real databases
* Be deterministic

---

# Widget tests

## Purpose

Validate UI behavior without full device integration.

## Recommended for

* Screen rendering
* Form validation
* User interaction
* Navigation triggers
* State transitions
* Conditional rendering

## Guidelines

* Keep widgets small
* Mock dependencies
* Avoid testing visual styling excessively
* Focus on behavior

---

# Integration tests

## Purpose

Validate critical end-to-end flows.

## Recommended flows

* App startup
* Shopping list creation
* Product comparison
* Persistence behavior
* Navigation flows

## Guidelines

* Keep integration tests limited
* Cover only critical paths
* Avoid duplication with lower-level tests

---

# TDD workflow

Preferred workflow:

1. Write failing test
2. Implement minimal solution
3. Refactor safely
4. Repeat

Benefits:

* Better API design
* Reduced overengineering
* Safer refactoring
* Higher confidence

---

# Test structure

## Naming

Use descriptive names.

Good:

```dart
returns_best_price_when_multiple_supermarkets_exist
```

Bad:

```dart
test_price
```

---

# Arrange / Act / Assert

Preferred structure:

```dart
// Arrange
final repository = FakeRepository();

// Act
final result = await useCase.execute();

// Assert
expect(result.isValid, true);
```

---

# Test doubles

## Prefer

* Fakes
* Stubs
* Simple mocks

## Avoid

* Excessive mocking
* Mocking implementation details
* Deep mock hierarchies

---

# Golden rules

## Tests must be deterministic

Avoid:

* Real time dependencies
* Randomness
* Network reliance
* Shared mutable state

## Tests must be isolated

Each test should:

* Run independently
* Clean up after itself
* Not depend on execution order

---

# Coverage guidelines

Coverage is useful but not the main goal.

Prioritize:

* Critical business logic
* Complex flows
* Risky areas

Do not chase meaningless 100% coverage.

---

# Error handling tests

Must validate:

* Network failures
* Invalid data
* Empty states
* Timeouts
* Parsing failures

---

# Async testing

Guidelines:

* Await all async operations
* Avoid arbitrary delays
* Use fake async utilities when useful

Avoid:

```dart
await Future.delayed(...)
```

unless strictly necessary.

---

# Repository testing

Repository tests should validate:

* Mapping correctness
* Cache behavior
* Error propagation
* Offline handling

Prefer fake data sources when possible.

---

# Widget testing guidelines

## Prefer testing

* What the user sees
* User interactions
* State changes

## Avoid testing

* Exact widget tree structure
* Internal implementation details

---

# Snapshot / golden testing

Use sparingly.

Recommended for:

* Critical reusable widgets
* Design system components

Avoid:

* Fragile full-screen snapshots

---

# Integration testing guidelines

Integration tests should:

* Run in CI
* Cover critical paths only
* Avoid flakiness

---

# Performance testing

Important for:

* Large lists
* Expensive comparisons
* Heavy parsing

Monitor:

* Rebuild counts
* Frame drops
* Startup time

---

# CI requirements

Every pull request should:

* Run formatter
* Run analyzer
* Run tests

Minimum commands:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

---

# Bugfix policy

Every bug fix should include:

* A reproducing test
* The actual fix
* Regression protection

---

# Recommended folder structure

```text
test/
  unit/
  widget/
  integration/
  fixtures/
  helpers/
```

---

# Fixtures

Fixtures should:

* Be small
* Be readable
* Represent realistic scenarios

Avoid:

* Massive JSON fixtures
* Irrelevant data

---

# Test data builders

Prefer builders for complex objects.

Benefits:

* Better readability
* Easier customization
* Reduced duplication

---

# Final principles

Good tests are:

* Fast
* Deterministic
* Readable
* Maintainable
* Behavior-focused

Tests are part of the product codebase and must receive the same quality standards as production code.

