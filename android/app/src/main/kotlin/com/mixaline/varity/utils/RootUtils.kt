package com.mixaline.varity.utils

import java.lang.Exception

// Try using root when called the first time, then cache the result
val isRootAvailable: Boolean by lazy {
  try {
    Shell.RootShell().exec("id").success()
  } catch (e: Exception) {
    false
  }
}
val isBusyBoxAvailable: Boolean by lazy {
  try {
    Shell().exec("busybox id").success()
  } catch (e: Exception) {
    false
  }
}

fun hasRootAccess(forceCheck: Boolean = false): Boolean {
  if (forceCheck) {
    return Shell.RootShell().exec("id").success()
  }
  return isRootAvailable
}

fun hasBusyBox(forceCheck: Boolean = false): Boolean {
  if (forceCheck) {
    return Shell().exec("busybox").success()
  }
  return isBusyBoxAvailable
}
