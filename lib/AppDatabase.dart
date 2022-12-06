import 'dart:developer';

import 'package:sonicdb/annotation.dart';
import 'package:sonicdb/sonicdb.dart';

import 'model/App.dart';
import 'collection/AppCollection.dart';

part 'AppDatabase.g.dart';

@Database(
    name: "varity",
    entities: [App],
    version: 2,
    useDeviceProtectedStorage: true)
abstract class AppDatabase extends SonicDb {
  late AppCollection apps;

  static AppDatabase getInstance() {
    return _AppDatabase.getInstance();
  }

  @override
  void onCreate() {
    log("on database created");
  }

  @override
  void onUpgrade() {
    // TODO: implement onUpgrade
    log("on database upgraded");
  }
}
