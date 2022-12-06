// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:async';
import 'dart:developer';

import 'package:android_native/app/Activity.dart';
import 'package:android_native/content/Intent.dart' as Native;
import 'package:android_native/provider/Settings.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:varity/VarityApp.dart';
import 'package:varity/model/App.dart';
import 'package:flutter/foundation.dart';
import 'package:varity/pages/Loading.dart';
import 'package:varity/utils/BuildUtils.dart';
import 'package:varity/utils/PreferenceUtils.dart';
import 'package:varity/utils/ServiceUtils.dart';
import 'package:varity/widgets/AppItemView.dart';
import 'package:sentry/sentry.dart';

import '../utils/SettingsUtils.dart';

class HomePage extends Activity {
  HomePage({Key? key, this.title = "Home"}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ActivityState<HomePage>
    with WidgetsBindingObserver {
  bool _isPremium = false;
  final Controller controller = Get.find();
  List<App> _apps = [];
  List<App> _searchResult = [];
  TextEditingController _searchQueryController = TextEditingController();
  FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  final GlobalKey<PopupMenuButtonState<int>> _menuKey = GlobalKey();

  static const Duration _snackBarDisplayDuration = Duration(milliseconds: 5000);
  GlobalKey _showcaseOne = GlobalKey();
  GlobalKey _showcaseTwo = GlobalKey();
  GlobalKey _showcaseThree = GlobalKey();
  GlobalKey _showcaseFour = GlobalKey();
  GlobalKey _showcaseFive = GlobalKey();

  static const ACCESSIBILITY_SETTINGS_REQUEST = 4390;
  static const WRITE_SYSTEM_SETTINGS_REQUEST = 4560;

  void _showSnackbar(
      BuildContext context, String message, SnackBarAction? action,
      {Key? key, Duration duration = _snackBarDisplayDuration}) {
    final snackBar = SnackBar(
      key: key,
      content: Text(message),
      duration: duration,
      action: action,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future requestStartAccessibilityService(BuildContext context) async {
    log("requestStartAccessibilityService");
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(); //Will close the dialog
        // Navigator.of(context).pop();
        var intent =
            Native.Intent(action: Settings.ACTION_ACCESSIBILITY_SETTINGS);
        intent.addFlags(Native.Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivityForResult(intent, ACCESSIBILITY_SETTINGS_REQUEST);

        // _showSnackbar(
        //   context,
        //   "Find and enable Varity in accessibility service.",
        //   null,
        //   duration: Duration(seconds: 5),
        // );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Accessibility Service'),
      content: Text("Varity needs accessibility service to work properly."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _initPermissions(BuildContext context) async {
    controller.hasFocus.update((val) {
      val = false;
    });
    // The code that are related to permission cannot be moved to Application class
    if (isAtLeastM() && !(await canWriteSystemSettings())) {
      await requestWriteSystemSettings(context, this);
    } else if (await neverCalled("write_system_settings", getContext())) {
      await requestWriteSystemSettings(context, this);
    }

    var componentName =
        "com.mixaline.varity/com.mixaline.varity.services.VarityAccessibilityService";
    if (!(await isAccessibilityServiceEnabled(componentName))) {
      await requestStartAccessibilityService(context);
    }
    controller.hasFocus.toggle();
    if (await neverCalled("showcase", getContext())) {
      ShowCaseWidget.of(context)
          .startShowCase([_showcaseOne, _showcaseTwo, _showcaseThree]);
    }
  }

  void _initAds() async {
    // UnityAds.showVideoAd(
    //   placementId: 'Interstitial_Android',
    //   onStart: (adUnitId) => print('UnityAds : Video Ad $adUnitId started'),
    //   onClick: (adUnitId) => print('UnityAds : Video Ad $adUnitId click'),
    //   onSkipped: (adUnitId) => print('Video Ad $adUnitId skipped'),
    //   onFailed: (adUnitId, error, message) => print(
    //       'UnityMediation : Rewarded Ad $adUnitId failed: $error $message'),
    // );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _searchQueryController.addListener(updateSearchQuery);

    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    // });
  }

  Future _fetchApps() {
    return controller.getApps(getContext()).then((value) async {
      var intent = await getIntent();
      if (mounted) {
        setState(() {
          _apps = value;
          _apps.sort((a, b) =>
              a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
          // _searchResult = _apps;

          if (intent.hasExtra("search") && intent.hasExtra("package_name")) {
            _startSearch(focus: false);
            _searchQueryController.text =
                intent.getStringExtra('package_name')!;
          }
        });
      } else {
        log("element is not mounted");
        _apps = value;
      }

      return _apps;
    });
  }

  @override
  void onActivityResult(
      int requestCode, int resultCode, Native.Intent? intent) {
    super.onActivityResult(requestCode, resultCode, intent);
    log("onActivityResult: requestCode=$requestCode");

    if (requestCode == ACCESSIBILITY_SETTINGS_REQUEST && _apps.length < 1) {
      _fetchApps();
    }
  }

  @override
  void dispose() {
    _apps = [];
    _searchResult = [];
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        // if (_apps.length < 1) _fetchApps();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: false,
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: "Search...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // if (_searchQueryController.text.isEmpty) {
            //   if (Navigator.canPop(context)) {
            //     Navigator.pop(context);
            //   }
            //   return;
            // }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return [
      if (kDebugMode)
        Switch(
          value: _isPremium,
          onChanged: (val) {
            controller.isPremium = val;
            setState(() {
              _isPremium = val;
              // _apps?.clear();
              // _fetchApps();
            });
          },
        ),
      Showcase(
        key: _showcaseOne,
        description: 'Tap to see menu options',
        // disposeOnTap: true,
        // onTargetClick: () {
        //   setState(() {
        //     dynamic state = _menuKey.currentState;
        //     state.showButtonMenu();
        //     // ShowCaseWidget.of(context)!
        //     //     .startShowCase([_showcaseFour, _showcaseFive]);
        //   });
        // },
        child: PopupMenuButton<int>(
          key: _menuKey,
          itemBuilder: (context) {
            return <PopupMenuEntry<int>>[
              PopupMenuItem(child: Text('Settings'), value: 0),
              // PopupMenuItem(child: Text('Upgrade to pro'), value: 1),
              PopupMenuItem(child: Text('About'), value: 2),
            ];
          },
          onSelected: (val) {
            switch (val) {
              case 0:
                Navigator.pushNamed(context, "/settings");
                break;
              case 1:
                launchUrl(Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.mixaline.varity"));
                // Navigator.pushNamed(context, "/upgrade");
                break;
              case 2:
                // controller.invokeMethod("about");
                Navigator.pushNamed(context, "/about");
                break;
            }
          },
        ),
      ),
    ];
  }

  void _startSearch({bool focus = true}) {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    if (!_searchFocus.hasPrimaryFocus && focus) {
      _searchFocus.requestFocus();
    }

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    setState(() {
      _isSearching = false;
      _searchResult.clear();
    });
    // if (_searchQueryController.text.isNotEmpty) {
    // if (!_searchFocus.hasPrimaryFocus) {
    //   _searchFocus.requestFocus();
    // }
    // setState(() {
    //   _searchQueryController.clear();
    //   updateSearchQuery();
    // });
    // } else {
    //   setState(() {
    //     _isSearching = false;
    //     _searchResult?.clear();
    //   });
    // }
  }

  void updateSearchQuery() {
    var query = _searchQueryController.text;
    // _fetchApps();
    _apps.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    if (query.isNotEmpty && _isSearching) {
      setState(() {
        _searchResult = _apps.where((app) {
          return app.appName.toLowerCase().startsWith(query.toLowerCase()) ||
              app.packageName.toLowerCase().startsWith(query.toLowerCase());
        }).toList();
      });
    } else {
      _searchResult.clear();
    }

    setState(() {});
  }

  @override
  void onNewIntent(Native.Intent intent) {
    if (intent.hasExtra("search") && intent.hasExtra("package_name")) {
      _startSearch(focus: false);
      _searchQueryController.text = intent.getStringExtra('package_name')!;
    }
  }

  void onItemValueChanged() {
    log("onItemValueChanged");
    // _fetchApps();
  }

  Future initialization() async {
    await _initPermissions(context);
    _initAds();
    return _fetchApps();
  }

  late final Future initFuture = initialization();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                  title:
                      _isSearching ? _buildSearchField() : Text(widget.title),
                  actions: _buildActions()),
              body: Container(
                child: (_isSearching)
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _searchResult.length,
                        itemBuilder: (context, index) {
                          return AppItemView(
                              _searchResult[index],
                              onItemValueChanged,
                              _searchResult.length,
                              index == 0,
                              _showcaseTwo);
                        },
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _apps.length,
                        itemBuilder: (context, index) {
                          return AppItemView(_apps[index], onItemValueChanged,
                              _apps.length, index == 0, _showcaseTwo);
                        },
                      ),
              ),
              floatingActionButton: Showcase(
                  key: _showcaseThree,
                  child: FloatingActionButton(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    onPressed: _startSearch,
                    tooltip: 'Search',
                    child: Icon(Icons.search),
                  ),
                  description:
                      "Tap to search app using app name or package name."),
            );
          }

          return LoadingPage();
        });
  }
}
