package com.mixaline.varity.services


import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.*
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.content.pm.ActivityInfo
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.graphics.Bitmap
import android.media.AudioManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.android.billingclient.api.*
import com.mixaline.varity.AppDatabase
import com.mixaline.varity.Database
import com.mixaline.varity.MainActivity
import com.mixaline.varity.R
import com.mixaline.varity.model.App
import com.mixaline.varity.utils.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*

class VarityAccessibilityService : AccessibilityService() {

  companion object {
    const val TAG = "VarityAccessibilityService"
    const val AUTO_SAVE_KEY = "auto_save"
    const val DAY_TIME_KEY = "day_time"
    const val NOTIFICATION_ID = 7643
    const val DIFFERENTIATE_KEY = "differentiate_state"
    var isRunning = false
    var instance: VarityAccessibilityService? = null
  }

  private var isPremium: Boolean = false
  private lateinit var db: Database
  private lateinit var prefs: SharedPreferences
  private lateinit var audioManager: AudioManager
  private lateinit var mSettingsContentObserver: SettingsContentObserver
  private var currentApp: String? = null
  private var mDatabase: AppDatabase? = null

  private var billingClient: BillingClient? = null
  private val volumeUris = listOf(
    "content://settings/system/volume_music_speaker",
    "content://settings/system/volume_music_headset",
    "content://settings/system/volume_ring_speaker",
    "content://settings/system/volume_alarm_speaker",
    "content://settings/system/volume_voice_earpiece",
    "content://settings/system/volume_voice_headset",
  )

