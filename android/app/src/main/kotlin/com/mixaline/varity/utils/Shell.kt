package com.mixaline.varity.utils

import android.app.Activity
import com.mixaline.varity.utils.Ln
import com.mixaline.varity.utils.runOnAsyncTask
import java.io.*
import kotlin.system.measureTimeMillis

typealias CommandResultCallback = (Shell.CommandResult) -> Unit
typealias CommandFinishedCallback = (Int, String?, String?) -> Unit

open class Shell {

  private var shell: String? = null

  companion object {
    const val TAG = "ST-Shell"
    const val BASH = "bash"
    private const val SH = "sh"
    private const val SU = "su"
    const val ZSH = "zsh"

    private var canSu = false

    val LD_LIBRARY_PATH = System.getenv("LD_LIBRARY_PATH")
    val SYSTEM_PATH = System.getenv("PATH")
    private var mInstance: Shell? = null

    @JvmStatic
    fun newInstance(shell: String? = null): Shell {
      if (mInstance == null) {
        mInstance = Shell(shell ?: SH)
      }

      return mInstance!!
    }

    @JvmStatic
    fun canSu(forceCheck: Boolean = false): Boolean {
      if (forceCheck) {
        val output = Shell(SU).exec("id")
        canSu = output.exitValue == 0 || output.stdout?.contains("uid=0") ?: false
      }
      return canSu
    }

    @JvmStatic
    fun createUiThreadCallback(
      activity: Activity,
      r: CommandFinishedCallback
    ): CommandFinishedCallback {
      return fun(exitCode: Int, stdout: String?, stderr: String?) {
        activity.runOnUiThread {
          r.invoke(exitCode, stdout, stderr)
        }
      }
    }

    @JvmStatic
    fun createAsyncCallback(cb: CommandFinishedCallback): CommandResultCallback {
      return fun(result: Shell.CommandResult) {
        runOnAsyncTask {
          cb.invoke(result.exitValue, result.stdout, result.stderr)
        }
      }
    }
  }

  constructor() {
    this.shell = SH
  }

  constructor(shell: String) {
    this.shell = shell
  }

  fun exec(
    cmd: String,
    cb: CommandFinishedCallback? = null,
    envp: Map<String, String>
  ): CommandResult {
    val newEnv = arrayOf<String>()
    for (env in envp) {
      newEnv[newEnv.size] = "${env.key}=${env.value}"
    }
    return exec(cmd, cb, newEnv)
  }

  fun exec(
    cmd: String,
    cb: CommandFinishedCallback? = null,
    envp: Array<String>? = null
  ): CommandResult {

    val newEnv =
      arrayOf("LD_LIBRARY_PATH=$LD_LIBRARY_PATH", "PATH=$SYSTEM_PATH", *(envp ?: emptyArray()))
    return CommandResult(cb).start(cmd, newEnv)
  }

  fun exec(cmd: String, envp: Map<String, String>): CommandResult {
    val newEnv = arrayOf<String>()
    for (env in envp) {
      newEnv[newEnv.size] = "${env.key}=${env.value}"
    }
    return exec(cmd, newEnv)
  }

  fun exec(cmd: String, envp: Array<String>? = null): CommandResult {

    val newEnv =
      arrayOf("LD_LIBRARY_PATH=$LD_LIBRARY_PATH", "PATH=$SYSTEM_PATH", *(envp ?: emptyArray()))
    return CommandResult().start(cmd, newEnv)
  }

  class RootShell : Shell(SU)

