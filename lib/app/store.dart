import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/invoices/invoice.dart';

/// Initialized before the app starts and overridden at the root ProviderScope.
final preferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('Local storage has not been initialized');
});

final appStoreProvider = NotifierProvider<AppStore, AppState>(AppStore.new);

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
      final raw = preferences.getString('invoices');
      invoices = raw == null
          ? []
          : (jsonDecode(raw) as List)
                .map(
                  (e) => Invoice.fromJson(Map<String, dynamic>.from(e as Map)),
                )
                .toList();
    } catch (_) {
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
    final next = [...state.invoices];
    final index = next.indexWhere((e) => e.id == invoice.id);
    if (index < 0) {
      next.insert(0, invoice);
    } else {
      next[index] = invoice;
    }
    if (!await preferences.setString(
      'invoices',
      jsonEncode(next.map((e) => e.toJson()).toList()),
    )) {
      throw StateError('Save failed');
    }
    if (!ref.mounted) return;
    state = state.copyWith(invoices: next);
  }

  Future<void> logout() async {
    if (!await preferences.setBool('onboarded', false)) {
      throw StateError('Save failed');
    }
    if (!ref.mounted) return;
    state = state.copyWith(onboarded: false);
  }
}
