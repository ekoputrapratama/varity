import 'dart:developer';

import 'package:android_native/app/Activity.dart';
import 'package:android_native/content/Context.dart';
import 'package:android_native/os/Build.dart';
import 'package:android_native/provider/Settings.dart';
import 'package:flutter/material.dart';
import 'package:android_native/content/Intent.dart' as Native;

import 'RootUtils.dart';

const WRITE_SYSTEM_SETTINGS_REQUEST = 4560;

Future<bool> canWriteSystemSettings() async {
  var canWrite = await Settings.System.canWrite();
  return canWrite;
}

Future requestWriteSystemSettings(
    BuildContext context, ActivityState ctx) async {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () async {
      Navigator.pop(context);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        var intent =
            Native.Intent(action: Settings.ACTION_MANAGE_WRITE_SETTINGS);
        intent.setData(Uri.parse("package:com.mixaline.varity"));
        intent.addFlags(Native.Intent.FLAG_ACTIVITY_NEW_TASK);
        ctx.startActivityForResult(intent, WRITE_SYSTEM_SETTINGS_REQUEST);
      } else if (await hasRootAccess()) {
        log("hasRootAccess");
      }

      // if (!(await _canWriteSystemSettings())) {
      //   _showSnackbar(context, "Write sytem settings is not enabled", null);
      // }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Write system settings"),
    content:
        Text("Varity needs write system settings permission to work properly."),
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
