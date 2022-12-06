package com.mixaline.varity

import android.os.Bundle

import com.mixaline.varity.handlers.BackgroundHandler
import com.mixaline.varity.handlers.ClientHandler
import com.mixaline.varity.utils.Ln
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.ironsource.mediationsdk.IronSource
import com.ironsource.mediationsdk.integration.IntegrationHelper
import com.ironsource.mediationsdk.logger.IronSourceError
import com.ironsource.mediationsdk.model.Placement
import com.ironsource.mediationsdk.sdk.InitializationListener
import com.ironsource.mediationsdk.sdk.RewardedVideoListener
import com.ironsource.mediationsdk.sdk.InterstitialListener

interface OnActivityRegistry {
  fun addOnResumeListener(callback: OnResumeCallback)
  fun addOnActivityResultListener(callback: OnActivityResultCallback)
}

interface OnResumeCallback {
  fun onResume()
}

interface OnActivityResultRegistry {
  fun addOnActivityResultListener(callback: OnActivityResultCallback)
}

interface OnActivityResultCallback {
  fun onActivityResult()
}

class MainActivity : FlutterActivity(), OnActivityRegistry {

  private var onResumeCallbacks = mutableListOf<OnResumeCallback>()
  private var onActivityResultCallbacks = mutableListOf<OnActivityResultCallback>()
  private var unityGameID = "5037701"
  private var testMode = true
  private var adUnitId = "Interstitial_Android";

  val mInterstitialListener = object : InterstitialListener {
    override fun onInterstitialAdReady() {
      
    }

    override fun onInterstitialAdLoadFailed(p0: IronSourceError?) {
      
    }

    override fun onInterstitialAdOpened() {
      
    }

    override fun onInterstitialAdClosed() {
      
    }

    override fun onInterstitialAdShowSucceeded() {
      
    }

    override fun onInterstitialAdShowFailed(p0: IronSourceError?) {
      
    }

    override fun onInterstitialAdClicked() {
      
    }
  }

  val mRewardedVideoListener = object : RewardedVideoListener {
    override fun onRewardedVideoAdOpened() {
      
    }

    override fun onRewardedVideoAdClosed() {
      
    }

    override fun onRewardedVideoAvailabilityChanged(p0: Boolean) {

    }

    override fun onRewardedVideoAdStarted() {
      
    }

    override fun onRewardedVideoAdEnded() {
      
    }

    override fun onRewardedVideoAdRewarded(p0: Placement?) {
      
    }

    override fun onRewardedVideoAdShowFailed(p0: IronSourceError?) {
      
    }

    override fun onRewardedVideoAdClicked(p0: Placement?) {
      
    }
  }

  companion object {
    const val TAG = "MainActivity"
    const val VARITY_FOREGROUND_CHANNEL = "com.mixaline.varity/foreground_channel"
    var backgroundFlutterEngine: FlutterEngine? = null
    var backgroundHandler: BackgroundHandler? = null
    var clientHandler: ClientHandler? = null
    var mainClientHandler: ClientHandler? = null
    var clientHandlers: MutableSet<ClientHandler> = mutableSetOf()
    var backgroundCallbackHandle: Long = -1L
    var bundlePath: String? = null
    
    @Volatile var startResult: MethodChannel.Result? = null
    @Volatile var stopResult: MethodChannel.Result? = null

    @JvmStatic
    fun sendStartResult(result: Boolean) {
      if (startResult != null) {
        startResult?.success(result)
        startResult = null
      }
    }

    @JvmStatic
    fun sendStopResult(result: Boolean) {
      if (stopResult != null) {
        stopResult?.success(result)
        stopResult = null
      }
    }
  }
  

  override fun onCreate(savedInstanceState: Bundle?) {
     val appKey = "1793e84ad";
    super.onCreate(savedInstanceState);
    IronSource.setRewardedVideoListener(mRewardedVideoListener)
    IronSource.setInterstitialListener(mInterstitialListener)
    /**
     *Ad Units should be in the type of IronSource.Ad_Unit.AdUnitName, example
     */
    
    IronSource.init(this, appKey, IronSource.AD_UNIT.REWARDED_VIDEO)
    // UnityAds.
    // Appodeal.initialize(
    //     "appKey",
    //     adTypes,
    //     object : ApdInitializationCallback {
    //       override fun onInitializationFinished(list: List<ApdInitializationError>?) {
    //         // Appodeal initialization finished
    //       }
    //     }
    // )
    // #AppDatabase.getInstance(applicationContext)
    // ACCESSIBILITY_SERVICE_NAME =
    //   "$packageName/${WorkManagerService::class.java.canonicalName}"
  }



  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    Ln.d(TAG, "configuringEngine")
    clientHandler = ClientHandler(flutterEngine.dartExecutor.binaryMessenger)
    clientHandler?.setActivity(this)
    clientHandler?.setContext(this)
    clientHandler?.setOnResumeRegistry(this)
    clientHandlers.add(clientHandler!!)
    mainClientHandler = clientHandler
  }

  override fun detachFromFlutterEngine() {
    super.detachFromFlutterEngine()
    clientHandlers.remove(clientHandler)
  }

  override fun onPause() {
    clientHandler?.setActivity(null)
    clientHandler?.setContext(applicationContext)
    IronSource.onPause(this)
    super.onPause()
  }

  override fun onResume() {
    super.onResume()
    for (cb in onResumeCallbacks) {
      cb.onResume()
    }
    IronSource.onResume(this)
  }

  override fun onPostResume() {
    super.onPostResume()
    clientHandler?.setActivity(this)
    clientHandler?.setContext(this)
  }

  override fun onDestroy() {
    clientHandler?.setActivity(null)
    clientHandler?.setContext(applicationContext)
    clientHandlers = clientHandlers.filter { it != clientHandler }.toMutableSet()
    if (clientHandler == mainClientHandler) {
      mainClientHandler = null
    }
    super.onDestroy()
  }

  override fun addOnResumeListener(callback: OnResumeCallback) {
    onResumeCallbacks.add(callback)
  }

  override fun addOnActivityResultListener(callback: OnActivityResultCallback) {
    onActivityResultCallbacks.add(callback)
  }
}
