/// Shared rules used by inline errors and navigation-button readiness.
String? textError(String? value, {int maxLength = 200}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'This field is required';
  if (text.length > maxLength) return 'Use $maxLength characters or fewer';
  if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text)) {
    return 'Enter text containing letters or numbers';
  }
  return null;
}

String? nameError(String? value) => textError(value, maxLength: 100);
String? titleError(String? value) => textError(value, maxLength: 150);
String? descriptionError(String? value) => textError(value, maxLength: 300);
String? termsError(String? value) => textError(value, maxLength: 500);

String? bankNumberError(String? value) =>
    RegExp(r'^[0-9]{1,10}$').hasMatch(value ?? '') ? null : 'Enter 1–10 digits';

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

String? invoiceNumberError(String? value) =>
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9/\-]{0,29}$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Use 1–30 letters or digits, with / or -';

String? emailError(String? value) {
  final email = value?.trim() ?? '';
  if (email.length > 254 ||
      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? passwordError(String? value) {
  if ((value?.length ?? 0) < 8) return 'Use at least 8 characters';
  if (value!.length > 128) return 'Use 128 characters or fewer';
  if (value.trim().isEmpty) return 'Password cannot contain only spaces';
  return null;
}

String? confirmationError(String? value, String password) =>
    passwordError(value) ??
    (value == password ? null : 'Passwords do not match');
