// Chooses onboarding or the dashboard from Riverpod’s saved completion flag.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import '../features/onboarding/onboarding.dart';
import '../features/invoices/dashboard.dart';
import 'store.dart';

class LanceBoxApp extends ConsumerWidget {
  const LanceBoxApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'LanceBox',
    theme: buildAppTheme(),
    home: ref.watch(appStoreProvider.select((state) => state.onboarded))
        ? const Dashboard()
        : const Onboarding(),
  );
}
