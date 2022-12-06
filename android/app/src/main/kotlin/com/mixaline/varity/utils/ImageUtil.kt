package com.mixaline.varity.utils

import android.content.Context
import android.content.res.Resources
import android.graphics.*
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import kotlin.math.floor
import kotlin.math.sqrt


class ImageUtil {
  companion object {
    @JvmStatic
    fun rescaleImage(icon: Drawable) : Bitmap {
      var iconHeight = icon.intrinsicHeight
      var iconWidth = icon.intrinsicWidth
      val maxHeight = 64

      var scale = -1f
      if (iconHeight > maxHeight) {
        scale = maxHeight.toFloat() / iconHeight
      }

      if (scale != -1f) {
        iconWidth = (scale * iconWidth).toInt()
        iconHeight = (scale * iconHeight).toInt()
      }

      val resizedImg = Bitmap.createBitmap(iconWidth, iconHeight, Bitmap.Config.ARGB_8888)
      val y = (resizedImg!!.height - iconHeight) / 2

      renderDrawableToBitmap(
        icon, resizedImg, 0, y, iconWidth,
        iconHeight
      )

      return resizedImg
    }
    
    @JvmStatic
    fun saveToCache(context: Context, bitmap: Bitmap, name: String) : String? {
      val cacheDirPath = "${context.cacheDir.absolutePath}/icons"
      val cacheDir = File(cacheDirPath)
      
      if(!cacheDir.exists() && cacheDir.canWrite()) {
        cacheDir.mkdirs()
      }

      val file = File(cacheDir, name)
      try {
        val out = FileOutputStream(file);
        bitmap.compress(
                Bitmap.CompressFormat.PNG,
                100, out);
        out.flush();
        out.close();
        return file.absolutePath
      } catch (e: FileNotFoundException) {
        e.printStackTrace();
      } catch (e: IOException) {
        e.printStackTrace();
      }
      return null
    }
    /**
     * Convert a Bitmap to a Bitmap that has 4 bytes per pixel
     * @param input The bitmap to convert to a 4 bytes per pixel Bitmap
     *
     * @return The converted Bitmap. Note: The caller of this method is
     * responsible for reycling the input
     */
    fun to4BytesPerPixelBitmap(input: Bitmap): Bitmap {
      val bitmap = Bitmap.createBitmap(input.width, input.height, Bitmap.Config.ARGB_8888)
      // Instantiate the canvas to draw on:
      val canvas = Canvas(bitmap)
      canvas.drawBitmap(input, 0f, 0f, null)
      // Return the new bitmap:
      return bitmap
    }

    /**
     * Method to scale the Bitmap to respect the max bytes
     *
     * @param input    the Bitmap to scale if too large
     * @param maxBytes the amount of bytes the Image may be
     * @return The scaled bitmap or the input if already valid
     * @Note: The caller of this function is responsible for recycling once the input is no longer needed
     */
    fun scaleBitmap(input: Bitmap, maxBytes: Long): Bitmap {
      val currentWidth = input.width
      val currentHeight = input.height
      val currentPixels = currentWidth * currentHeight
      // Get the amount of max pixels:
      // 1 pixel = 4 bytes (R, G, B, A)
      val maxPixels = maxBytes / 4 // Floored
      if (currentPixels <= maxPixels) {
        // Already correct size:
        return input
      }
      // Scaling factor when maintaining aspect ratio is the square root since x and y have a relation:
      val scaleFactor = sqrt(maxPixels / currentPixels.toDouble())
      val newWidthPx = floor(currentWidth * scaleFactor).toInt()
      val newHeightPx = floor(currentHeight * scaleFactor).toInt()

      return Bitmap.createScaledBitmap(input, newWidthPx, newHeightPx, true)
    }
    fun renderDrawableToBitmap(
      d: Drawable?,
      bitmap: Bitmap?,
      x: Int,
      y: Int,
      w: Int,
      h: Int,
      alpha: Int = 255
    ) {
      if (bitmap != null) {
        val c = Canvas(bitmap)
        val oldBounds = d!!.copyBounds()
        var oldAlpha = 0
        if (Build.VERSION.SDK_INT >= 19) {
          oldAlpha = d.alpha
          d.alpha = alpha
        }
        d.setBounds(x, y, x + w, y + h)

        d.draw(c)
        d.bounds = oldBounds // Restore the bounds
        if (Build.VERSION.SDK_INT >= 19) {
          d.alpha = oldAlpha
        }
        c.setBitmap(null)

      }
    }

    fun cropImage(bitmap: Bitmap, rect: Rect): Bitmap {
      val result = Bitmap.createBitmap(
        rect.right - rect.left,
        rect.bottom - rect.top,
        Bitmap.Config.ARGB_8888
      )
      val canvas = Canvas(result)

      val top = if (rect.top > 0) {
        -(bitmap.height - rect.top)
      } else 0
      val left = if (rect.left > 0) {
        -(bitmap.width - rect.left)
      } else 0

      canvas.drawBitmap(bitmap, left.toFloat(), top.toFloat(), null)
      canvas.setBitmap(null)
      return result
    }

    fun grayscaleImage(bitmap: Bitmap): Bitmap {
      val result = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)

      val canvas = Canvas(result)
      val paint = Paint()

      val cm = ColorMatrix()
      cm.setSaturation(0f)
      paint.colorFilter = ColorMatrixColorFilter(cm)
      canvas.drawBitmap(bitmap, 0f, 0f, paint)
      canvas.setBitmap(null)
      return result
    }

