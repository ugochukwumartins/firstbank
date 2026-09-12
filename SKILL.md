---
name: lancebox-flutter
description: >
  Build and review the LanceBox invoicing mobile app in Flutter. Focus on faithful
  Figma implementation, onboarding and invoicing flows, error handling,
  responsiveness, code quality, state management, scalability, performance,
  documentation, and presentation readiness. Optimize for the 60-minute case-study
  constraint and avoid unnecessary architectural complexity.
---

# LanceBox Flutter Engineering Skill

## Purpose

Use this skill when working on the **LanceBox Simple Invoicing Mobile App**.

The assignment is to implement the supplied Figma design as a mobile application
using Flutter, with **Onboarding** and **Invoicing** features.

The implementation will be evaluated on:

- Accuracy of screens and features against the design/specification.
- Error handling.
- Responsiveness.
- Code quality, including readability, state management, and scalability.
- Performance, including load time and resource usage.
- Documentation.
- Ability to present and explain the code and final solution.

The assessment has a **60-minute maximum duration**, so optimize for a complete,
working, explainable solution rather than architectural ceremony.

---

# Core Operating Principles

## 1. Follow the case study and Figma

Treat the case study and Figma as the source of truth.

Do not invent screens, workflows, fields, or business rules that are not required.

When the Figma and code disagree:

1. Prefer the Figma for visual behavior.
2. Prefer explicit case-study requirements for functional behavior.
3. If something is ambiguous, implement the simplest reasonable behavior.
4. Record important assumptions in the README.

Do not spend assessment time implementing speculative features.

---

## 2. Do not over-engineer

Use the simplest production-quality Flutter structure that supports the required
features.

Avoid introducing architecture merely to demonstrate knowledge.

Do not add, unless clearly needed:

- Multiple repository layers.
- Use-case classes for trivial operations.
- DTO/domain duplication.
- Dependency-injection frameworks.
- Complex event buses.
- Multiple state-management libraries.
- Premature caching.
- Unnecessary networking abstractions.
- Microservice-style concepts in the mobile client.

Every abstraction must solve an actual problem in the application.

---

## 3. Prioritize in this order

When time is limited, work in this sequence:

1. Project runs successfully.
2. Figma/theme foundations.
3. Onboarding flow.
4. Core invoicing flow.
5. Form validation and error states.
6. Navigation.
7. Responsiveness.
8. State-management cleanup.
9. Performance cleanup.
10. Documentation.
11. Presentation notes.

A complete, explainable implementation is more valuable than an elaborate but
unfinished architecture.

---

# Flutter and Dart Standards

## Dart

Use:

- Sound null safety.
- Clear types.
- Immutable models where practical.
- `final` by default.
- `const` constructors where appropriate.
- `async` / `await` for asynchronous work.
- Small, focused methods.
- Descriptive names.

Avoid:

- Excessive `dynamic`.
- Unchecked casts.
- Large anonymous callbacks.
- Business logic embedded directly in widget trees.
- Empty `catch` blocks.
- `print()` for production-style logging.

Run before submission:

```bash
dart format .
flutter analyze
flutter test
```

If time prevents fixing a non-critical analyzer issue, document it explicitly.

---

# Project Structure

Prefer a lightweight feature-oriented structure.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
│
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── invoices/
│       ├── models/
│       ├── screens/
│       ├── widgets/
│       └── state/
│
└── shared/
    ├── widgets/
    └── utils/
```

Do not create empty folders merely to satisfy this structure.

If the application is very small, simplify it.

---

# Figma-to-Flutter Implementation

## Visual fidelity

Translate the Figma into reusable Flutter components.

Pay attention to:

- Typography.
- Font sizes.
- Font weights.
- Colors.
- Spacing.
- Border radius.
- Borders.
- Shadows.
- Icons.
- Alignment.
- Component size.
- Image sizing.
- Screen hierarchy.

Do not scatter arbitrary visual values across many widgets.

Centralize recurring values in:

- `ThemeData`
- `ColorScheme`
- text styles
- shared constants
- reusable widgets

Use design tokens only where repetition justifies them.

---

## Reusable UI components

Create reusable widgets when the same visual or behavioral pattern occurs more
than once.

Likely candidates include:

- Primary button.
- Secondary button.
- Form field.
- Password field.
- Screen header.
- Invoice item row.
- Invoice summary.
- Empty state.
- Loading indicator.
- Error message.

Do not extract a widget solely because it is a few lines long.

Extract when reuse, readability, testing, or separation of responsibility improves.

---

# Responsive Design

The app must behave correctly across reasonable phone dimensions.

Prefer:

- `SafeArea`
- `Expanded`
- `Flexible`
- `LayoutBuilder`
- `MediaQuery`
- `ListView`
- `SingleChildScrollView`

Avoid fixed heights when content can vary.

Forms must remain usable when the keyboard opens.

Prevent:

- Render overflow.
- Hidden submit buttons.
- Clipped text.
- Fixed-width layouts that only work on one device.
- Unscrollable long forms.

Use responsive behavior, not arbitrary device-specific conditionals.

---

# Navigation

Keep navigation predictable.

The expected navigation model should support the screens actually present in the
Figma, including the onboarding and invoicing flows.

For a small assessment project, Flutter's built-in navigation is acceptable.

Introduce `go_router` only if it materially simplifies the required flow.

Do not spend assessment time building a sophisticated routing architecture unless
the design requires it.

Back navigation must behave sensibly.

---

# State Management

Use one state-management approach consistently.

For a small case-study application, valid approaches include:

- Widget-local state for local UI behavior.
- `ChangeNotifier` for small shared state.
- Riverpod if already selected for the project.
- Bloc/Cubit if already selected for the project.

Do not introduce multiple state-management approaches without a clear reason.

## State boundaries

Keep state local when only one widget needs it.

Promote state when it must be shared across screens or features.

Examples of shared invoice state:

- Current invoice.
- Invoice items.
- Customer information.
- Invoice totals.
- Invoice status if required.

Do not place every variable into global state.

---

# Invoice Domain

Create explicit models for the data actually required by the design.

Possible models include:

```dart
class Invoice {
  final String id;
  final String customerName;
  final List<InvoiceItem> items;
  final DateTime createdAt;
  final double total;

