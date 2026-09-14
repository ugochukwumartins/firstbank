// Starts Flutter, loads device storage, and offers a retry if storage cannot open.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/store.dart';
import 'shared/ui.dart';

// Start with the storage-loading screen before showing the app.
void main() {
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<SharedPreferences> loading = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) => FutureBuilder<SharedPreferences>(
    future: loading,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ProviderScope(
          overrides: [preferencesProvider.overrideWithValue(snapshot.data!)],
          child: const LanceBoxApp(),
        );
      }
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: snapshot.hasError
                ? TextButton(
                    onPressed: () => setState(
                      () => loading = SharedPreferences.getInstance(),
                    ),
                    child: const Text(
                      'Unable to open local storage. Tap to retry.',
                    ),
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Brand(),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(color: blue),
                      ),
                    ],
                  ),
          ),
        ),
      );
    },
  );
}
