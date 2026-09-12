import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lancebox/app/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'profile and logout publish immutable state and persist completion',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final changes = <bool>[];
      container.listen(
        appStoreProvider.select((state) => state.onboarded),
        (_, next) => changes.add(next),
      );
      final original = container.read(appStoreProvider);
      final logo = Uint8List.fromList([1, 2, 3]);
      await container
          .read(appStoreProvider.notifier)
          .completeProfile('Freelancer', logo);
      final profile = container.read(appStoreProvider);
      logo[0] = 9;
      expect(original.onboarded, isFalse);
      expect(profile.onboarded, isTrue);
      expect(profile.logo!.first, 1);
      expect(() => profile.logo![0] = 8, throwsUnsupportedError);
      expect(prefs.getBool('onboarded'), isTrue);
      await container.read(appStoreProvider.notifier).logout();
      expect(container.read(appStoreProvider).onboarded, isFalse);
      expect(profile.onboarded, isTrue);
      expect(changes, [true, false]);
      expect(prefs.getBool('onboarded'), isFalse);
    },
  );
}
