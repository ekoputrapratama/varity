package com.mixaline.varity.utils

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log

internal fun isSystemApp(applicationInfo: ApplicationInfo): Boolean {
  return applicationInfo.flags.isFlagSet(ApplicationInfo.FLAG_SYSTEM)
}

internal fun isSystemApp(context: Context, packageName: String): Boolean {
  return try {
    val pm = context.packageManager
    val info = pm.getPackageInfo(packageName, 0)
    info.applicationInfo.flags and (ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
    /*
            PackageInfo pkg = pm.getPackageInfo(packageName, PackageManager.GET_SIGNATURES);
            PackageInfo sys = pm.getPackageInfo("android", PackageManager.GET_SIGNATURES);
            return (pkg != null && pkg.signatures != null && pkg.signatures.length > 0 &&
                    sys.signatures.length > 0 && sys.signatures[0].equals(pkg.signatures[0]));
            */
  } catch (ignore: PackageManager.NameNotFoundException) {
    false
  }
}

internal fun isSystemApp(uid: Int, context: Context): Boolean {
  val pm = context.packageManager
  val pkgs = pm.getPackagesForUid(uid)
  if (pkgs != null) for (pkg in pkgs) if (isSystemApp(
      context,
      pkg
    )
  ) return true
  return false
}

fun getListOfBrowser(context: Context): List<String> {
  val browserPackageName: MutableList<String> = ArrayList()
  try {
    val intent = Intent(Intent.ACTION_VIEW)
    intent.data = Uri.parse("http://www.google.com")
    val pm: PackageManager = context.packageManager
    val browserList = pm.queryIntentActivities(intent, 0)
    for (info in browserList) {
      browserPackageName.add(info.activityInfo.packageName)
    }
  } catch (e: Exception) {
    e.printStackTrace()
    Ln.e("BrowserList Info ", e)
  }
  return browserPackageName
}

fun isAppEnabled(context: Context, info: PackageInfo): Boolean {
  var setting: Int
  try {
    val pm = context.packageManager
    setting = pm.getApplicationEnabledSetting(info.packageName)
  } catch (ex: IllegalArgumentException) {
    setting = PackageManager.COMPONENT_ENABLED_STATE_DEFAULT
    Ln.w("""
   $ex
   ${Log.getStackTraceString(ex)}
   """.trimIndent()
    )
  }
  return if (setting == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) info.applicationInfo.enabled else setting == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
}