  const Invoice({
    required this.id,
    required this.customerName,
    required this.items,
    required this.createdAt,
    required this.total,
  });
}
```

```dart
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
```

These are examples only.

Match the final model to the fields actually shown in the supplied design.

---

# Business Logic

Keep calculation logic outside the widget tree.

For invoice calculations:

```text
line total = quantity × unit price
subtotal   = sum(line totals)
total      = subtotal + applicable additions - applicable deductions
```

Only implement tax, discount, fees, status, payment terms, or other calculations if
the supplied design/specification requires them.

Use a consistent money representation.

For a case study, `double` may be acceptable for display-oriented mock data.

If financial accuracy is part of the actual requirement, prefer integer minor units
or an appropriate decimal implementation.

Do not silently add banking-grade financial behavior that the case study does not
request.

---

# Forms and Validation

Use Flutter's form facilities where appropriate:

- `Form`
- `GlobalKey<FormState>`
- `TextFormField`
- `TextEditingController`

Validate relevant fields before submission.

Possible validation rules:

- Required text cannot be empty.
- Quantity must be valid and greater than zero.
- Monetary values must be valid and non-negative where appropriate.
- Dates must be valid.
- Email/phone validation should only be added if required by the design.

Show validation errors close to the relevant field.

Do not fail silently.

Dispose controllers and focus nodes when the widget owns them.

---

# Error Handling

The assessment explicitly evaluates error handling.

Handle likely failure states deliberately.

Examples:

- Invalid form input.
- Missing required data.
- Empty invoice list.
- Failed asynchronous operation.
- Invalid numeric input.
- Unexpected application error.

For asynchronous operations:

```dart
try {
  // operation
} catch (error) {
  // translate into a user-visible error state
}
```

Do not expose raw stack traces or technical exception messages in the UI.

Use meaningful user-facing messages.

If the project has no real backend, do not create fake networking complexity merely
to demonstrate error handling. Validate and handle the actual failure modes present
in the app.

---

# Loading and Empty States

If a screen loads data asynchronously, represent:

```text
loading
success
empty
error
```

Do not show a blank screen while loading.

Do not show an unexplained empty screen when no invoices exist.

If the entire app is local/mock-data driven, only implement states relevant to the
actual implementation.

---

# Performance

Keep the application lightweight.

Use:

- `const` constructors where useful.
- `ListView.builder` for dynamic lists.
- Lazy rendering for long lists.
- Proper image sizing.
- Cached assets when appropriate.
- Narrow state updates.

Avoid:

- Expensive calculations inside `build()`.
- Recreating controllers during rebuild.
- Unnecessary state notifications.
- Unbounded image sizes.
- Excessive third-party packages.

Do not perform premature micro-optimization.

Focus first on avoiding obvious waste and unnecessary rebuilds.

---

# Assets

Declare assets correctly in `pubspec.yaml`.

Use local assets supplied for the exercise where available.

Do not substitute random internet assets when the Figma provides or implies a
specific asset.

If an exact asset cannot be obtained during the assessment, use the closest
appropriate local placeholder and document the limitation.

---

# Dependencies

Keep dependencies minimal.

Before adding a package, ask:

1. Is this needed to satisfy the requirements?
2. Can Flutter/Dart already do this simply?
3. Will adding the package consume more assessment time than it saves?
4. Can I explain why this dependency exists?

Remove unused dependencies before submission.

---

# Testing

Prioritize tests around logic that is easy to break and easy to demonstrate.

Minimum useful coverage may include:

- Invoice item total calculation.
- Invoice total calculation.
- Form validation.
- Important state mutations.

Example:

```dart
test('invoice item calculates line total', () {
  const item = InvoiceItem(
    description: 'Consulting',
    quantity: 2,
    unitPrice: 5000,
  );

  expect(item.total, 10000);
});
```

Add widget tests for high-value UI behavior if time permits.

Do not spend most of the 60-minute assessment constructing a large test suite at
the expense of required screens.

---

# Accessibility

Use reasonable accessibility practices:

- Clear labels.
- Sufficient tap targets.
- Text that respects reasonable scaling.
- Semantic meaning for important controls.
- Do not communicate state solely by color.

Do not let accessibility work derail completion, but avoid obvious accessibility
problems.

---

# Documentation

Create a concise `README.md`.

It should contain:

```text
# LanceBox

