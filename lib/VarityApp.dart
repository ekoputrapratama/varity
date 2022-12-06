import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:android_native/app/Application.dart';
import 'package:android_native/content/Context.dart';
import 'package:android_native/content/pm/ApplicationInfo.dart';
import 'package:android_native/content/pm/ResolveInfo.dart';
import 'package:android_native/media/AudioManager.dart';
import 'package:android_native/os/Build.dart';

import 'package:android_native/content/Intent.dart' as Native;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:varity/constants.dart';
import 'package:varity/pages/About.dart';
import 'package:varity/pages/Upgrade.dart';

import 'model/App.dart';
import 'pages/Loading.dart';
import 'pages/Login.dart';
import 'pages/SnapshotError.dart';
import 'pages/Home.dart';
import 'pages/Settings.dart';
import 'AppDatabase.dart';

const String AUTO_SAVE_KEY = "auto_save";
const String DAY_TIME_KEY = "day_time";

// ignore: must_be_immutable
class VarityApp extends Application {
  late final Controller controller = Get.put(Controller(this));
  final List<int> carrierIds = [789, 1537, 787, 788, 792, 1978, 1977];

  //Event Channel creation
  // static const stream = const EventChannel('poc.deeplink.flutter.dev/events');
  StreamController<String> _stateController = StreamController();
  Stream<String> get state => _stateController.stream;
  Sink<String> get stateSink => _stateController.sink;

  VarityApp() : super();
  //Checking application start by deep link
  // startUri().then(_onRedirected);task
  //Checking broadcast stream, if deep link was clicked in opened appication
  // stream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  // }

  Future<String?> startUri() async {
    try {
      return invokeMethod<String>('initialLink');
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }

  // void _onRedirected(String? uri) {
  //   // Here can be any uri analysis, checking tokens etc, if it’s necessary
  //   // Throw deep link URI into the BloC's stream
  //   if (uri != null) stateSink.add(uri);
  // }
  double getMaxBrightness() {
    String manufacturer = Build.MANUFACTURER;
    String model = Build.MODEL;
    developer.log("MANUFACTURER ${Build.MANUFACTURER}");
    developer.log("MODEL ${Build.MODEL}");
    if (maxBrightnessMap.keys.contains("$manufacturer $model")) {
      return maxBrightnessMap["$manufacturer $model"]!;
    }
    return maxBrightnessMap['default']!;
  }

  Future<void> _initialization() async {
    developer.log("initializing Application");

    await super.init();

    var brightness = getMaxBrightness();
    if (brightness > 0) {
      controller.maxBrightness = brightness;
    }

    var audioManager = getApplicationContext()
        .getSystemService(Context.AUDIO_SERVICE) as AudioManager;
    controller.maxVolume =
        await audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
    controller.minVolume =
        await audioManager.getStreamMinVolume(AudioManager.STREAM_MUSIC);

    developer.log("max volume ${controller.maxVolume}");
    developer.log("min volume ${controller.minVolume}");
    // await UnityAds.init(
    //   gameId: '5037701',
    //   testMode: kDebugMode,
    //   onComplete: () => print('UnityAds : Initialization Complete'),
    //   onFailed: (error, message) =>
    //       print('UnityAds : Initialization Failed: $error $message'),
    // );

    // await UnityAds.load(
    //   placementId: 'Rewarded_Android',
    //   onComplete: (adUnitId) =>
    //       print('UnityMediation : Rewarded Ad Load Complete $adUnitId'),
    //   onFailed: (adUnitId, error, message) => print(
    //       'UnityMediation : Rewarded Ad Load Failed $adUnitId: $error $message'),
    // );

    try {
      await controller.initPlatformState(getApplicationContext());
    } catch (e) {
      developer.log("Error $e");
    }
  }

  void destroy() async {
    // Firestore.FirebaseFirestore.instance.clearPersistence();
    _stateController.close();

    // await FlutterInappPurchase.instance.endConnection;
  }

  @override
  VoidCallback? get onDispose => destroy;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return GetMaterialApp(
            home: SnapshotErrorPage(
              snapshot: snapshot,
            ),
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color.fromRGBO(49, 49, 49, 1),
              colorScheme: ColorScheme.fromSwatch().copyWith(secondary: color),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(
            title: 'Varity',
            routes: <String, WidgetBuilder>{
              '/settings': (BuildContext context) => SettingsPage(),
              '/login': (BuildContext context) => LoginPage(),
              '/about': (BuildContext context) => AboutPage(),
              '/upgrade': (BuildContext context) => UpgradePage()
            },
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color.fromRGBO(49, 49, 49, 1),
              primaryColor: Colors.blue,
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Colors.blueAccent, primary: Colors.blue),
            ),
            home: ShowCaseWidget(
              builder: Builder(builder: (context) {
                return HomePage(title: 'Varity');
              }),
            ),
          );
        }

        return GetMaterialApp(
          home: LoadingPage(),
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color.fromRGBO(49, 49, 49, 1),
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
          ),
        );
      },
    );
  }
}

class Controller extends GetxController {
  String? cacheDir;
  MethodChannel _channel =
      const MethodChannel("com.mixaline.varity/foreground_channel");

