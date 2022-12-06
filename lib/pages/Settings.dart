import 'dart:developer';
import 'dart:io';

import 'package:android_native/app/Activity.dart';
import 'package:android_native/content/Context.dart';
import 'package:android_native/content/SharedPreferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:simple_time_range_picker/simple_time_range_picker.dart';
import 'package:intl/intl.dart';
import 'package:varity/widgets/slider.dart';
import '../VarityApp.dart';

class _SettingTile extends StatefulWidget {
  final void Function()? onTap;
  final String title;
  final String? subtitle;
  final Widget? child;
  final bool enabled;
  final Widget? icon;

  _SettingTile(
      {this.onTap,
      this.title = "",
      this.subtitle,
      this.child,
      this.icon,
      this.enabled = true});

  @override
  State<StatefulWidget> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          ListTile(
            enabled: widget.enabled,
            leading: Container(
                width: 28,
                child: Center(
                  child: widget.icon,
                )),
            contentPadding: EdgeInsets.all(10),
            title: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                widget.title,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: (!widget.enabled) ? Colors.white10 : Colors.white70),
              ),
            ),
            subtitle: Text(
              widget.subtitle ?? "",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.normal,
                  color: (!widget.enabled) ? Colors.white10 : Colors.white70),
            ),
            trailing: widget.child,
            onTap: widget.onTap,
            // dense: true,
            // wrap only if th
          ),
          Divider(
            height: 0.0,
          )
        ],
      ),
    );
  }
}