## Overview

## Features

## Architecture / Project Structure

## State Management

## Running the App

## Testing

## Design Decisions

## Assumptions

## Known Limitations

## What I Would Improve With More Time
```

Keep it short enough that an assessor can scan it quickly.

Document decisions that are useful during the presentation.

Do not write pages of theoretical architecture documentation.

---

# Presentation Readiness

The implementation must be easy to explain to assessors.

Before submission, be prepared to explain:

1. How the project is organized.
2. Why the chosen state-management approach fits the app.
3. How Figma components were translated into reusable Flutter widgets.
4. Where invoice business logic lives.
5. How form validation works.
6. How errors are surfaced.
7. How responsiveness is handled.
8. What was done for performance.
9. What tests exist.
10. What would be improved with more time.

Never include code you cannot explain.

Prefer a simpler implementation you fully understand over advanced patterns added
only to appear sophisticated.

---

# 60-Minute Execution Strategy

## 0-5 minutes — Inspect

- Read the case study.
- Review every Figma screen.
- Identify the mandatory user journey.
- Identify reusable components.
- Identify required assets.
- Note any ambiguity.

Do not begin coding before understanding the minimum complete flow.

## 5-10 minutes — Foundation

- Verify Flutter project runs.
- Configure theme.
- Add required assets.
- Establish lightweight folders.
- Configure basic navigation.

## 10-25 minutes — Onboarding

- Build onboarding screens.
- Implement navigation.
- Match Figma spacing and typography.
- Ensure screens are scroll/keyboard safe where relevant.

## 25-45 minutes — Invoicing

Implement the core invoicing journey.

Prioritize:

- Required fields.
- Invoice items.
- Totals.
- Validation.
- Required list/detail/create views from the design.

## 45-52 minutes — Hardening

Check:

- Invalid input.
- Empty state.
- Screen overflow.
- Back navigation.
- Small phone layout.
- Error states.
- Controller disposal.

## 52-56 minutes — Quality

Run:

```bash
dart format .
flutter analyze
flutter test
```

Fix high-value issues first.

## 56-60 minutes — Submission

- Update README.
- Remove dead code.
- Remove debug output.
- Verify app launches.
- Prepare a short presentation explanation.

---

# Agent Behavior

When acting as a coding agent on this project:

## Before changing code

1. Inspect the relevant existing files.
2. Identify the current pattern used by the project.
3. Preserve existing conventions unless they are clearly harmful.
4. State the smallest intended change.

## While changing code

- Modify the minimum number of files necessary.
- Keep changes scoped to the requested task.
- Reuse existing widgets and styles.
- Do not refactor unrelated code.
- Do not silently introduce dependencies.
- Do not rename large portions of the project without necessity.

## After changing code

Run the relevant checks whenever possible:

```bash
dart format .
flutter analyze
flutter test
```

Report:

- What changed.
- What was verified.
- Any assumptions.
- Any remaining limitation.

---

# Review Checklist

Before declaring the project ready, verify:

## Functionality

- [ ] App launches.
- [ ] Required onboarding flow works.
- [ ] Required invoicing flow works.
- [ ] Navigation works.
- [ ] Required calculations are correct.
- [ ] Forms validate correctly.

## Design

- [ ] Screens reasonably match Figma.
- [ ] Typography is consistent.
- [ ] Colors are consistent.
- [ ] Spacing is consistent.
- [ ] Buttons and inputs match the design.
- [ ] No visible overflow.

## State

- [ ] Local state remains local.
- [ ] Shared state has a clear owner.
- [ ] No duplicate state sources.
- [ ] State mutations are understandable.

## Error handling

- [ ] Invalid input is handled.
- [ ] Empty states are handled.
- [ ] Async errors are handled if present.
- [ ] No silent exception swallowing.

## Quality

- [ ] Code formatted.
- [ ] Analyzer checked.
- [ ] Important logic tested.
- [ ] No unused dependencies.
- [ ] No unnecessary debug output.
- [ ] Controllers/resources are disposed.

## Documentation

- [ ] README explains how to run the app.
- [ ] README explains important architectural decisions.
- [ ] Assumptions are documented.
- [ ] Limitations are documented.

## Presentation

- [ ] Every architectural decision can be explained.
- [ ] State-management choice can be defended.
- [ ] Error handling can be demonstrated.
- [ ] Responsive behavior can be demonstrated.
- [ ] At least one important test can be discussed.

---

# Decision Rule

When choosing between two implementations, prefer the one that is:

1. Correct.
2. Faithful to the design.
3. Simple.
4. Readable.
5. Easy to test.
6. Easy to explain.
7. Fast to complete.

For this assessment, **finished and defensible beats elaborate and incomplete**.