    fun drawBorder(bitmap: Bitmap, size: Float, color: Int, alpha: Int = 255, padding: Rect? = null): Bitmap {
      val width = bitmap.width.toFloat()
      val height = bitmap.height.toFloat()
      val newBitmap = Bitmap.createBitmap(bitmap)
      val c = Canvas(newBitmap)
      val paint = Paint()
      paint.strokeWidth = size
      paint.color = color
      paint.alpha = alpha
      paint.style = Paint.Style.STROKE

      var left = 0f
      var top = 0f
      var right = width
      var bottom = height

      if (padding != null) {
        left = padding.left.toFloat()
        top = padding.top.toFloat()
        right = width - padding.right
        bottom = height - padding.bottom
      }

      c.drawRect(left, top, right, bottom, paint)
      c.drawBitmap(newBitmap, 0f, 0f, null)

      c.setBitmap(null)

      return newBitmap
    }

    fun addPadding(bitmap: Bitmap, paddingX: Float, paddingY: Float): Bitmap {
      val outputimage = Bitmap.createBitmap(
        bitmap.width + (paddingX.toInt() / 2),
        bitmap.height + (paddingY.toInt() / 2),
        Bitmap.Config.ARGB_8888
      )
      val can = Canvas(outputimage)
      can.drawColor(Color.TRANSPARENT) //This represents White color
      can.drawBitmap(bitmap, paddingX / 2, paddingY / 2, null)
      return outputimage
    }

    fun resizeImage(res: Resources, drawable: Drawable, width: Int, height: Int): Drawable {
      val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
      val c = Canvas(bitmap)
      val oldBounds = drawable.copyBounds()
      drawable.setBounds(0, 0, width, height)
      drawable.draw(c)
      drawable.bounds = oldBounds
      c.setBitmap(null)
      return BitmapDrawable(res, bitmap)
    }

    fun resizeImage(res: Resources, bitmap: Bitmap, width: Int, height: Int): Bitmap {
      val drawable = BitmapDrawable(res, bitmap)
      val newBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
      val c = Canvas(newBitmap)
      val oldBounds = drawable.copyBounds()
      drawable.setBounds(0, 0, width, height)
      drawable.draw(c)
      drawable.bounds = oldBounds
      c.setBitmap(null)
      return newBitmap
    }

