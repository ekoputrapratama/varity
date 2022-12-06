package com.mixaline.varity.utils

import android.content.Context
import android.os.Build
import android.widget.Toast
import androidx.annotation.RequiresApi


@RequiresApi(Build.VERSION_CODES.N)
fun Context.moveDefaultSharedPreferencesFrom(sourceContext: Context): Boolean {
  return moveSharedPreferencesFrom(sourceContext, "${sourceContext.packageName}_preferences")
}

internal fun Context.toast(s: String, duration: Int) {
  Toast.makeText(this, s, duration).show()
}
