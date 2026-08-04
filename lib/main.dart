import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/local_storage/shared_prefs_storage.dart';
import 'di/repository_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Storage must exist before the first provider reads it, so it is created
  // here and injected as an override rather than resolved lazily.
  final storage = await SharedPrefsStorage.create();

  runApp(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      child: const SuvioQuickApp(),
    ),
  );
}