    fun getImageUri(inContext: Context, inImage: Bitmap, title: String, description: String? = null): Uri {
      val bytes = ByteArrayOutputStream()
      inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes)
      val path = MediaStore.Images.Media.insertImage(
        inContext.contentResolver,
        inImage,
        title,
        description
      )
      return Uri.parse(path)
    }

    fun drawableToBitmap(drawable: Drawable?): Bitmap? {
      if (drawable == null) {
        return null
      }

      if (drawable is BitmapDrawable) {
        val bitmapDrawable = drawable as BitmapDrawable?
        if (bitmapDrawable!!.bitmap != null) {
          return bitmapDrawable.bitmap
        }
      }

      val bitmap: Bitmap
      if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {
        // single color bitmap will be created
        bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
      } else {
        bitmap = Bitmap.createBitmap(
          drawable.intrinsicWidth,
          drawable.intrinsicHeight,
          Bitmap.Config.ARGB_8888
        )
      }

      val canvas = Canvas(bitmap)
      drawable.setBounds(0, 0, drawable.intrinsicWidth, drawable.intrinsicHeight)
      drawable.draw(canvas)

      return bitmap
    }

    fun removeMargins(bmp: Bitmap, color: Int): Bitmap {
      var MTop = 0
      var MBot = 0
      var MLeft = 0
      var MRight = 0
      var found = false

      val bmpIn = IntArray(bmp.width * bmp.height)
      val bmpInt = Array(bmp.width) { IntArray(bmp.height) }

      bmp.getPixels(
        bmpIn, 0, bmp.width, 0, 0, bmp.width,
        bmp.height
      )

      var ii = 0
      var contX = 0
      var contY = 0
      while (ii < bmpIn.size) {
        bmpInt[contX][contY] = bmpIn[ii]
        contX++
        if (contX >= bmp.width) {
          contX = 0
          contY++
          if (contY >= bmp.height) {
            break
          }
        }
        ii++
      }

      run {
        var hP = 0
        while (hP < bmpInt[0].size && !found) {
          // looking for MTop
          var wP = 0
          while (wP < bmpInt.size && !found) {
            if (bmpInt[wP][hP] != color) {
              MTop = hP
              found = true
              break
            }
            wP++
          }
          hP++
        }
      }
      found = false

      run {
        var hP = bmpInt[0].size - 1
        while (hP >= 0 && !found) {
          // looking for MBot
          var wP = 0
          while (wP < bmpInt.size && !found) {
            if (bmpInt[wP][hP] != color) {
              MBot = bmp.height - hP
              found = true
              break
            }
            wP++
          }
          hP--
        }
      }
      found = false

      run {
        var wP = 0
        while (wP < bmpInt.size && !found) {
          // looking for MLeft
          var hP = 0
          while (hP < bmpInt[0].size && !found) {
            if (bmpInt[wP][hP] != color) {
              MLeft = wP
              found = true
              break
            }
            hP++
          }
          wP++
        }
      }
      found = false

      var wP = bmpInt.size - 1
      while (wP >= 0 && !found) {
        // looking for MRight
        var hP = 0
        while (hP < bmpInt[0].size && !found) {
          if (bmpInt[wP][hP] != color) {
            MRight = bmp.width - wP
            found = true
            break
          }
          hP++
        }
        wP--

      }
      found = false

      val sizeY = bmp.height - MBot - MTop
      val sizeX = (bmp.width
        - MRight - MLeft)

      return Bitmap.createBitmap(bmp, MLeft, MTop, sizeX, sizeY)
    }


    fun getIcon(context: Context, filename: String): Drawable? {
      val bitmap = BitmapFactory.decodeFile(context.filesDir.toString() + "/icons/" + filename + ".png")
      return if (bitmap != null) BitmapDrawable(context.resources, bitmap) else null
    }

    fun saveIcon(context: Context, icon: Bitmap, filename: String) {
      val directory = File(context.filesDir.toString() + "/icons/")
      if (!directory.exists()) directory.mkdir()
      val file = File(directory.path + filename + ".png")
      try {
        file.createNewFile()
        val out = FileOutputStream(file)
        icon.compress(Bitmap.CompressFormat.PNG, 100, out)
        out.close()
      } catch (e: Exception) {
        e.printStackTrace()
      }

    }

    fun removeIcon(context: Context, filename: String) {
      val file = File(context.filesDir.toString() + "/icons/" + filename + ".png")
      if (file.exists()) {
        try {
          file.delete()
        } catch (e: Exception) {
          e.printStackTrace()
        }

      }
    }
  }
}
