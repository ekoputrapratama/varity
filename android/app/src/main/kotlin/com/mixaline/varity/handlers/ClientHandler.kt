package com.mixaline.varity.handlers

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.net.Uri
import android.provider.Settings
import android.app.AlertDialog

import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.mixaline.varity.*
import com.mixaline.varity.utils.*
import com.mixaline.varity.services.VarityAccessibilityService


class ClientHandler(val messenger: BinaryMessenger) : MethodCallHandler, OnResumeCallback {
  var channel: MethodChannel? = null
  private var activity: Activity? = null
  private var context: Context? = null
  private var mainActivity: MainActivity? = null
  private var initEnginePending = false

  companion object {
    const val TAG = "ClientHandler"
    const val VARITY_FOREGROUND_CHANNEL = "com.mixaline.varity/foreground_channel"
  }

  init {
    Ln.d(TAG, "initializing MethodChannel")
    channel = MethodChannel(messenger, VARITY_FOREGROUND_CHANNEL)
    channel?.setMethodCallHandler(this)
  }

  fun setMainActivity(mainActivity: MainActivity?) {
    this.mainActivity = mainActivity
  }

  fun setActivity(activity: Activity?) {
    this.activity = activity
  }
  
  fun setContext(context: Context?) {
    this.context = context
  }

  fun setOnResumeRegistry(registry: OnActivityRegistry) {
    // registry?.addOnResumeListener(this)
  }

  override fun onResume() {
    Ln.d(TAG, "onResume fired in clientHandler")
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    Ln.d(TAG, "onMethodCall ${call.method}")
    when(call.method) {
      METHOD_START -> {
        Ln.d(TAG, "start")
        if (startResult() != null) {
          sendStartResult(false)
          return
        }
        MainActivity.startResult = result

        val serviceName = "${context!!.packageName}/${VarityAccessibilityService::class.java.canonicalName}"
        checkAccessibilityService(context!!, serviceName)

        if (!VarityAccessibilityService.isRunning) {
          sendStartResult(false)
        } else {
          sendStartResult(true)
        }
      }
      METHOD_ABOUT -> {
        // LibsBuilder(activity).start(this)
      }
      METHOD_IS_RUNNING -> {
        result.success(VarityAccessibilityService.isRunning)
      }
    }
  }

  private fun startAccessibilityService(context: Context, serviceName: String) {
    if (!isAccessibilityServiceEnabled(context.contentResolver, serviceName)) {
      if (canWriteSecureSettings(context) || hasRootAccess()) {
      }
    }
  }
  
  private fun checkAccessibilityService(context: Context, serviceName: String) {
    if (!isAccessibilityServiceEnabled(context.contentResolver, serviceName)) {
      val info = context!!.applicationInfo
      val appName = if(info.labelRes == 0)
        info.nonLocalizedLabel.toString() 
      else
        context!!.getString(info.labelRes)

      if (!canWriteSecureSettings(context) && !hasRootAccess()) {
        Ln.d("enabling accessibility service without root")
        AlertDialog.Builder(context)
          .setTitle("Accessibility Service")
          .setMessage("$appName needs accessibility service to run properly.")
          .setCancelable(false)
          .setPositiveButton("Ok") { _, _ ->
            val intent =
              Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            // intent.data =
            //   Uri.fromParts("package", context!!.packageName, null);
            context.startActivity(intent)
          }
          .setNegativeButton(context.getString(android.R.string.cancel)) { _, _ ->
          }
          .show()
      } else if (canWriteSecureSettings(context) || hasRootAccess()) {
        Ln.d("enabling accessibility service with or without root")
        AlertDialog.Builder(context)
          .setTitle("Accessibility Service")
          .setMessage("$appName needs accessibility service to run properly.")
          .setCancelable(false)
          .setPositiveButton("Ok") { _, _ ->
            enableAccessibilityService(context, serviceName)
          }
          .setNegativeButton(context.getString(android.R.string.cancel)) { _, _ ->
          }
          .show()
        
      }
    }
  }
}
internal fun getLong(o: Any?): Long? {
  return if (o == null || o is Long) (o as Long) else (o as Int).toLong()
}