  private var purchasesUpdatedListener = PurchasesUpdatedListener() { billingResult, purchases ->
    try {
      Ln.d("purchasesUpdated $purchases")
      if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
        if (purchases != null) {
//          val purchasesResult = billingClient!!.queryPurchases(BillingClient.SkuType.INAPP);
//          val allPurchases = purchasesResult.purchasesList;
//          Ln.d("all purchases $allPurchases")
          for (purchase in purchases) {
            for(sku in purchase.skus) {
              if (sku === "varity_premium") {
                Ln.d("set as premium member")
                isPremium = true
                break;
              }  
            }
          }
        }
      }

    } catch (e: Exception) {
      Ln.e("Something wrong happen when trying to validate your purchase")
    }
  }

  private val mBroadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      try {
        when (intent.action) {
          Intent.ACTION_PACKAGE_ADDED -> {
            val packageName = intent.data?.schemeSpecificPart
            Ln.d("ACTION_PACKAGE_ADDED : $packageName")

            if (packageName != null) {
              val existingApp = mDatabase?.appDao()?.getApp(packageName)
              if (existingApp == null) {
                val am = applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val currentVolume = prefs.getInt("default_volume", 8)
                val currentBrightness = prefs.getInt("default_brightness", 115)
                try {
                  val info = context.packageManager.getApplicationInfo(packageName, 0)
                  val appName = info.nonLocalizedLabel?.toString() ?: info.loadLabel(
                    context.packageManager
                  ).toString()

                  val icon = info.loadIcon(
                    context.packageManager
                  )

                  val resizedImg = ImageUtil.rescaleImage(icon)

                  val stream = ByteArrayOutputStream()
                  resizedImg.compress(Bitmap.CompressFormat.PNG, 100, stream)
                  val app = App(
                    info.packageName,
                    appName,
                    stream.toByteArray(),
                    currentVolume,
                    currentVolume,
                    currentBrightness,
                    currentBrightness
                  )
                  Ln.d("adding new installed application to database")
                  GlobalScope.launch(Dispatchers.IO) {
                    mDatabase?.appDao()?.insert(app)
                    notifyNewApp(app)
                  }

                } catch (e: Exception) {
                  Ln.e(TAG, e.message)
                }
              }
            }
          }
          Intent.ACTION_PACKAGE_REMOVED -> {
            val packageName = intent.data?.schemeSpecificPart
            Ln.d("ACTION_PACKAGE_REMOVED : $packageName")
            // if(packageName != null)
            //   mDatabase?.appDao()?.deleteApp(packageName)
          }
          Intent.ACTION_HEADSET_PLUG -> {
            when (val state = intent.getIntExtra("state", -1)) {
              0,
              1 -> {
                Ln.d(TAG, "Headset is ${if (state == 0) "unplugged" else "plugged"}")
                if (currentApp != null) {
                  restoreStateFromDb(currentApp!!)
                }
              }
              else -> {
              }
            }
          }
        }

      } catch (e: Exception) {
        Ln.e(TAG, e.message)
      }
    }
  }

  private val mSharedPreferenceChangedListener =
    OnSharedPreferenceChangeListener { _, key ->
      Ln.d(TAG, "shared preference change for key=$key ")
      val value = prefs.getBoolean("premium", false)
      if (key == "premium" && value) {
        billingClient!!.queryPurchasesAsync(
          QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.SUBS)
            .build()
        ) { billingResult, purchaseList ->
          // Process the result
          for (purchase in purchaseList) {
            for(sku in purchase.skus) {
              if (sku === "varity_premium") {
                Ln.d("set as premium member")
                isPremium = true
                break;
              }
            }
          }
        }
      }
    }

  fun restoreStateFromDb(packageName: String) {
    db.open()
    val app = db.getApp(packageName)
    if (app != null) {
      Ln.d("app $app")
      val differentiateState = prefs.getBoolean(DIFFERENTIATE_KEY, false)
      val dayTime = prefs.getString(DAY_TIME_KEY, "06:00-18:00")
      var savedBrightness = app.dayBrightness
      if (canWriteSystemSettings(this)) {
        Ln.d("savedBrightness ${app.dayBrightness}")
        if (isPremium && differentiateState && !isDayTime(dayTime!!)) {
          savedBrightness = app.nightBrightness
        }

        Ln.d("restore brightness to $savedBrightness for package $currentApp")
        Settings.System.putInt(
          contentResolver,
          Settings.System.SCREEN_BRIGHTNESS,
          savedBrightness
        )
      }

      val disableOnPlayback = prefs.getBoolean("disable_on_playback", true)
      // when disableOnPlayback is true and there is no music active/playing
      var savedVolume = app.dayVolume

      val isMusicActive = audioManager.isMusicActive
      if (savedVolume == -1 || savedVolume == 0) {
        savedVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
//        mDatabase?.appDao()?.updateDayVolume(currentApp!!, savedVolume)
        db.updateDayVolume(currentApp!!, savedVolume)
        if (isPremium && differentiateState) {
//          mDatabase?.appDao()?.updateNightVolume(currentApp!!, savedVolume)
          db.updateNightVolume(currentApp!!, savedVolume)
        }
      } else if (isPremium && differentiateState && !isDayTime(dayTime)) {
        savedVolume = app.nightVolume
      }

      if ((disableOnPlayback && !isMusicActive) || !disableOnPlayback) {
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, savedVolume, 0)
      }
    }
    db.close()
  }

  private fun disableAutomaticBrightness() {
    if (canWriteSystemSettings(this)) {
      val mode = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE)
      if (mode == Settings.System.SCREEN_BRIGHTNESS_MODE_AUTOMATIC) {
        Settings.System.putInt(
          contentResolver,
          Settings.System.SCREEN_BRIGHTNESS_MODE, Settings.System.SCREEN_BRIGHTNESS_MODE_MANUAL
        );
      }
    }
  }

  @SuppressLint("MissingPermission")
  private fun notifyNewApp(app: App) {
    Ln.d(TAG, "notifyNewApp ${app.name}")
    val main = Intent(this, MainActivity::class.java).apply {
      // flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
      putExtra("search", true)
      putExtra("package_name", app.packageName)
    }

    val pi = PendingIntent.getActivity(this, 0, main, PendingIntent.FLAG_UPDATE_CURRENT)

    val builder = if (isAtLeastO()) {
      val channelId = "varity"
      val importance = NotificationManager.IMPORTANCE_DEFAULT;
      val channel = NotificationChannel(channelId, "Varity", importance)
      val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      service.createNotificationChannel(channel)

      NotificationCompat.Builder(this, channelId)
    } else {
      NotificationCompat.Builder(this)
    }

    builder.apply {
      setSmallIcon(R.drawable.ic_varity)
      setContentIntent(pi)
      setAutoCancel(true)

      if (isAtLeastN()) {
        setContentTitle(app.name)
        setContentText(getString(R.string.msg_installed_n))
      } else {
        setContentTitle(getString(R.string.app_name))
        setContentText(getString(R.string.msg_installed, app.name))
      }

      if (isAtLeastL()) {
        setCategory(NotificationCompat.CATEGORY_STATUS)
        setVisibility(NotificationCompat.VISIBILITY_SECRET)
      }
    }

    with(NotificationManagerCompat.from(this)) {
      notify(NOTIFICATION_ID, builder.build())
    }
  }


  private fun endBillingClientConnection() {
    if (billingClient != null) {
      try {
        billingClient!!.endConnection()
        billingClient = null
      } catch (ignored: java.lang.Exception) {
      }
    }
  }

  @SuppressLint("SwitchIntDef")
  override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    Ln.d(TAG, "onAccessibilityEvent")
    when (event?.eventType) {
      AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
        if (event.packageName != null && event.className != null) {
          val componentName = ComponentName(
            event.packageName.toString(),
            event.className.toString()
          )
          val activityInfo: ActivityInfo? = tryGetActivity(componentName)
          val isActivity = activityInfo != null
          Ln.d(TAG, "package name ${event.packageName}")
          if (isActivity) {
            currentApp = componentName.packageName

            // val app = mDatabase?.appDao()?.getApp(currentApp!!)

            Ln.i(TAG, "CurrentActivity ${componentName.flattenToShortString()}")
            restoreStateFromDb(currentApp!!)
            // if (app != null) {
            //   val differentiateState = prefs.getBoolean(DIFFERENTIATE_KEY, false)
            //   val dayTime = prefs.getString(DAY_TIME_KEY, "06:00-18:00")
            //   var savedBrightness = app.dayBrightness
            //   Ln.d("attempting to restore brightness for package $currentApp")
            //   if(canWriteSystemSettings(this)){
            //     if(isPremium && differentiateState && !isDayTime(dayTime!!) ) {
            //       savedBrightness = app.nightBrightness
            //     }

            //     Ln.d("restore brightness for package $currentApp")
            //     Settings.System.putInt(
            //       contentResolver,
            //       Settings.System.SCREEN_BRIGHTNESS,
            //       savedBrightness
            //     )
            //   }

            //   val disableOnPlayback = prefs.getBoolean("disable_on_playback", true)
            //   // when disableOnPlayback is true and there is no music active/playing
            //   var savedVolume = app.dayVolume

            //   val isMusicActive = audioManager.isMusicActive
            //   if (savedVolume == -1) {
            //     savedVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            //     // prefs.edit().putInt(componentName.packageName, savedVolume).apply()
            //     mDatabase?.appDao()?.updateDayVolume(currentApp!!, savedVolume)
            //     if(isPremium && differentiateState){
            //       mDatabase?.appDao()?.updateNightVolume(currentApp!!, savedVolume)
            //     }
            //   } else if(isPremium && differentiateState && !isDayTime(dayTime)) {
            //     savedVolume = app.nightVolume
            //   }

            //   if((disableOnPlayback && !isMusicActive) || !disableOnPlayback){
            //     audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, savedVolume, 0)
            //   }
            // }

          } else {
            // val names = listOf("com.vivo.upslide","com.android.systemui")
            // if (!names.contains(event.packageName))
              // currentApp = null
          }
        }
      }
    }
  }

  override fun onInterrupt() {
    Ln.d(TAG, "onInterrupt")
    // backgroundHandler?.onInterrupt()
  }

  private fun initDatabase() {
    var storageContext: Context? = null
    if (isAtLeastN()) {
      Ln.d("using device protected storage")
      storageContext = createDeviceProtectedStorageContext()
    } else {
      storageContext = this
    }

    val dummyName = "dummy.db"
    val file = storageContext!!.getDatabasePath(dummyName)
    val databasePath = file.parent
    db = Database("$databasePath/varity.db")
    Ln.d("Database path $databasePath")
  }


  override fun onServiceConnected() {
    Ln.d(TAG, "onServiceConnected")
    super.onServiceConnected()
    isRunning = true
    initDatabase()
    if (isAtLeastN()) {
      mDatabase = AppDatabase.getInstance(createDeviceProtectedStorageContext())
    } else {
      mDatabase = AppDatabase.getInstance(this)
    }

    billingClient = BillingClient.newBuilder(this).setListener(purchasesUpdatedListener)
      .enablePendingPurchases()
      .build()
    prefs = getPrefs(this, "varity", true, Context.MODE_MULTI_PROCESS)
    prefs.registerOnSharedPreferenceChangeListener(mSharedPreferenceChangedListener)
    
    billingClient!!.startConnection(object : BillingClientStateListener {
      var alreadyFinished = false
      override fun onBillingSetupFinished(p0: BillingResult) {
        billingClient!!.queryPurchasesAsync(
          QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.SUBS)
            .build()
        ) { billingResult, purchaseList ->
          // Process the result
          Ln.d("list of purchases $purchaseList")
          for (purchase in purchaseList) {
            for(sku in purchase.skus) {
              if (sku === "varity_premium") {
                Ln.d("set as premium member")
                prefs.edit().putBoolean("premium", true).apply()
                isPremium = true
                break;
              }
            }
          }
        }        
      }

      override fun onBillingServiceDisconnected() {
        TODO("Not yet implemented")
      }
    })

    
    // isPremium = prefs.getBoolean("is_premium", false)
    audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
    // Configure these here for compatibility with API 13 and below.
    val config = AccessibilityServiceInfo()
    config.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
    config.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC

    serviceInfo = config
    disableAutomaticBrightness()

    mSettingsContentObserver = SettingsContentObserver(Handler(Looper.myLooper()!!))
    contentResolver.registerContentObserver(
      Settings.System.CONTENT_URI, true,
      mSettingsContentObserver
    )

    val filter = IntentFilter()
    filter.addAction(Intent.ACTION_PACKAGE_ADDED)
    filter.addAction(Intent.ACTION_PACKAGE_REMOVED)
    filter.addAction(Intent.ACTION_HEADSET_PLUG)
    filter.addDataScheme("package")
    registerReceiver(mBroadcastReceiver, filter)
  }

  override fun onDestroy() {
    Ln.d(TAG, "onDestroy")
    super.onDestroy()
    endBillingClientConnection()

    isRunning = false
    mDatabase = null
    prefs.unregisterOnSharedPreferenceChangeListener(mSharedPreferenceChangedListener)
    contentResolver.unregisterContentObserver(mSettingsContentObserver)
    unregisterReceiver(mBroadcastReceiver)
  }

  private fun tryGetActivity(componentName: ComponentName): ActivityInfo? {
    return try {
      packageManager.getActivityInfo(componentName, 0)
    } catch (e: PackageManager.NameNotFoundException) {
      null
    }
  }

  @SuppressLint("SimpleDateFormat")
  fun isDayTime(dayTime: String?): Boolean {
    if (dayTime != null && dayTime.isNotEmpty() && isPremium) {
      val time1 = SimpleDateFormat("HH:mm").parse(dayTime.split("-")[0])!!
      val calendar1 = Calendar.getInstance()
      calendar1.time = time1
      calendar1.add(Calendar.DATE, 1)

      val time2 = SimpleDateFormat("HH:mm").parse(dayTime.split("-")[1])!!
      val calendar2 = Calendar.getInstance()
      calendar2.time = time2
      calendar2.add(Calendar.DATE, 1)

      val now = Calendar.getInstance();
      val x = now.time

      return x.after(calendar1.time) && x.before(calendar2.time)
    }

    return false
  }

  interface ServiceListener {
    fun onAccessibilityEvent(event: AccessibilityEvent?)
    fun onInterrupt()
    fun onServiceConnected()
    fun onDestroy()
  }

  inner class SettingsContentObserver(handler: Handler?) :
    ContentObserver(handler) {
    override fun onChange(selfChange: Boolean, uri: Uri?) {
      super.onChange(selfChange, uri)
      val brightnessUri = Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS)
      Ln.d(TAG, "onChange : $currentApp")
      if (currentApp != null) {
        db.open()
        val app = db.getApp(currentApp!!)
//        val app = mDatabase?.appDao()?.getApp(currentApp!!)
        val autoSave = prefs.getBoolean(AUTO_SAVE_KEY, true)
        val differentiateState = prefs.getBoolean(DIFFERENTIATE_KEY, false)
        val dayTime = prefs.getString(DAY_TIME_KEY, "06:00-18:00")
        // Ln.d(TAG, "autoSave enabled $autoSave")
        // Ln.d(TAG, "day time range $dayTime")

        if (app != null && autoSave) {
          if (uri.toString() == brightnessUri.toString()) {
            val savedBrightness = app.dayBrightness
            val currentBrightness =
              Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS)
            Ln.d("current brightness $currentBrightness")
            if (currentBrightness != savedBrightness) {
              Ln.d(TAG, "updating value for brightness")
              if (isPremium && differentiateState) {
                if (isDayTime(dayTime)) {
                  db.updateDayBrightness(currentApp!!, currentBrightness)
//                  mDatabase?.appDao()?.updateDayBrightness(currentApp!!, currentBridghtness)
                } else {
                  db.updateNightBrightness(currentApp!!, currentBrightness)
//                  mDatabase?.appDao()?.updateNightBrightness(currentApp!!, currentBridghtness)
                }
              } else {
                db.updateDayBrightness(currentApp!!, currentBrightness)
//                mDatabase?.appDao()?.updateDayBrightness(currentApp!!, currentBridghtness)
              }
            }
            Ln.d(TAG, "Brightness now $currentBrightness")
          } else if (volumeUris.contains(uri.toString())) {
            val savedVol = app.dayVolume
            val currentVol = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)

            if (currentVol != savedVol) {
              Ln.d(TAG, "updating value for volume")
              db.updateDayVolume(currentApp!!, currentVol)
//              mDatabase?.appDao()?.updateDayVolume(currentApp!!, currentVol)
            }
            Ln.d(TAG, "Volume now $currentVol")
          }
        }
        db.close()
      }
    }
  }
}


