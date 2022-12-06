package com.mixaline.varity.utils

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.O)
internal fun createNotificationChannel(context: Context, channelId: String, channelName: String): String {
  val chan = NotificationChannel(
    channelId,
    channelName, NotificationManager.IMPORTANCE_NONE
  )
  chan.lightColor = Color.BLUE
  chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
  val service = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
  service.createNotificationChannel(chan)
  return channelId
}
