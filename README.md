# LanceBox

Flutter implementation of the supplied LanceBox onboarding and invoicing screenshots for the Senior Analyst mobile-development case study.

## Features

- Local onboarding demo with email/password validation (passwords are never stored).
- Optional PNG/JPG logo selection below 20 MB, business/freelancer selection, and skip.
- Dashboard with invoice count, empty state, saved history, and navigation drawer.
- Invoice editor with dynamic line items, date/currency selection, VAT, shipping, bank details, and payment terms.
- Preview, edit, actual PDF export, device sharing/email handoff, and a local saved-invoice store.
- Inline errors, disabled invalid actions, progress indicators, and discard confirmation.

## Architecture / Project Structure

- `lib/main.dart`: asynchronous storage initialization and retry.
- `lib/app/`: theme, app entry, and shared store.
- `lib/features/onboarding/`: sign-up and profile setup.
- `lib/features/invoices/`: models, dashboard, editor, preview, and PDF generation.
- `lib/shared/ui.dart`: exports focused components from `shared/widgets/`.

See [the code guide](docs/CODE_GUIDE.md) for a plain-language file map and explanation of Riverpod.

## State Management

Forms own and dispose their controllers. Riverpod’s `appStoreProvider` (`NotifierProvider<AppStore, AppState>`) owns immutable profile and saved-invoice snapshots. `ProviderScope` supplies initialized local storage; screens use `ref.watch` for state and `ref.read(...notifier)` for actions. The app watches only onboarding completion when choosing its home screen. A draft stays in its editor through bank/preview navigation. Saved invoices are replaced by stable ID when edited. Storage writes finish before the in-memory list changes; corrupt invoice storage is not overwritten silently.

## Running the App

Use Flutter with Dart 3.10.3 or newer compatible with the lockfile. Run:

```sh
flutter pub get
# Select an Android/iOS simulator or connected device:
flutter devices
flutter run -d <device-id>
```

Android uses Java 17, AGP 8.12.1 and the supplied Gradle wrapper. iOS builds need Xcode and signing/device setup. macOS file-picker entitlements are included. To produce an Android debug build, run `flutter build apk --debug`.

Onboarding is a local demonstration, not authentication. Use a valid email-shaped value and any matching password of at least eight characters; no credentials are transmitted or persisted. Profile setup is optional. Invoices remain on this device after logging out. This is one local workspace, not separate user accounts.

## Testing

```sh
dart format .
flutter analyze
flutter test
```

Tests cover rounding, VAT/shipping totals, invalid numbers, JSON round trips, persistence and editing, corrupt-data protection, PDF output, sign-up validation, Riverpod profile/logout notifications and immutable snapshots, invoice creation/preview/edit at 320-pixel phone width, and visual regression snapshots.

Run the checks above after making changes. Android APK: `build/app/outputs/flutter-apk/app-debug.apk`. Device-level file-picker/share-sheet behavior remains unverified; iOS has not been built.

## Design Decisions

- Lightweight Flutter navigation and one Riverpod notifier; no backend or speculative repository layers.
- Monetary values use integer minor units. Decimal quantities and VAT percentages are rounded to minor units at line/tax calculation boundaries.
- `total = sum(line totals) + VAT on subtotal + shipping`.
- Bank numbers stay as text to retain leading zeros.
- PDF and screen preview use the same invoice model and calculations.
- Long forms scroll; the preview uses a four-column table with wrapping text, right-aligned totals, and paired payment sections that fit small screens.
- Pretendard Variable v1.3.9 is bundled for the mobile UI. Matching static Pretendard Regular/Bold files are used for PDFs because the PDF renderer does not expose variable-font weight controls. Source: https://github.com/orioncactus/pretendard. The logo and empty-state illustration are recreated with Flutter drawing/widgets because source assets were not supplied.
- Dependencies: `flutter_riverpod` for shared state; `shared_preferences` for small local data; `file_picker` for image selection and PDF saving; `pdf` for document generation; `share_plus` for device sharing. Font license: `assets/fonts/Pretendard-LICENSE.txt`.

## Assumptions

- Personal Details was not supplied. As agreed, Proceed/Skip goes directly to Dashboard; greeting is generic.
- Logo is optional. Proceed requires an account-type choice.
- All invoice/bank text fields are required. Bank numbers accept 1–10 digits (the requested maximum, not a banking verification rule); bank names reject digits and unsupported symbols. Names are capped at 100 characters, titles at 150, descriptions at 300, and payment terms at 500. Invoice identifiers allow up to 30 letters/digits with hyphens and slashes. Email and 8–128-character passwords are validated; confirmation must match. VAT and shipping are optional and default to zero when empty. Quantity must be positive; price may be zero. VAT is 0–100%. Numeric fields accept plain numbers with up to two decimal places and are capped at one billion. Exponents and nonfinite values are rejected.
- Currency options are NGN/USD/GBP/EUR; no exchange-rate conversion occurs. Dates default to today.
- The sample preview totals are inconsistent. The app computes actual totals instead of reproducing those values.
- Saved-history layout is a simple extension of the supplied empty dashboard.
- The current preview exposes Download and Email only. Saved-invoice persistence remains implemented and tested; there is currently no visible Save action.
- The missing sign-up predecessor is not invented. Social buttons explain that sign-in is unavailable; policy controls show demo information, not invented legal terms.

## Known Limitations

- No remote authentication, OAuth, multi-user separation, synchronization, or production-grade encrypted storage. Do not treat this assessment demo as a banking production app.
- Profile displays the selected type; Receipts and Settings explain that their designs were not provided.
- Email opens the operating system share menu. The user chooses an email app and recipient; delivery is never claimed. Available share targets depend on the device. Web sharing may fall back to a PDF download.
- Web download confirmation means the browser download was initiated. Native save cancellation shows no success.
- Preferences storage fits a small assessment dataset, not large invoice archives. Uploaded logos are resized before storing.
- Pretendard is bundled for offline text rendering; full multilingual script coverage is not guaranteed.
- Visual matching is based on supplied PNGs; original font metadata, exact assets, and interactive Figma behavior were unavailable.

## Presentation

1. Show invalid sign-up, then proceed through or skip profile setup.
2. Create an invoice with two line items; change quantity, VAT and shipping to demonstrate totals.
3. Enter bank details, preview, return to edit, and show preserved values.
4. Download a PDF or open the share menu, and explain the device handoff.
5. Explain the invoice model, local/shared state boundary, error handling and tests.

## What I Would Improve With More Time

Confirm missing designs and prototype transitions; connect authentication and policy URLs; replace preferences with suitable durable/encrypted storage; add broader device testing, localization, and production delivery integrations.
# firstbank
