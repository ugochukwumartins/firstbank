# LanceBox — brief project documentation

**Purpose.** LanceBox is a Flutter mobile invoicing demo based on the supplied case study and designs. Customers complete or skip profile setup, enter invoice and bank details, preview their invoice, and download or share a PDF.

**User journey.** Sign up → loading screen → profile setup → dashboard → invoice details → bank details → preview. Required fields show validation errors, and navigation buttons become available when inputs are valid. Draft values remain available when returning from preview to edit.

**Where the code lives.** `lib/main.dart` opens device storage and starts the app. `lib/app/` contains the theme and shared data. `lib/features/onboarding/` handles sign-up and profile setup. `lib/features/invoices/` contains the dashboard, editor, calculations, preview and PDF generation. `lib/shared/` contains reusable controls, colors, dialogs and validation rules. File-opening comments explain each file’s role; comments beside methods explain actions and important decisions.

**State management.** Riverpod’s `appStoreProvider` owns the shared profile and saved invoices. `ref.watch` reads data and refreshes the screen when it changes; `ref.read(...notifier)` requests actions such as saving. Storage writes finish before a new state snapshot is published. Temporary form values, focus and loading flags stay local to their screen. Controllers are disposed when no longer needed.

**Calculations and validation.** Item total = quantity × unit price; subtotal adds item totals; final total adds VAT and shipping. Money is stored in minor units (100 means 1.00). Bank numbers retain leading zeros and accept at most ten digits. Bank names reject numbers. Quantity must be positive; prices and shipping may be zero; VAT is limited to 0–100%.

**Run and check.** Install Flutter and configure an Android/iOS device or simulator. Run `flutter pub get`, then `flutter run -d <device-id>`. Check changes with `dart format .`, `flutter analyze` and `flutter test`. Tests cover calculations, validation, storage, PDF output, key user flows and visual baselines.

**Current boundaries.** Authentication and social sign-in are demonstrations. Email uses the device share menu; delivery is not confirmed. Invoice saving exists in the store, but the current preview has no visible Save button. Native file picking and sharing require device verification. See `README.md` for setup details and `docs/CODE_GUIDE.md` for the fuller file map.
