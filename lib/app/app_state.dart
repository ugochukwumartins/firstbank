import 'dart:typed_data';
import '../features/invoices/invoice.dart';

/// A read-only snapshot of the profile and invoices on this device.
class AppState {
  final List<Invoice> invoices;
  final bool onboarded;
  final String accountType;
  final Uint8List? logo;
  final String? loadError;

  AppState({
    List<Invoice> invoices = const [],
    this.onboarded = false,
    this.accountType = '',
    Uint8List? logo,
    this.loadError,
  }) : invoices = List.unmodifiable(invoices),
       logo = logo == null
           ? null
           : Uint8List.fromList(logo).asUnmodifiableView();

  AppState copyWith({
    List<Invoice>? invoices,
    bool? onboarded,
    String? accountType,
    Uint8List? logo,
    bool clearLogo = false,
  }) => AppState(
    invoices: invoices ?? this.invoices,
    onboarded: onboarded ?? this.onboarded,
    accountType: accountType ?? this.accountType,
    logo: clearLogo ? null : logo ?? this.logo,
    loadError: loadError,
  );
}
