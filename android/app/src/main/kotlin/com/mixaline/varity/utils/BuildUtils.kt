package com.mixaline.varity.utils

import android.os.Build

internal fun isAtLeastM(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
}
internal fun isPriorM(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.M
}

internal fun isAtLeastO(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
}
internal fun isPriorO(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.O
}

internal fun isAtLeastOMR1(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1
}
internal fun isPriorOMR1(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1
}

internal fun isAtLeastN(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
}
internal fun isPriorN(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.N
}

internal fun isAtLeastL(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
}
internal fun isPriorL(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP
}

internal fun isAtLeastLMR1(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1
}
internal fun isPriorLMR1(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP_MR1
}

internal fun isAtLeastQ(): Boolean {
  return Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
}
internal fun isPriorQ(): Boolean {
  return Build.VERSION.SDK_INT < Build.VERSION_CODES.Q
}
