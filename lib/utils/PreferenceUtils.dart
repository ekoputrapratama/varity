

import 'package:android_native/content/Context.dart';

Future<bool> neverCalled(String id, Context context) async {
  var prefs =  context.getSharedPreferences(id, Context.MODE_PRIVATE);

  final firstTime = await prefs.getBoolean(id, defaultValue: true);
  if(firstTime) {
    prefs.edit().putBoolean(id, false).apply();
  }

  return firstTime;
}