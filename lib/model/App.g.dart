// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'App.dart';

// **************************************************************************
// EntityPartGenerator
// **************************************************************************

class _App implements App {
  _App({Map? value}) {
    if (value != null) {
      this.id = value['_id'];
      this.packageName = value['package_name'];
      this.appName = value['name'];
      this.dayVolume = value['day_volume'];
      this.nightVolume = value['night_volume'];
      this.dayBrightness = value['day_brightness'];
      this.nightBrightness = value['night_brightness'];
      this.icon = value['icon'];
    }
  }

  int id = 0;

  String packageName = "";

  String appName = "";

  int dayVolume = 0;

  int nightVolume = 0;

  int dayBrightness = 0;

  int nightBrightness = 0;

  late Uint8List icon;

  @override
  Map toMap({bool withPrimaryKey = false}) {
    var data = Map();
    if (withPrimaryKey) {
      data['_id'] = this.id;
    }
    data['package_name'] = this.packageName;
    data['name'] = this.appName;
    data['day_volume'] = this.dayVolume;
    data['night_volume'] = this.nightVolume;
    data['day_brightness'] = this.dayBrightness;
    data['night_brightness'] = this.nightBrightness;
    data['icon'] = this.icon;
    return data;
  }
}
