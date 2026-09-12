import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lancebox/app/store.dart';
import 'package:lancebox/features/invoices/invoice.dart';
import 'package:lancebox/features/invoices/export.dart';

Invoice sample({String title = 'Design'}) => Invoice(
  id: '1',
  number: '0001',
  client: 'Client',
  sender: 'Sender',
  title: title,
  currency: 'NGN',
  date: DateTime(2026, 9, 11),
  items: const [
    InvoiceItem(description: 'Design', quantity: 2, unitPrice: 300000),
    InvoiceItem(description: 'Support', quantity: 1.5, unitPrice: 10001),
  ],
  vat: 7.5,
  shipping: 50000,
  bankNumber: '0123456789',
  bankName: 'Lance Bank',
  accountName: 'Sender',
  terms: 'Due on receipt',
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('fractional quantities, VAT and shipping use rounded minor units', () {
    final invoice = sample();
    expect(invoice.items.last.total, 15002);
    expect(invoice.subtotal, 615002);
    expect(invoice.tax, 46125);
    expect(invoice.total, 711127);
    expect(money(invoice.total), 'NGN 7,111.27');
  });
  test('reject invalid numerical inputs', () {
    for (final value in ['NaN', 'Infinity', '-1', 'abc', '']) {
      expect(nonNegativeNumber(value), isNotNull);
    }
    expect(positiveNumber('0'), isNotNull);
    expect(nonNegativeNumber('0'), isNull);
  });
  test('invoice round trip preserves account leading zero and totals', () {
    final invoice = Invoice.fromJson(
      jsonDecode(jsonEncode(sample().toJson())) as Map<String, dynamic>,
    );
    expect(invoice.bankNumber, '0123456789');
    expect(invoice.total, sample().total);
  });
  test('saved invoices survive reload and edits do not duplicate', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final store = container.read(appStoreProvider.notifier);
    await store.save(sample());
    await store.save(sample(title: 'Updated'));
    final restored = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(restored.dispose);
    final reopened = restored.read(appStoreProvider);
    expect(reopened.invoices.length, 1);
    expect(reopened.invoices.single.title, 'Updated');
  });
  test('corrupt saved data is not silently overwritten', () async {
    SharedPreferences.setMockInitialValues({'invoices': 'broken'});
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final store = container.read(appStoreProvider.notifier);
    expect(container.read(appStoreProvider).loadError, isNotNull);
    await expectLater(store.save(sample()), throwsStateError);
  });
  test('export produces a PDF document', () async {
    final bytes = await invoicePdf(sample(), null);
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });
}