  int maxVolume = 0;
  int minVolume = 0;
  double maxBrightness = 0.0;
  bool isPremium = false;
  AppDatabase db = AppDatabase.getInstance();

  var hasFocus = false.obs;
  final _random = Random();
  int _randomInt(int min, int max) => min + _random.nextInt(max - min);

  VarityApp _app;
  Controller(this._app);
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(Context context) async {}

  VarityApp getRootWidget() {
    return _app;
  }

  Future showAboutPage() async {
    await _channel.invokeMethod("about");
  }

  Future invokeMethod(String method, [Map? data]) async {
    return _channel.invokeMethod(method, data);
  }

  // start VarityAccessibilityService and return the state of the
  // Accessibilty service if it's already running or not
  Future<dynamic> startAccessibilityService() async {
    await _channel.invokeMethod("start");
    final running = await _channel.invokeMethod("isRunning");
    return running;
  }

  AppDatabase getDatabase() {
    return db;
  }

  // bool _isSystemApp(ApplicationInfo info) {
  //   return (info.flags & ApplicationInfo.FLAG_SYSTEM) ==
  //       ApplicationInfo.FLAG_SYSTEM;
  // }

  App _parseApp(ApplicationInfo appInfo, Context context) {
    var app = App();
    app.appName = appInfo.nonLocalizedLabel ??
        appInfo.loadLabel(context.getPackageManager());
    app.packageName = appInfo.packageName;
    app.icon = appInfo.loadIcon(context.getPackageManager());
    return app;
  }

  // get all apps from database but if it's empty that means this is the
  // first run of this app or user clear the data of this app. If so then
  // we need to get all activity from PackageManager
  // that define action MAIN and category LAUNCHER/HOME in their
  // manifest and save it to database so we can access the data faster on the
  // the next run
  Future<List<App>> getApps(Context context) async {
    await db.init();
    var apps = await db.apps.getApps();
    if (apps.isEmpty) {
      developer.log("building apps list");
      var launcherIntent = Native.Intent(action: Native.Intent.ACTION_MAIN);
      launcherIntent.addCategory(Native.Intent.CATEGORY_HOME);
      // launcherIntent.addCategory(Native.Intent.CATEGORY_HOME);
      List<ResolveInfo> launcherApps = (await context
              .getPackageManager()
              .queryIntentActivities(launcherIntent, 0))
          .where((app) => app.loadLabel().isNotEmpty)
          .toList();
      List<String> launcherNames =
          launcherApps.map((e) => e.loadLabel()).toList();

      var intent = Native.Intent(action: Native.Intent.ACTION_MAIN);
      intent.addCategory(Native.Intent.CATEGORY_LAUNCHER);

      List<ResolveInfo> installedApps =
          (await context.getPackageManager().queryIntentActivities(intent, 0))
              .where((app) => !launcherNames.contains(app.loadLabel()))
              .toList();

      // developer.log("installed launchers $launcherNames");
      var prefs =
          context.getSharedPreferences("varity", Context.MODE_MULTI_PROCESS);
      var defaultVolume = await prefs.getInt("default_volume",
          defaultValue: (maxVolume / 2).round());
      var defaultBrightness = await prefs.getInt("default_brightness",
          defaultValue: (maxBrightness / 2).round());
      // var audioManager =
      //     context.getSystemService(Context.AUDIO_SERVICE) as AudioManager;
      var currentVolume = defaultVolume!;
      var currentBrightness = defaultBrightness!;

      for (var info in launcherApps) {
        var activityInfo = info.activityInfo;
        if (activityInfo != null) {
          var app = _parseApp(activityInfo.applicationInfo, context);
          app.dayBrightness = currentBrightness;
          app.dayVolume = currentVolume;
          if (isPremium) {
            app.nightVolume = currentVolume;
            app.nightBrightness = currentBrightness;
          }

          apps.add(app);
          await db.apps.add(app);
        }
      }

      for (var info in installedApps) {
        var activityInfo = info.activityInfo;
        if (activityInfo != null) {
          var app = _parseApp(activityInfo.applicationInfo, context);

          app.dayBrightness = currentBrightness;
          app.dayVolume = currentVolume;
          if (isPremium) {
            app.nightVolume = currentVolume;
            app.nightBrightness = currentBrightness;
          }

          apps.add(app);
          await db.apps.add(app);
        }
      }
    } else {
      for (var i = 0; i < apps.length; i++) {
        var app = apps[i];
        // log("getting icon for package ${app.packageName}");
        var isInstalled = await isPackageInstalled(context, app);
        if (!isInstalled) {
          developer.log("package is not installed, skipping");
          continue;
        }
        var icon;
        try {
          if (app.icon.isEmpty) {
            developer.log("app icon is empty or null, getting a new one");
            icon = await context
                .getPackageManager()
                .getApplicationIcon(app.packageName);
          }
        } catch (e) {
          continue;
        }
        if (icon != null) {
          app.icon = icon;
          apps[i] = app;
        }
      }
    }
    developer.log("apps length ${apps.length}");
    return apps;
  }

  Future<bool> isPackageInstalled(Context context, App app) async {
    try {
      context.getPackageManager().getPackageInfo(app.packageName, 0);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    cacheDir = (await getTemporaryDirectory()).path;
  }
}
