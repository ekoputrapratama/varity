

import 'package:android_native/os/Build.dart';

bool isAtLeastM() {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M;
}
bool isPriorM() {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.M;
}

bool isAtLeastO() {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O;
}
bool isPriorO() {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.O;
}