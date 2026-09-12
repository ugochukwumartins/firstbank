import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lancebox/app/store.dart';
import 'package:lancebox/features/invoices/editor.dart';

void main() {
  testWidgets('last invoice item can be deleted and a new item added', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: InvoiceEditor()),
      ),
    );
    await tester.scrollUntilVisible(
      find.byWidgetPredicate((widget) => widget is IconButton && widget.tooltip == 'Remove item 1'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((widget) => widget is IconButton && widget.tooltip == 'Remove item 1'));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((widget) => widget is IconButton && widget.tooltip == 'Remove item 1'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Next'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('Add New Item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add New Item'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byWidgetPredicate((widget) => widget is IconButton && widget.tooltip == 'Remove item 1'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byWidgetPredicate((widget) => widget is IconButton && widget.tooltip == 'Remove item 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
