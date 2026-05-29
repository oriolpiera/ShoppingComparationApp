# docs/architecture.md

# Architecture

## Goals

The architecture of this application is designed to:

* Keep business logic independent from Flutter UI
* Make the application easy to test
* Allow incremental feature growth
* Reduce coupling between modules
* Keep mobile performance predictable
* Enable offline-first improvements in the future

---

# Architectural principles

## 1. Separation of concerns

Each layer has a clear responsibility.

| Layer               | Responsibility                         |
| ------------------- | -------------------------------------- |
| Presentation        | UI and user interaction                |
| Application / State | State management and orchestration     |
| Domain              | Business rules and use cases           |
| Data                | APIs, persistence and external systems |

---

## 2. Dependency direction

Dependencies must always point inward:

```text
Presentation -> Application -> Domain -> Data
```

The domain layer must not depend on Flutter.

---

## 3. Feature-first organization

Prefer organizing code by feature instead of technical type.

Preferred structure:

```text
lib/
  features/
    shopping_list/
      presentation/
      application/
      domain/
      data/

    supermarkets/
      presentation/
      application/
      domain/
      data/

  shared/
  core/
```

Benefits:

* Better scalability
* Easier navigation
* Lower coupling
* Easier extraction into packages later

---

# Layer responsibilities

## Presentation layer

Contains:

* Widgets
* Screens
* UI-only state
* Navigation triggers
* User interaction handling

Rules:

* No direct API access
* No persistence logic
* No business rules
* Keep widgets small and composable

Good:

* Formatting values for display
* Animations
* Responsive layouts

Bad:

* Price comparison algorithms
* Database queries
* HTTP requests

---

# Application layer

Contains:

* State management
* Controllers
* Coordinators
* Use case orchestration

Responsibilities:

* Transform domain data into UI state
* Handle loading/error/success states
* Coordinate async flows

Should not:

* Know Flutter widget details
* Access storage directly

Possible technologies:

* Riverpod
* Bloc
* Cubit
* ValueNotifier

Avoid mixing multiple state management approaches unless justified.

---

# Domain layer

Contains:

* Entities
* Value objects
* Use cases
* Business rules
* Repository contracts/interfaces

The domain layer is the heart of the application.

Requirements:

* Pure Dart whenever possible
* Fully unit-testable
* Independent from Flutter
* Independent from persistence implementation

Examples:

* Product comparison logic
* Price normalization
* Shopping optimization
* Unit conversion rules

---

# Data layer

Contains:

* Repository implementations
* API clients
* Local database access
* DTOs
* Mappers

Responsibilities:

* Fetch data
* Cache data
* Convert external models into domain models

Rules:

* External models never leak into domain/UI
* Use mappers between layers
* Handle retries and network failures here

---

# State management guidelines

## Preferred principles

* Keep ephemeral UI state local
* Keep business state centralized
* Make state deterministic
* Prefer immutable state objects

## Avoid

* Hidden mutable state
* Business logic inside widgets
* Global state without justification

---

# Async & concurrency

## Guidelines

* Avoid blocking the UI thread
* Prefer async/await
* Cancel unused operations when possible
* Handle loading and cancellation explicitly

## Network behavior

The app should:

* Handle slow connections gracefully
* Handle offline mode safely
* Retry only when appropriate

---

# Error handling strategy

## Expected errors

Examples:

* Network unavailable
* Invalid server responses
* Missing data

These should:

* Produce user-friendly messages
* Preserve app stability

## Unexpected errors

Examples:

* Programming bugs
* Invalid assumptions

These should:

* Be logged
* Fail safely
* Never crash silently

---

# Persistence strategy

Preferred order:

1. In-memory cache
2. Local persistence
3. Network refresh

Goals:

* Faster UI
* Lower network usage
* Better offline experience

---

# UI guidelines

## Responsiveness

Support:

* Phones
* Tablets (eventually)
* Portrait and landscape

## Accessibility

Support:

* Dynamic text scaling
* Screen readers where possible
* Adequate contrast
* Large touch targets

---

# Performance guidelines

## Avoid

* Large rebuild trees
* Unnecessary allocations
* Expensive work during build
* Excessive nested scrolling

## Prefer

* const widgets
* Lazy rendering
* Memoization when useful
* Pagination for large datasets

---

# Dependency injection

Dependencies should:

* Be explicit
* Be injectable
* Be mockable in tests

Avoid:

* Hidden globals
* Service locators everywhere
* Tight coupling

---

# Logging

Logging should:

* Help debugging
* Avoid sensitive information
* Be structured when possible

Never log:

* Secrets
* Tokens
* Personal user information

---

# Scalability guidelines

As the app grows:

* Split features cleanly
* Keep boundaries strict
* Avoid shared mutable utilities
* Reduce cross-feature dependencies

---

# Architecture decision principles

When choosing solutions:

Prefer:

* Simplicity
* Maintainability
* Testability
* Predictability

Over:

* Clever abstractions
* Premature optimization
* Excessive generic code

---

# Refactoring policy

Refactor when:

* Complexity grows
* Duplication appears repeatedly
* Testing becomes difficult
* Feature velocity slows down

Avoid:

* Massive rewrites
* Refactors without tests
* Architectural changes without clear benefit

