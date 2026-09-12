import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lancebox/app/app.dart';
import 'package:lancebox/app/store.dart';

void main() {
  testWidgets('sign-up validates input and skip opens the empty dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LanceBoxApp(),
      ),
    );
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNWidgets(2));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNWidgets(3));
    await tester.enterText(find.byType(TextFormField).at(1), 'password456');
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNWidgets(2));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.byIcon(Icons.check), findsNWidgets(3));
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Skip for now'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome!'), findsOneWidget);
    expect(container.read(appStoreProvider).onboarded, isTrue);
    expect(tester.takeException(), isNull);
  });
}
