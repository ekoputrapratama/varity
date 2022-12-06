package com.mixaline.varity.utils

import android.app.Activity
import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import androidx.arch.core.util.Function


val mainHandler by lazy { Handler(Looper.getMainLooper()) }

fun runOnMainThread(r: () -> Unit) {
  runOnThread(mainHandler, r)
}

fun runOnThread(handler: Handler, r: () -> Unit) {
  if (handler.looper.thread.id == Looper.myLooper()?.thread?.id) {
    r()
  } else {
    handler.post(r)
  }
}

//fun runOnUiThread(r: () -> Unit) {
//  HomeActivity.launcher.runOnUiThread(r)
//}
fun runOnUiThread(activity: Activity, r: () -> Unit) {
  activity.runOnUiThread(r)
}

typealias UiThreadCallback = Function<Array<out Any?>, Unit>

fun interface CommonCallback {
  fun invoke(vararg params: Any?)
}

//var h: Function<Array<out Any>, Void> = null

fun createUiThreadCallback(activity: Activity, r: CommonCallback): CommonCallback {
  return CommonCallback { params ->
    activity.runOnUiThread{
      r.invoke(*params)
    }
  }
}

fun runOnAsyncTask(r: () -> Unit): AsyncTask<() -> Unit, Any, Any> {

  return GeneralAsyncTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, r)
}

fun <V> runUpdateAsync(valueType: Class<V>,cb: AsyncTaskCallback<Any, V>): Any {
  return SimpleAsyncTask<V>(valueType, cb).execute()
}

fun <V> createPublishCallback(task: SimpleAsyncTask<V>, valueType: Class<V>): (value: V) -> Unit {
  Ln.d("createPublishCallback ")
  return fun(value: V) {
    Ln.d("publishProgress $value")
    val method = task.javaClass.getMethod("publishProgress", valueType)
    method.isAccessible = true
    method.invoke(task, value)
  }
}

abstract class AsyncTaskCallback<T, V> {
  private lateinit var task: AsyncTask<Any, V, Unit>
  abstract fun doInBackground(vararg params: T?, publish: (value: V) -> Unit): V?
  abstract fun onProgressUpdate(vararg values: V?)
  abstract fun onPreExecute()
  fun publish(){
    if(task != null) {

    }
  }
  fun setTask(t: AsyncTask<Any, V, Unit>){
    task = t
  }
//  fun onPostExecute()
}


class SimpleAsyncTask<V>(val valueType:Class<V>,val cb: AsyncTaskCallback<Any, V>) : AsyncTask<Any, V, Unit>() {
  override fun onPreExecute() {
    super.onPreExecute()
    cb.onPreExecute()
  }

  override fun doInBackground(vararg params: Any) {
    cb.doInBackground(params, publish = createPublishCallback<V>(this, valueType))
  }

  override fun onProgressUpdate(vararg values: V) {
    Ln.d("onProgressUpdate $values")
    cb.onProgressUpdate(*values)
  }
}

//fun <V> AsyncTask<Any, V, Any>.publishProgress(value: V) {
//  publishProgress(arrayOf(value))
//}

class GeneralAsyncTask : AsyncTask<() -> Unit, Any, Any>() {
  override fun doInBackground(vararg params: (() -> Unit)?): Any? {
    params[0]!!.invoke()
    return null
  }
}

fun Thread.waitIsAlive(waitUntil: Boolean) {
  while (isAlive != waitUntil) {
    Thread.sleep(100)
  }
}
