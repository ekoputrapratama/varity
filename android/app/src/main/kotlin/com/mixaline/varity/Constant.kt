package com.mixaline.varity

import com.mixaline.varity.handlers.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

const val VAB_CHANNEL = "com.mixaline.varity/vab"

const val METHOD_GET_CURRENT_VOLUME = "getCurrentVolume"
const val METHOD_GET_CURRENT_BRIGHTNESS = "getCurrentBrightness"
const val METHOD_START = "start"
const val METHOD_STOP = "stop"
const val METHOD_ABOUT = "about"
const val METHOD_IS_RUNNING = "isRunning"
const val METHOD_ON_DESTROY = "onDestroy"
const val METHOD_ON_SERVICE_CONNECTED = "onServiceConnected"
const val METHOD_ON_INTERRUPT = "onInterrupt"
const val METHOD_ON_ACCESSIBILITY_EVENT = "onAccessibilityEvent"

const val PARAM_STREAM_TYPE = "type"
val maxBrightnessMap: Map<String, Int> = mapOf(
  "Xiaomi M2101K6G" to 2047
)

internal fun backgroundHandler(): BackgroundHandler? {
  return MainActivity.backgroundHandler
}

internal fun backgroundEngine(): FlutterEngine? {
  return MainActivity.backgroundFlutterEngine
}

internal fun clientHandlers(): MutableSet<ClientHandler> {
  return MainActivity.clientHandlers
}

internal fun mainClientHandler(): ClientHandler? {
  return MainActivity.mainClientHandler
}
internal fun startResult(): Result? {
  return MainActivity.startResult
}
internal fun sendStartResult(result: Boolean) {
  MainActivity.sendStartResult(result)
}


