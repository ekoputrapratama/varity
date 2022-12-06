import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'VarityApp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://610ef210c0b24a95abd85f06920ea639@o4504281061851136.ingest.sentry.io/4504281098878976';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(VarityApp()),
  );
}