class SettingsPage extends Activity {
  SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ActivityState<SettingsPage> {
  bool _autoSave = false;
  bool _disableOnPlayback = false;
  bool _backupToCloud = false;
  bool _differentiateState = false;
  int _defaultBrightness = 0;
  int _defaultVolume = 0;
  TimeOfDay _dayStartTime = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _dayEndTime = TimeOfDay(hour: 18, minute: 0);
  late SharedPreferences prefs;
  final Controller controller = Get.find();

  Future _initSettings() async {
    var autoSave = await prefs.getBoolean("auto_save", defaultValue: true);
    var disableOnPlayback =
        await prefs.getBoolean("disable_on_playback", defaultValue: true);
    var backupToCloud =
        await prefs.getBoolean("backup_to_cloud", defaultValue: false);
    var defaultBrightness =
        await prefs.getInt("default_brightness", defaultValue: 127);
    var defaultVolume = await prefs.getInt("default_volume",
        defaultValue: (controller.maxVolume / 2).round());

    var differentiateState =
        await prefs.getBoolean("differentiate_state", defaultValue: false);

    var timeRange =
        await prefs.getString('day_time', defaultValue: "06:00-18:00");
    var startTimeStr = timeRange!.split("-")[0];

    var startTime = TimeOfDay(
      hour: int.parse(startTimeStr.split(":")[0]),
      minute: int.parse(startTimeStr.split(":")[1]),
    );

    var endTimeStr = timeRange.split("-")[1];
    var endTime = TimeOfDay(
      hour: int.parse(endTimeStr.split(":")[0]),
      minute: int.parse(endTimeStr.split(":")[1]),
    );
    setState(() {
      _defaultBrightness = defaultBrightness!;
      _defaultVolume = defaultVolume!;
      _dayStartTime = startTime;
      _dayEndTime = endTime;
      _autoSave = autoSave;
      _disableOnPlayback = disableOnPlayback;
      _backupToCloud = backupToCloud;
      _differentiateState = differentiateState;
    });
  }

  @override
  void initState() {
    super.initState();
    prefs = getSharedPreferences("varity", Context.MODE_PRIVATE);
    _initSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        // shrinkWrap: true,
        children: [
          _SettingTile(
            title: 'Auto Save',
            enabled: true,
            icon: SvgPicture.asset('assets/diskette.svg', width: 28),
            subtitle:
                'Automatically save your volume/brightness state when you change your volume/brightness in another app.',
            child: Switch(
              value: _autoSave,
              onChanged: (val) {},
            ),
            onTap: () async {
              var oldAutoSave = await prefs.getBoolean('auto_save');
              var success = await prefs
                  .edit()
                  .putBoolean('auto_save', !oldAutoSave)
                  .commit();
              var newAutoSave = await prefs.getBoolean('auto_save');
              if (success) {
                setState(() {
                  _autoSave = newAutoSave;
                });
                log("auto save value changed from $oldAutoSave to $newAutoSave");
              }
            },
          ),
          _SettingTile(
            title: 'Disable on media playback',
            icon: SvgPicture.asset('assets/musical-note.svg', width: 28),
            subtitle:
                'Prevent Varity from changing the volume when there is a music playing.',
            child: Switch(
              value: _disableOnPlayback,
              onChanged: (val) {
                log("disable_on_playback value changed to $val");
              },
            ),
            onTap: () async {
              var oldValue = await prefs.getBoolean('disable_on_playback');
              var success = await prefs
                  .edit()
                  .putBoolean('disable_on_playback', !oldValue)
                  .commit();
              var newValue = await prefs.getBoolean('disable_on_playback');
              if (success) {
                setState(() {
                  _disableOnPlayback = newValue;
                });
                log("disable_on_playback value changed from $oldValue to $newValue");
              }
            },
          ),
          _SettingTile(
            title: "Default Volume",
            subtitle: "Set default volume for new app.",
            icon: SvgPicture.asset(
              'assets/volume.svg',
              height: 28.0,
            ),
            onTap: () {
              Widget okButton = TextButton(
                child: Text("Ok"),
                onPressed: () async {
                  Navigator.of(context).pop(); //Will close the dialog
                  // Navigator.of(context).pop();
                  var oldValue = await prefs.getInt('default_volume');
                  var success = await prefs
                      .edit()
                      .putInt('default_volume', _defaultVolume)
                      .commit();
                  var newValue = await prefs.getInt('default_volume');
                  if (success) {
                    setState(() {
                      _defaultVolume = newValue!;
                    });
                    log("default_volume value changed from $oldValue to $newValue");
                  }
                },
              );
              Widget cancelButton = TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); //Will close the dialog
                  // Navigator.of(context).pop();
                },
              );
              AlertDialog dialog = AlertDialog(
                title: Text('Default Volume'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    height: 50,
                    child: StatefulBuilder(
                      builder: (context, state) => VaritySlider(
                        min: controller.minVolume.toDouble(),
                        max: controller.maxVolume.toDouble(),
                        value: _defaultVolume.toDouble(),
                        label: _defaultVolume.round().toString(),
                        divisions: 255,
                        onChanged: (value) {
                          state(() {
                            _defaultVolume = value.round();
                          });
                        },
                      ),
                    ),
                  ),
                ]),
                actions: [okButton, cancelButton],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return dialog;
                },
              );
            },
          ),
          _SettingTile(
            title: "Default Brightness",
            subtitle: "Set default brightness for new app.",
            icon: SvgPicture.asset(
              'assets/brightness.svg',
              height: 32.0,
            ),
            onTap: () {
              Widget okButton = TextButton(
                child: Text("Ok"),
                onPressed: () async {
                  Navigator.of(context).pop(); //Will close the dialog
                  // Navigator.of(context).pop();
                  var oldValue = await prefs.getInt('default_brightness');
                  var success = await prefs
                      .edit()
                      .putInt('default_brightness', _defaultBrightness)
                      .commit();
                  var newValue = await prefs.getInt('default_brightness');
                  if (success) {
                    setState(() {
                      _defaultBrightness = newValue!;
                    });
                    log("default_brightness value changed from $oldValue to $newValue");
                  }
                },
              );
              Widget cancelButton = TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); //Will close the dialog
                  // Navigator.of(context).pop();
                },
              );
              AlertDialog dialog = AlertDialog(
                title: Text('Default Brightness'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    height: 50,
                    child: StatefulBuilder(
                      builder: (context, state) => VaritySlider(
                        min: 0,
                        max: 255,
                        value: _defaultBrightness.toDouble(),
                        label: _defaultBrightness.round().toString(),
                        divisions: 255,
                        onChanged: (value) {
                          state(() {
                            _defaultBrightness = value.round();
                          });
                        },
                      ),
                    ),
                  ),
                ]),
                actions: [okButton, cancelButton],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return dialog;
                },
              );
            },
          )
          // _SettingTile(
          //   enabled: controller.isPremium,
          //   title: "Backup your configuration",
          //   icon: SvgPicture.asset('assets/cloud-backup.svg',
          //       width: 28,
          //       color:
          //           (!controller.isPremium) ? Colors.white10 : Colors.white70),
          //   subtitle:
          //       "Backup your apps configuration to our cloud so you can restore it later.",
          //   child: Switch(
          //     value: _backupToCloud,
          //     onChanged: (val) {
          //       log("_backupToCloud value changed to $val");
          //     },
          //   ),
          //   onTap: () async {
          //     var oldValue = await prefs.getBoolean('backup_to_cloud');
          //     var success = await prefs
          //         .edit()
          //         .putBoolean('backup_to_cloud', !oldValue)
          //         .commit();
          //     var newValue = await prefs.getBoolean('backup_to_cloud');
          //     if (success) {
          //       setState(() {
          //         _backupToCloud = newValue;
          //       });
          //       log("backup_to_cloud value changed from $oldValue to $newValue");
          //     }
          //   },
          // ),
          // _SettingTile(
          //     enabled: controller.isPremium,
          //     title: "Differentiate Day & Night State",
          //     subtitle:
          //         "Differentiate your volume/brightness state for day time and night time.",
          //     icon: SvgPicture.asset('assets/day-and-night.svg',
          //         width: 28,
          //         color: (!controller.isPremium)
          //             ? Colors.white10
          //             : Colors.white70),
          //     child: Switch(
          //       value: _differentiateState,
          //       onChanged: (val) {
          //         log("_differentiateState value changed to $val");
          //       },
          //     ),
          //     onTap: () async {
          //       var oldValue = await prefs.getBoolean('differentiate_state',
          //           defaultValue: false);
          //       var success = await prefs
          //           .edit()
          //           .putBoolean('differentiate_state', !oldValue)
          //           .commit();
          //       var newValue = await prefs.getBoolean('differentiate_state',
          //           defaultValue: false);
          //       if (success) {
          //         setState(() {
          //           _differentiateState = newValue;
          //         });
          //         log("differentiate_state value changed from $oldValue to $newValue");
          //       }
          //     }),
          // _SettingTile(
          //   enabled: controller.isPremium && _differentiateState,
          //   title: "Day time",
          //   icon: SvgPicture.asset('assets/sunny-day.svg',
          //       width: 28,
          //       color:
          //           (!controller.isPremium) ? Colors.white10 : Colors.white70),
          //   subtitle:
          //       "Set time range when Varity should set volume for daytime volume.",
          //   onTap: () async {
          //     TimeRangePicker.show(
          //       startTime: _dayStartTime,
          //       endTime: _dayEndTime,
          //       context: context,
          //       onSubmitted: (value) async {
          //         var now = DateTime.now();
          //         var startTime = DateFormat('HH:mm').format(DateTime(
          //             now.year,
          //             now.month,
          //             now.day,
          //             value.startTime.hour,
          //             value.startTime.minute));
          //         var endTime = DateFormat('HH:mm').format(DateTime(
          //             now.year,
          //             now.month,
          //             now.day,
          //             value.endTime.hour,
          //             value.endTime.minute));
          //         var dayTime = "${startTime}-${endTime}";
          //         var success = await prefs
          //             .edit()
          //             .putString('day_time', dayTime)
          //             .commit();
          //         if (success) {
          //           _dayStartTime = TimeOfDay(
          //             hour: int.parse(startTime.split(":")[0]),
          //             minute: int.parse(startTime.split(":")[1]),
          //           );

          //           _dayEndTime = TimeOfDay(
          //             hour: int.parse(endTime.split(":")[0]),
          //             minute: int.parse(endTime.split(":")[1]),
          //           );
          //           log("result ${startTime}-${endTime}");
          //         }
          //       },
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
