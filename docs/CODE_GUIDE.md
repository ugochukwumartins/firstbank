# Reading the LanceBox code

Start with the user journey: sign up → loading screen → profile setup → dashboard → invoice details → bank details → preview.

| What you want to understand or change | File under `lib/` |
| --- | --- |
| App startup and storage setup | `main.dart` |
| Choosing onboarding or dashboard | `app/app.dart` |
| Fonts, colors and default styles | `app/theme.dart`, `shared/colors.dart` |
| Shared profile and saved invoices | `app/app_state.dart` |
| Loading and saving shared data through Riverpod | `app/store.dart` |
| Sign-up timing and navigation | `features/onboarding/onboarding.dart` |
| Sign-up fields and legal links | `features/onboarding/signup_content.dart`, `signup_footer.dart` |
| Profile layout and logo selection | `features/onboarding/profile_setup.dart`, `logo_picker.dart` |
| Invoice navigation and field layout | `features/invoices/editor.dart` |
| Draft values and readiness to continue | `features/invoices/invoice_form_data.dart` |
| One editable invoice item | `features/invoices/invoice_item_editor.dart` |
| Subtotal, VAT and shipping inputs | `features/invoices/invoice_summary.dart` |
| Calculations and saved invoice format | `features/invoices/invoice.dart` |
| Preview actions, document layout and PDF | `features/invoices/preview.dart`, `invoice_document.dart`, `export.dart` |
| Reusable fields, buttons and loading graphics | `shared/widgets/` |
| Text validation rules | `shared/validation.dart` |

## How state works

State means the information the app remembers. Riverpod owns information shared across screens through `appStoreProvider`.

- `ref.watch(appStoreProvider)` reads that information and updates the screen when it changes.
- `ref.read(appStoreProvider.notifier)` gets the object that can save invoices, complete a profile or log out.
- `AppState` is a read-only snapshot. The store publishes a new snapshot after storage succeeds.

Typing, keyboard focus, loading indicators and the current form step belong to their screen. These remain local rather than becoming global providers. `InvoiceFormData` owns the text controllers, checks whether the draft is valid and converts it into an `Invoice`. The editor disposes it when the screen closes.

## Calculations and validation

An item total is quantity multiplied by unit price. Subtotal adds item totals; total adds tax and shipping. Money is stored in minor units (100 means 1.00), so display formatting stays separate from calculation. Required checks control both field errors and whether the next button is enabled.

## Checking a change

Run `dart format .`, `flutter analyze` and `flutter test`. Visual tests compare signup, dashboard, editor and preview against snapshots captured before this refactor. Do not update snapshots just to hide an unexpected design change.

The current preview exposes Download and Email. Saved-invoice storage is supported and tested, but the current layout has no Save button. File pickers and sharing still need checks on a real mobile device.
