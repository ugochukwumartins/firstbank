import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lancebox/app/app.dart';
import 'package:lancebox/app/store.dart';
import 'package:lancebox/features/invoices/editor.dart';
import 'package:lancebox/features/invoices/preview.dart';
import 'package:lancebox/features/invoices/invoice.dart';

void main() {
  for (final screen in ['signup', 'dashboard', 'editor', 'preview']) {
    testWidgets('$screen design stays unchanged', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'onboarded': screen != 'signup'});
      final container = ProviderContainer(overrides: [preferencesProvider.overrideWithValue(await SharedPreferences.getInstance())]);
      addTearDown(container.dispose);
      const captureKey = Key('screen-capture');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const RepaintBoundary(key: captureKey, child: LanceBoxApp())));
      await tester.pumpAndSettle();
      final invoice = Invoice(id: 'visual', number: '0001', client: 'Peter Abu', sender: 'Jane Doe', title: 'Website Design', currency: 'NGN', date: DateTime(2026, 9, 12), items: const [InvoiceItem(description: 'Design work', quantity: 2, unitPrice: 300000)], vat: 7.5, shipping: 50000, bankNumber: '0123456789', bankName: 'Lance Bank', accountName: 'Jane Doe', terms: 'Due on receipt');
      if (screen == 'editor' || screen == 'preview') {
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.push(MaterialPageRoute<void>(builder: (_) => screen == 'editor' ? InvoiceEditor(invoice: invoice) : InvoicePreview(invoice: invoice)));
        await tester.pumpAndSettle();
      }
      await expectLater(find.byKey(captureKey), matchesGoldenFile('goldens/$screen.png'));
    });
  }
}
