import 'dart:developer';

import 'package:android_native/app/Activity.dart';
import 'package:android_native/content/Context.dart';
import 'package:android_native/provider/Settings.dart';
import 'package:flutter/material.dart';
import 'package:android_native/content/Intent.dart' as Native;

const ACCESSIBILITY_SETTINGS_REQUEST = 4390;

Future<bool> isAccessibilityServiceEnabled(String componentName) async {
  var enabledServices = await Settings.Secure.getString(
      Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
  // log("enabled acceessibility services $enabledServices");
  log("isAccessibilityServiceEnabled ${enabledServices != null && enabledServices.contains(componentName)}");
  return enabledServices != null && enabledServices.contains(componentName);
}

Future requestStartAccessibilityService(
    BuildContext context, ActivityState ctx) async {
  log("requestStartAccessibilityService");
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop(); //Will close the dialog
      // Navigator.of(context).pop();
      var intent =
          Native.Intent(action: Settings.ACTION_ACCESSIBILITY_SETTINGS);
      intent.addFlags(Native.Intent.FLAG_ACTIVITY_NEW_TASK);
      ctx.startActivityForResult(intent, ACCESSIBILITY_SETTINGS_REQUEST);

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
