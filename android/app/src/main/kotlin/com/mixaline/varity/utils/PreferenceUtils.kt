package com.mixaline.varity.utils


import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.SharedPreferences
import android.os.PowerManager
import androidx.preference.PreferenceManager


private const val TAG = "VM-PreferenceUtils"

internal fun neverCalled(id: String, context: Context): Boolean {
  val sharedPreferences = context.getSharedPreferences(id, Context.MODE_PRIVATE)
  val first = sharedPreferences.getBoolean(id, true)
  if (first) {
    with(sharedPreferences.edit()) {
      putBoolean(id, false)
      apply()
    }
  }
  return first
}

@Suppress("deprecation")
internal fun isDeviceLocked(ctx: Context): Boolean {
  val km = ctx.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager?

  if (km!!.isKeyguardLocked) return true

  val pm = ctx.getSystemService(Context.POWER_SERVICE) as PowerManager? ?: return false

  return if (isAtLeastL())
    !pm.isInteractive
  else
    !pm.isScreenOn
}

internal fun getPrefs(context: Context, useProtectedPreference: Boolean = false): SharedPreferences {
  var storageContext: Context? = null
  if (isAtLeastN() && (isDeviceLocked(context) || useProtectedPreference)) {
    val deviceContext = context.createDeviceProtectedStorageContext()
    if (!deviceContext.moveDefaultSharedPreferencesFrom(
        context
      )
    ) {
      Ln.w(TAG, "Failed to migrate shared preferences.")
    }
    storageContext = deviceContext
  }
  return PreferenceManager.getDefaultSharedPreferences(storageContext ?: context)
}

internal fun getPrefs(context: Context, name: String, useProtectedPreference: Boolean = false, mode: Int = Context.MODE_PRIVATE): SharedPreferences {
  var storageContext: Context? = null
  if (isAtLeastN() && (isDeviceLocked(context) || useProtectedPreference)) {
    val deviceContext = context.createDeviceProtectedStorageContext()
    if (!deviceContext.moveSharedPreferencesFrom(
        context,
        name
      )
    ) {
      Ln.w(TAG, "Failed to migrate shared preferences.")
    }
    storageContext = deviceContext
  }
  return (storageContext ?: context).getSharedPreferences(name, mode)
}
