// Checks typed values. A null result means valid; a message explains an error.

import '../features/invoices/invoice.dart' show nonNegativeNumber;

/// Shared rules used by inline errors and navigation-button readiness.
// Require meaningful text and enforce the supplied maximum length.
String? textError(String? value, {int maxLength = 200}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'This field is required';
  if (text.length > maxLength) return 'Use $maxLength characters or fewer';
  if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text)) {
    return 'Enter text containing letters or numbers';
  }
  return null;
}

// Limit names to 100 characters.
String? nameError(String? value) => textError(value, maxLength: 100);
// Limit invoice titles to 150 characters.
String? titleError(String? value) => textError(value, maxLength: 150);
// Limit each item description to 300 characters.
String? descriptionError(String? value) => textError(value, maxLength: 300);
// Limit payment terms to 500 characters.
String? termsError(String? value) => textError(value, maxLength: 500);

// Accept only one to ten digits; this does not verify a bank account.
String? bankNumberError(String? value) =>
    RegExp(r'^[0-9]{1,10}$').hasMatch(value ?? '') ? null : 'Enter 1–10 digits';

// Allow letters and normal name punctuation, but reject numbers.
String? bankNameError(String? value) {
  final error = nameError(value);
  if (error != null) return error;
  if (!RegExp(
    r"^[\p{L}\p{M}\s&.'’()\-]+$",
    unicode: true,
  ).hasMatch(value!.trim())) {
    return 'Bank name cannot contain numbers or special symbols';
  }
  return null;
}

// Allow a short identifier containing letters, digits, slashes or hyphens.
String? invoiceNumberError(String? value) =>
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9/\-]{0,29}$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Use 1–30 letters or digits, with / or -';

// Check email-shaped text; this does not prove the address exists.
String? emailError(String? value) {
  final email = value?.trim() ?? '';
  if (email.length > 254 ||
      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

// Require 8–128 characters and reject whitespace-only passwords.
String? passwordError(String? value) {
  if ((value?.length ?? 0) < 8) return 'Use at least 8 characters';
  if (value!.length > 128) return 'Use 128 characters or fewer';
  if (value.trim().isEmpty) return 'Password cannot contain only spaces';
  return null;
}

// Apply password rules and check that both password entries match.
String? confirmationError(String? value, String password) =>
    passwordError(value) ??
    (value == password ? null : 'Passwords do not match');

// Treat an empty shipping charge as optional; otherwise check its amount.
String? shippingError(String? value) =>
    value == null || value.trim().isEmpty ? null : nonNegativeNumber(value);

// Allow blank VAT or a valid percentage from zero to one hundred.
String? vatError(String? value) => value == null || value.trim().isEmpty
    ? null
    : nonNegativeNumber(value) ??
          ((double.tryParse(value) ?? 0) > 100 ? 'VAT must be 0–100%' : null);
