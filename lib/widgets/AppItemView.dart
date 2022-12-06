import 'dart:developer';

import 'package:android_native/os/Build.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:varity/model/App.dart';
import 'package:varity/widgets/slider.dart';

import '../VarityApp.dart';

class AppItemView extends StatefulWidget {
  AppItemView(this._app, this.onChanged,
      [this._visibleItemsCount = 0,
      this._withShowcase = false,
      this._showcaseTwo]);
  final App _app;
  final bool _withShowcase;
  final GlobalKey? _showcaseTwo;
  final int _visibleItemsCount;
  final Function() onChanged;

  @override
  _AppItemViewState createState() => _AppItemViewState(_app);
}

class _AppItemViewState extends State<AppItemView> {
  final Controller controller = Get.find();
  double _currentDayVolume = 0;
  double _currentNightVolume = 0;
  double _currentDayBrightness = 0;
  double _currentNightBrightness = 0;
  double _dayVolumeTemp = 0;
  double _nightVolumeTemp = 0;
  double _dayBrightnessTemp = 0;
  double _nightBrightnessTemp = 0;
  final App _app;

  _AppItemViewState(this._app) : super();
  @override
  void initState() {
    super.initState();
    
    setState(() {
      _currentDayVolume = _app.dayVolume.toDouble();
      _currentNightVolume = _app.nightVolume.toDouble();
      _currentDayBrightness = _app.dayBrightness.toDouble();
      _currentNightBrightness = _app.nightBrightness.toDouble();
      log("current day volume $_currentDayVolume");
      log("current night volume $_currentNightVolume");
      log("current day brightness $_currentDayBrightness");
      log("current night brightness $_currentNightBrightness");
      
      // log("currentDaytBrightness $_currentDayBrightness ${_app.toMap()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    var image = widget._app.icon;
    var packageName = widget._app.packageName;
    var appName = widget._app.appName;
    var currentDayBrightness = widget._app.dayBrightness;
    var card = Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        maintainState: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: [
                  Container(
                    child: Image.memory(
                      image,
                      fit: BoxFit.scaleDown,
                      width: 26,
                    ),
                    height: 48,
                    margin: EdgeInsets.only(right: 20),
                  ),
                  Flexible(child: Text(appName))
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /* Volume */
                SizedBox(
                  height: 64,
                  // margin: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          getDayVolumeText(controller.isPremium),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            (!controller.isPremium)
                                ? 'assets/volume.svg'
                                : 'assets/day-volume.svg',
                            height: 32.0,
                          ),
                          Expanded(
                            flex: 1,
                            child: VaritySlider(
                              min: controller.minVolume.toDouble(),
                              max: controller.maxVolume.toDouble(),
                              value: _currentDayVolume,
                              label: _currentDayVolume.round().toString(),
                              divisions: controller.maxVolume,
                              onChangeStart: (value) {
                                _dayVolumeTemp = value;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _currentDayVolume = value;
                                });
                              },
                              onTouchEnd: (value) async {
                                final snackBar = SnackBar(
                                  content: Text(getDayVolumeSnackbarText(
                                      controller.isPremium, appName)),
                                  duration: Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async {
                                      var db = controller.getDatabase();
                                      // await db.open();
                                      await db.apps.updateDayVolume(
                                          packageName, _dayVolumeTemp.round());
                                      setState(() {
                                        _currentDayVolume = _dayVolumeTemp;
                                      });
                                      widget.onChanged();
                                      // await db.close();
                                    },
                                  ),
                                );

                                var db = controller.getDatabase();
                                // await db.open();
                                log("updating day volume for package $packageName to $_currentDayVolume");
                                await db.apps.updateDayVolume(
                                    packageName, _currentDayVolume.round());
                                // await db.close();
                                widget.onChanged();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                if (controller.isPremium)
                  SizedBox(
                    height: 64,
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            "Night Volume",
                            textAlign: TextAlign.center,
                          ),
                          // margin: EdgeInsets.only(top: 10),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image(
                              image: AssetImage('assets/night-volume.png'),
                              width: 32.0,
                              height: 32.0,
                              fit: BoxFit.scaleDown,
                            ),
                            Expanded(
                              flex: 1,
                              child: VaritySlider(
                                min: controller.minVolume.toDouble(),
                                max: controller.maxVolume.toDouble(),
                                value: _currentNightVolume,
                                label: _currentNightVolume.round().toString(),
                                divisions: controller.maxVolume,
                                onTouchEnd: (value) async {
                                  final snackBar = SnackBar(
                                    content: Text(
                                        "Night volume for $appName has changed."),
                                    duration: Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () async {
                                        var db = controller.getDatabase();

                                        await db.apps.updateNightVolume(
                                            packageName,
                                            _nightVolumeTemp.round());
                                        setState(() {
                                          _currentNightVolume =
                                              _nightVolumeTemp;
                                        });
                                      },
                                    ),
                                  );

                                  var db = controller.getDatabase();
                                  log("updating night volume for package $packageName");
                                  await db.apps.updateNightVolume(
                                      packageName, _currentNightVolume.round());

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                onChangeStart: (value) {
                                  _nightVolumeTemp = value;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _currentNightVolume = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Divider(
                  height: 10.0,
                ),
                /* Brightness */
                SizedBox(
                  height: 64,
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          getDayBrightnessText(controller.isPremium),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            (!controller.isPremium)
                                ? 'assets/brightness.svg'
                                : 'assets/day-brightness.svg',
                            height: 32.0,
                          ),
                          Expanded(
                            flex: 1,
                            child: VaritySlider(
                              min: 0,
                              max: 2047,
                              value: _currentDayBrightness,
                              label: _currentDayBrightness.round().toString(),
                              divisions: 2047,
                              onTouchEnd: (value) async {
                                final snackBar = SnackBar(
                                  content: Text(getDayBrightnessSnackbarText(
                                      controller.isPremium, appName)),
                                  duration: Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async {
                                      var db = controller.getDatabase();

                                      await db.apps.updateDayBrightness(
                                          packageName,
                                          _dayBrightnessTemp.round());
                                      setState(() {
                                        _currentDayBrightness =
                                            _dayBrightnessTemp;
                                      });
                                      widget.onChanged();
                                    },
                                  ),
                                );

                                var db = controller.getDatabase();
                                log("updating day brighness for package $packageName to $_currentDayBrightness");
                                await db.apps.updateDayBrightness(
                                    packageName, _currentDayBrightness.round());
                                widget.onChanged();
                                // Find the Scaffold in the widget tree and use
                                // it to show a SnackBar.
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              onChangeStart: (value) {
                                _dayBrightnessTemp = value;
                              },
                              onChanged: (value) {
                                log("onDayBrightnessChanged $value");
                                setState(() {
                                  _currentDayBrightness = value;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                if (controller.isPremium)
                  SizedBox(
                    height: 64,
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            "Night Brightness",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image(
                              image: AssetImage('assets/night-brightness.png'),
                              width: 32.0,
                              height: 32.0,
                              fit: BoxFit.scaleDown,
                            ),
                            Expanded(
                              flex: 1,
                              child: VaritySlider(
                                min: 0,
                                max: 2047,
                                value: _currentNightBrightness,
                                label:
                                    _currentNightBrightness.round().toString(),
                                divisions: 2047,
                                onTouchEnd: (value) async {
                                  final snackBar = SnackBar(
                                    key: Key('night-brightness-snackbar'),
                                    content: Text(
                                        "Night brightness for $appName has changed."),
                                    duration: Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () async {
                                        var db = controller.getDatabase();
                                        await db.apps.updateNightBrightness(
                                            packageName,
                                            _nightBrightnessTemp.round());
                                        setState(() {
                                          _currentNightBrightness =
                                              _dayBrightnessTemp;
                                        });
                                      },
                                    ),
                                  );

                                  var db = controller.getDatabase();
                                  await db.apps.updateDayBrightness(packageName,
                                      _currentNightBrightness.round());
                                  // Find the Scaffold in the widget tree and use
                                  // it to show a SnackBar.
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                onChangeStart: (value) {
                                  _nightBrightnessTemp = value;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _currentNightBrightness = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
      child: widget._withShowcase
          ? Showcase(
              key: widget._showcaseTwo!,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              child: card,
              description:
                  "Tap to view volume and brightness configuration for this app.")
          : card,
    );
  }
}

String getDayVolumeSnackbarText(bool isPremium, String appName) {
  if (isPremium) {
    return "Day Volume for $appName has changed.";
  } else {
    return "Volume for $appName has changed.";
  }
}

String getDayBrightnessSnackbarText(bool isPremium, String appName) {
  if (isPremium) {
    return "Day Brightness for $appName has changed.";
  } else {
    return "Brightness for $appName has changed.";
  }
}

String getDayVolumeText(bool isPremium) {
  if (isPremium) {
    return "Day Volume";
  } else {
    return "Volume";
  }
}

String getDayBrightnessText(bool isPremium) {
  if (isPremium) {
    return "Day Brightness";
  } else {
    return "Brightness";
  }
}
