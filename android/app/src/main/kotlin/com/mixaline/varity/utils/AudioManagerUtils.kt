package com.mixaline.varity.utils

import android.media.AudioManager
import android.content.Context

fun getStreamVolume(context: Context, type: Int) : Int {
  val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

  return audioManager.getStreamVolume(type)
}

fun setStreamVolume(context: Context, type: Int, volume: Int, flags: Int?) {
  val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

  audioManager.setStreamVolume(type, volume, flags ?: 0)
}

fun isMusicActive(context: Context) : Boolean {
  val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

  return audioManager.isMusicActive
}
