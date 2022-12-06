// library app_collection;

import 'dart:async';

import 'package:sonicdb/annotation.dart';
import 'package:sonicdb/operation.dart';
import 'package:sonicdb/sonicdb.dart';

import '../model/App.dart';

part 'AppCollection.g.dart';

@Collection(App)
abstract class AppCollection {
  factory AppCollection(SonicDb db) = _AppCollection;
  // final SonicDb db;
  @Query("select * from apps")
  Future<List<App>> getApps();
  @Query("select * from apps where package_name = :packageName")
  Future<App?> getApp(String packageName);

  @Query("select day_volume from apps where package_name = :packageName")
  Future<int> getDayVolume(String packageName);

  // @Query(
  //     "UPDATE apps set day_volume = :volume where package_name = :packageName")
  @Update(conditions: ["package_name = :packageName"])
  Future updateDayVolume(String packageName, int dayVolume);
  // @Query(
  //     "UPDATE apps set night_volume = :volume where package_name = :packageName")
  @Update(conditions: ["package_name = :packageName"])
  Future updateNightVolume(String packageName, int nightVolume);

  // @Query(
  //     "UPDATE apps set day_volume = :volume where package_name = :packageName")
  @Update(conditions: ["package_name = :packageName"])
  Future updateDayBrightness(String packageName, int dayBrightness);
  // @Query(
  //     "UPDATE apps set night_volume = :volume where package_name = :packageName")
  @Update(conditions: ["package_name = :packageName"])
  Future updateNightBrightness(String packageName, int nightBrightness);

  @Update()
  UpdateOperation update();
  // void insertAll(List<App> apps);
  @Insert()
  Future add(App app);

  @Insert()
  Future addAll(List<App> apps);
}
