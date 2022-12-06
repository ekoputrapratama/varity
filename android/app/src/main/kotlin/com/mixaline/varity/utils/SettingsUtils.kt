package com.mixaline.varity.utils

import android.Manifest
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat

internal fun canWriteSecureSettings(context: Context): Boolean = ContextCompat.checkSelfPermission(
    context,
    Manifest.permission.WRITE_SECURE_SETTINGS
) == PackageManager.PERMISSION_GRANTED

internal fun canWriteSystemSettings(context: Context): Boolean = (isAtLeastM() && Settings.System.canWrite(context)) || isPriorM()

internal fun writeSecureSettings(contentResolver: ContentResolver, key: String, value: Any) {
  when (value) {
    is Int -> Settings.Secure.putInt(contentResolver, key, value)
    is Float -> Settings.Secure.putFloat(contentResolver, key, value)
    is Long -> Settings.Secure.putLong(contentResolver, key, value)
    else -> Settings.Secure.putString(contentResolver, key, value.toString())
  }
}

internal fun <V> readSecureSettings(
    contentResolver: ContentResolver,
    key: String,
    type: Class<*> = String::class.java
): V = when (type) {
  Int::class.java -> Settings.Secure.getInt(contentResolver, key) as V
  Float::class.java -> Settings.Secure.getFloat(contentResolver, key) as V
  Long::class.java -> Settings.Secure.getLong(contentResolver, key) as V
  else -> Settings.Secure.getString(contentResolver, key) as V
}
