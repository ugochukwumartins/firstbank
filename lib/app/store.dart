import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/invoices/invoice.dart';
import 'app_state.dart';
export 'app_state.dart';

/// Initialized before the app starts and overridden at the root ProviderScope.
final preferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('Local storage has not been initialized');
});

final appStoreProvider = NotifierProvider<AppStore, AppState>(AppStore.new);

/// Riverpod owns this object. Write to storage first, then publish the new state.
class AppStore extends Notifier<AppState> {
  SharedPreferences get preferences => ref.read(preferencesProvider);

  @override
  AppState build() {
    final preferences = ref.watch(preferencesProvider);
    bool onboarded = false;
    String accountType = '';
    Uint8List? logo;
    List<Invoice> invoices = [];
    String? loadError;
    try {
      onboarded = preferences.getBool('onboarded') ?? false;
      accountType = preferences.getString('accountType') ?? '';
      final encodedLogo = preferences.getString('logo');
      logo = encodedLogo == null ? null : base64Decode(encodedLogo);
      final savedInvoices = preferences.getString('invoices');
      if (savedInvoices != null) {
        final invoiceList = jsonDecode(savedInvoices) as List;
        for (final savedInvoice in invoiceList) {
          final invoiceJson = Map<String, dynamic>.from(savedInvoice as Map);
          invoices.add(Invoice.fromJson(invoiceJson));
        }
      }
    } catch (_) {
      invoices = [];
      loadError =
          'Some saved data could not be loaded. Restart the app to try again.';
    }
    return AppState(
      invoices: invoices,
      onboarded: onboarded,
      accountType: accountType,
      logo: logo,
      loadError: loadError,
    );
  }

  Future<void> completeProfile(String type, Uint8List? bytes) async {
    if (!await preferences.setString('accountType', type)) {
      throw StateError('Save failed');
    }
    if (bytes != null &&
        !await preferences.setString('logo', base64Encode(bytes))) {
      throw StateError('Save failed');
    }
    if (bytes == null && !await preferences.remove('logo')) {
      throw StateError('Save failed');
    }
    if (!await preferences.setBool('onboarded', true)) {
      throw StateError('Save failed');
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      accountType: type,
      logo: bytes,
      clearLogo: bytes == null,
      onboarded: true,
    );
  }

  Future<void> save(Invoice invoice) async {
    if (state.loadError != null) {
      throw StateError('Existing data could not be read');
    }
    final updatedInvoices = [...state.invoices];
    final index = updatedInvoices.indexWhere(
      (savedInvoice) => savedInvoice.id == invoice.id,
    );
    if (index < 0) {
      updatedInvoices.insert(0, invoice);
    } else {
      updatedInvoices[index] = invoice;
    }
    if (!await preferences.setString(
      'invoices',
      jsonEncode(updatedInvoices.map((invoice) => invoice.toJson()).toList()),
    )) {
      throw StateError('Save failed');
    }
    if (!ref.mounted) return;
    state = state.copyWith(invoices: updatedInvoices);
  }

  Future<void> logout() async {
    if (!await preferences.setBool('onboarded', false)) {
      throw StateError('Save failed');
    }
    if (!ref.mounted) return;
    state = state.copyWith(onboarded: false);
  }
}