  inner class CommandResult {
    var exitValue: Int = -1
    var stderr: String? = null
    var stdout: String? = null
    private var cb: CommandFinishedCallback? = null

    constructor(cb: CommandFinishedCallback? = null) {
      this.cb = cb
    }

    constructor(exitValue: Int, stdout: String, stderr: String) {
      this.exitValue = exitValue;
      this.stdout = stdout;
      this.stderr = stderr;
    }

    fun start(cmd: String, envp: Array<String>? = null): CommandResult {
      if (cb == null) {
        run(cmd, envp)
      } else {
        runAsync(cmd)
      }

      return this
    }

    private fun run(cmd: String, envp: Array<String>? = null) {
      var process: Process
      val elapsedTime = measureTimeMillis {
        val command = arrayOf(shell, "-c", cmd)
        Ln.d("$TAG -> running command : ${command.joinToString(" ")}")
        process = Runtime.getRuntime().exec(command, envp)
        val stdoutReader = BufferedReader(InputStreamReader(process.inputStream))
        val stderrReader = BufferedReader(InputStreamReader(process.errorStream))

        stdout = stdoutReader.readLines().joinToString(separator = "\n")
        stderr = stderrReader.readLines().joinToString(separator = "\n")

        stdoutReader.close()
        stderrReader.close()

        process.waitFor()
        exitValue = process.exitValue()

        process.destroy()
      }
      Ln.d("$TAG -> running command \"$cmd\" took time $elapsedTime ms")
    }

    private fun run(cmd: String) {
      var process: Process
      val elapsedTime = measureTimeMillis {
        val command = arrayOf(shell, "-c", cmd)
        Ln.d("$TAG -> running command : ${command.joinToString(" ")}")
        process = Runtime.getRuntime().exec(command)
        val stdoutReader = BufferedReader(InputStreamReader(process.inputStream))
        val stderrReader = BufferedReader(InputStreamReader(process.errorStream))

        stdout = stdoutReader.readLines().joinToString(separator = "\n")
        stderr = stderrReader.readLines().joinToString(separator = "\n")

        stdoutReader.close()
        stderrReader.close()

        process.waitFor()
        exitValue = process.exitValue()

        process.destroy()
      }
      Ln.d("$TAG -> running command \"$cmd\" took time $elapsedTime ms")
    }

    private fun runAsync(cmd: String) {
      runOnAsyncTask {
        var stdout: List<String>
        var stderr: List<String>
        var process: Process
        val elapsedTime = measureTimeMillis {
          val command = arrayOf(shell, "-c", cmd)
          Ln.d("$TAG -> running command : ${command.joinToString(" ")}")
          process = Runtime.getRuntime().exec(command)
          val stdoutReader = BufferedReader(InputStreamReader(process.inputStream))
          val stderrReader = BufferedReader(InputStreamReader(process.errorStream))

          StreamGrabber(process.errorStream, StreamGrabber.LogLevel.ERROR).start()
          StreamGrabber(process.inputStream, StreamGrabber.LogLevel.DEBUG).start()

          stdout = stdoutReader.readLines()
          stderr = stderrReader.readLines()

          stdoutReader.close()
          stderrReader.close()

          process.waitFor()
          process.destroy()
        }
        Ln.d("$TAG -> running command \"$cmd\" took time $elapsedTime ms")
        val stdoutStr = stdout.joinToString(separator = "\n")
        val stderrStr = stderr.joinToString(separator = "\n")
        cb?.invoke(process.exitValue(), stdoutStr, stderrStr)
      }
    }

    fun success(): Boolean {
      return exitValue == 0
    }
  }

  class StreamGrabber(
    private var inputStream: InputStream,
    private var logLevel: LogLevel = LogLevel.DEBUG,
    redirect: OutputStream? = null
  ) : Thread() {
    enum class LogLevel {
      DEBUG, INFO, ERROR
    }

    private var outputStream: OutputStream? = redirect

    override fun run() {
      try {
        val pw = if (outputStream != null) {
          PrintWriter(outputStream!!)
        } else null

        val isr = InputStreamReader(inputStream)
        val reader = BufferedReader(isr)

        var line: String?
        while ((reader.readLine().also { line = it }) != null) {
          pw?.println(line)
          when (logLevel) {
            LogLevel.INFO -> Ln.i("$line")
            LogLevel.ERROR -> Ln.e("$line")
            else -> Ln.d("$line")
          }
        }
        pw?.flush();
      } catch (e: IOException) {
        println(e.message)
      }
    }
  }

}


