package com.mixaline.varity.model

import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.media.AudioManager
import android.provider.Settings
import androidx.appcompat.widget.AppCompatImageView
import androidx.core.graphics.drawable.toBitmap
// import androidx.databinding.BindingAdapter
import androidx.room.*
// import com.warkiz.widget.IndicatorSeekBar

import com.mixaline.varity.*
import com.mixaline.varity.utils.*

import kotlinx.coroutines.flow.Flow
import java.io.ByteArrayOutputStream


@Entity(tableName = "apps", indices = [Index("package_name")])
data class App(
  @ColumnInfo(name = "package_name") val packageName: String,
  @ColumnInfo(name = "name") val name: String,
  @ColumnInfo(name = "icon", typeAffinity = ColumnInfo.BLOB) val icon: ByteArray,
  @ColumnInfo(name = "day_volume") val dayVolume: Int = -1,
  @ColumnInfo(name = "night_volume") val nightVolume: Int = -1,
  @ColumnInfo(name = "day_brightness") val dayBrightness: Int = -1,
  @ColumnInfo(name = "night_brightness") val nightBrightness: Int = -1
) {
  @PrimaryKey(autoGenerate = true)
  @ColumnInfo(name = "_id")
  var id: Long = 0
  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as App

    if (packageName != other.packageName) return false
    if (name != other.name) return false
    if (!icon.contentEquals(other.icon)) return false
    if (dayVolume != other.dayVolume) return false
    if (nightVolume != other.nightVolume) return false
    if (dayBrightness != other.dayBrightness) return false
    if (nightBrightness != other.nightBrightness) return false
    if (id != other.id) return false

    return true
  }
  override fun toString() : String {
    return toMap().toString()
  }

  override fun hashCode(): Int {
    var result = packageName.hashCode()
    result = 31 * result + name.hashCode()
    result = 31 * result + icon.contentHashCode()
    result = 31 * result + dayVolume
    result = 31 * result + nightVolume
    result = 31 * result + dayBrightness
    result = 31 * result + nightBrightness
    result = 31 * result + id.hashCode()
    return result
  }
  
  fun toMap() {
    val map = mutableMapOf<String, Any?>()
    map["package_name"] = packageName
    map["name"] = name
    map["icon"] = icon
    map["day_volume"] = dayVolume
    map["night_volume"] = nightVolume
    map["day_brightness"] = dayBrightness
    map["night_brightness"] = nightBrightness
  }
  
  companion object {
    @JvmStatic
    fun fromMap(map: Map<*,*>) : App {
      return App(
        map["package_name"] as String,
        map["name"] as String,
        map["icon"] as ByteArray,
        map["day_volume"] as Int,
        map["night_volume"] as Int,
        map["day_brightness"] as Int,
        map["night_brightness"] as Int
      )
    }
  }
}

@Dao
interface AppDao {
  @Query("select * from apps")
  fun getApps(): Flow<List<App>>

  @Query("select * from apps where package_name = :packageName")
  fun getApp(packageName: String): App?

  @Query("select day_volume from apps where package_name = :packageName")
  fun getDayVolume(packageName: String): Int?
  @Query("UPDATE apps set day_volume = :volume where package_name = :packageName")
  fun updateDayVolume(packageName: String, volume: Int)
  @Query("UPDATE apps set night_volume = :volume where package_name = :packageName")
  fun updateNightVolume(packageName: String, volume: Int)

  @Query("UPDATE apps set day_brightness = :brightness where package_name = :packageName")
  fun updateDayBrightness(packageName: String, brightness: Int)
  @Query("UPDATE apps set night_brightness = :brightness where package_name = :packageName")
  fun updateNightBrightness(packageName: String, brightness: Int)

  @Insert(onConflict = OnConflictStrategy.IGNORE)
  suspend fun insert(app: App): Long
  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertAll(apps: List<App>)

  @Query("DELETE FROM apps WHERE package_name = :packageName")
  fun deleteApp(packageName: String)
}
