package com.mixaline.varity.handlers

import android.content.Context
import android.view.accessibility.AccessibilityEvent

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.FlutterCallbackInformation

import com.mixaline.varity.*
import com.mixaline.varity.services.VarityAccessibilityService
import com.mixaline.varity.utils.*

class BackgroundHandler(val callbackHandle: Long, val bundlePath: String?) : MethodCallHandler, 
  VarityAccessibilityService.ServiceListener {
  
  private var channel: MethodChannel? = null

  companion object {
    const val TAG = "BackgroundHandler"
    const val VARITY_BACKGROUND_CHANNEL = "com.mixaline.varity/accessibility_background"
  }

  fun init(messenger: BinaryMessenger) {
    if (channel != null) return
    channel = MethodChannel(messenger, VARITY_BACKGROUND_CHANNEL)
    channel?.setMethodCallHandler(this)
  }

  fun initEngine() {
    Ln.d(TAG, "initializing background engine")
    val context = VarityAccessibilityService.instance
    val backgroundFlutterEngine = FlutterEngine(context!!.applicationContext)
    MainActivity.backgroundFlutterEngine = backgroundFlutterEngine

    val cb = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle) as FlutterCallbackInformation?

    if (cb == null || bundlePath == null) {
      Ln.d(TAG, "cannot initialize background engine")
      // sendStartResult(false)
      return
    }

    val executor = backgroundFlutterEngine.dartExecutor
    init(executor)

    val dartCallback = DartCallback(context.assets, bundlePath!!, cb)

    executor.executeDartCallback(dartCallback)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      "isRunning" -> {
        result.success(VarityAccessibilityService.isRunning)
      }
    }
  }

  override fun onServiceConnected() {
    channel?.invokeMethod(METHOD_ON_SERVICE_CONNECTED, null)
  }

  override fun onDestroy() {
    channel?.invokeMethod(METHOD_ON_DESTROY, null)
  }

  override fun onInterrupt(){
    channel?.invokeMethod(METHOD_ON_INTERRUPT, null)
  }

  override fun onAccessibilityEvent(event: AccessibilityEvent?){
    channel?.invokeMethod(METHOD_ON_ACCESSIBILITY_EVENT, event?.toMap())
  }
}
fun AccessibilityEvent.toMap(): Map<Any, Any?> {
  val map = mutableMapOf<Any, Any?>()
  map["eventType"] = eventType
  map["packageName"] = packageName?.toString()
  map["className"] = className?.toString()
  map["eventTime"] = eventTime
  map["recordCount"] = recordCount
  map["windowChanges"] = windowChanges
  return map
}
