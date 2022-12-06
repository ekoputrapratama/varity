package com.mixaline.varity.utils

import android.app.NotificationManager
import android.content.ComponentName
import android.content.ContentResolver
import android.content.Context
import android.provider.Settings
import android.widget.Toast

import com.mixaline.varity.utils.*

internal fun isNotificationListenerServiceEnabled(
  context: Context,
  componentName: ComponentName
): Boolean {
  return if(isPriorOMR1()){
    Settings.Secure.getString(
      context.contentResolver,
      "enabled_notification_listeners"
    ).contains(componentName.toString())
  } else {
    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    return nm.isNotificationListenerAccessGranted(componentName);
  }
}

internal fun isAccessibilityServiceEnabled(
    contentResolver: ContentResolver,
    componentName: String
): Boolean = Settings.Secure.getString(
    contentResolver,
    Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
)?.contains(componentName) ?: false

internal fun enableAccessibilityService(context: Context, componentName: String) {
  if (canWriteSecureSettings(context) && !isAccessibilityServiceEnabled(
          context.contentResolver,
          componentName
      )
  ) {
    var services = readSecureSettings<String?>(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ) ?: ""
    services += "${if (!services.isNullOrEmpty()) ":" else ""}${componentName}"
    Ln.d("enabling accessibility service without root")
    writeSecureSettings(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        services
    )
  } else if (hasRootAccess() && !isAccessibilityServiceEnabled(
          context.contentResolver,
          componentName
      )
  ) {
    var services = readSecureSettings<String?>(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ) ?: ""
    services += "${if (!services.isNullOrEmpty()) ":" else ""}${componentName}"
    Ln.d("enabling accessibility service with root")
    val result =
        Shell.RootShell().exec("settings put secure enabled_accessibility_services $services")
    if (!result.success()) {
      Ln.w("cannot enable accessibility service as root")
      Toast.makeText(context, "cannot enable accessibility service as root", Toast.LENGTH_LONG)
          .show()
    }
  } else {
    Ln.w("cannot enable Accessibility Service")
    Toast.makeText(context, "cannot enable accessibility service", Toast.LENGTH_LONG)
        .show()
  }
}

// com.stella.debug/com.stella.apps.toolbox.services.ToolboxAccessibilityService:com.stella.debug/com.stella.apps.navbar.services.NavBarService:com.googelService
internal fun disableAccessibilityService(context: Context, componentName: String) {
  if (canWriteSecureSettings(context) && isAccessibilityServiceEnabled(
          context.contentResolver,
          componentName
      )
  ) {

    val services = readSecureSettings<String>(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ).replace(":$componentName", "")
        .replace("$componentName:", "")

    writeSecureSettings(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        services
    )
  } else if(hasRootAccess() && isAccessibilityServiceEnabled(
    context.contentResolver,
    componentName)) {
    
    val services = readSecureSettings<String>(
        context.contentResolver,
        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ).replace(":$componentName", "")
      .replace("$componentName:", "")

    val result =
        Shell.RootShell().exec("settings put secure enabled_accessibility_services $services")
    if (!result.success()) {
      Ln.w("cannot enable accessibility service as root")
      Toast.makeText(context, "cannot enable accessibility service as root", Toast.LENGTH_LONG)
          .show()
    }
  }
}
