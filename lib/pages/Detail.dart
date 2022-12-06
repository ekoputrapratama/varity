import 'dart:developer';

import 'package:android_native/app/Activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:varity/model/App.dart';
import 'package:varity/widgets/slider.dart';

import '../VarityApp.dart';

class DetailPage extends Activity {
  final App _app;
  final Function _onChanged;

  DetailPage(this._app, this._onChanged) : super();

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends ActivityState<DetailPage> {
  final Controller controller = Get.find();
  double _currentDayVolume = 0;
  double _currentNightVolume = 0;
  double _currentDayBrightness = -1;
  double _currentNightBrightness = 0;
  double _dayVolumeTemp = 0;
  double _nightVolumeTemp = 0;
  double _dayBrightnessTemp = 0;
  double _nightBrightnessTemp = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _currentDayVolume = widget._app.dayVolume.toDouble();
      _currentNightVolume = widget._app.nightVolume.toDouble();
      _currentDayBrightness = widget._app.dayBrightness.toDouble();
      _currentNightBrightness = widget._app.nightBrightness.toDouble();
      // log("currentDaytBrightness $_currentDayBrightness ${_app.toMap()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    var image = widget._app.icon;
    var packageName = widget._app.packageName;
    var appName = widget._app.appName;
    return Scaffold(
      // textDirection: TextDirection.ltr,
      backgroundColor: const Color.fromRGBO(49, 49, 49, 1),
      body: Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 20, top: 10),
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

                                        await db.apps.updateDayVolume(
                                            packageName,
                                            _dayVolumeTemp.round());
                                        setState(() {
                                          _currentDayVolume = _dayVolumeTemp;
                                        });
                                        widget._onChanged();
                                      },
                                    ),
                                  );

                                  var db = controller.getDatabase();
                                  await db.open();
                                  log("updating day volume for package $packageName to $_currentDayVolume");
                                  await db.apps.updateDayVolume(
                                      packageName, _currentDayVolume.round());
                                  await db.close();
                                  widget._onChanged();
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
                                    await db.apps.updateNightVolume(packageName,
                                        _currentNightVolume.round());

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
                                max: 255,
                                value: _currentDayBrightness,
                                label: _currentDayBrightness.round().toString(),
                                divisions: 255,
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
                                        widget._onChanged();
                                      },
                                    ),
                                  );

                                  var db = controller.getDatabase();
                                  log("updating day brighness for package $packageName to $_currentDayBrightness");
                                  await db.apps.updateDayBrightness(packageName,
                                      _currentDayBrightness.round());
                                  widget._onChanged();
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
                                image:
                                    AssetImage('assets/night-brightness.png'),
                                width: 32.0,
                                height: 32.0,
                                fit: BoxFit.scaleDown,
                              ),
                              Expanded(
                                flex: 1,
                                child: VaritySlider(
                                  min: 0,
                                  max: 255,
                                  value: _currentNightBrightness,
                                  label: _currentNightBrightness
                                      .round()
                                      .toString(),
                                  divisions: 255,
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
                                    await db.apps.updateDayBrightness(
                                        packageName,
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
      ),
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
