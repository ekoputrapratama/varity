package com.mixaline.varity

import android.content.ContentValues
import android.database.Cursor
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import com.mixaline.sonicdb.Database
import com.mixaline.sonicdb.Ln
import com.mixaline.sonicdb.Operation
import com.mixaline.sonicdb.TAG
import com.mixaline.sonicdb.utils.toContentValues
import com.mixaline.varity.model.App
import java.io.File

class Database(val path: String) {
  lateinit var sqliteDatabase: SQLiteDatabase

  fun open() {
    
    sqliteDatabase = SQLiteDatabase.openDatabase(path, null,
      SQLiteDatabase.CREATE_IF_NECESSARY)
  }

  fun openReadOnly() {
    sqliteDatabase = SQLiteDatabase.openDatabase(path, null,
      SQLiteDatabase.OPEN_READONLY, DatabaseErrorHandler {

      })
  }

  fun close() {
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
  }

  fun getWritableDatabase(): SQLiteDatabase {
    return sqliteDatabase
  }

  fun getReadableDatabase(): SQLiteDatabase {
    return sqliteDatabase
  }

  fun getDatabasePath(): String {
    return path
  }

  fun exists(): Boolean {
    return File(path).exists()
  }

  fun createTableIfNotExists(name: String, columns: List<String>) {
    
    Ln.d(TAG, "create table $name with columns (${columns.joinToString(",")})")
    val db = getReadableDatabase()
    var query = "create table if not exists $name (${columns.joinToString(",")});"

    db.execSQL(query)
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
  }

  fun insert(table: String, value: Map<*, *>): Boolean {
    val db = getWritableDatabase()

    val values = toContentValues(value)
    val inserted = db.insert(table, null, values)
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
    return inserted > 0
  }

  fun update(table: String, values: ContentValues, whereClause: String?): Boolean {
    var updated = false;
    try {
      val db = getWritableDatabase()
      updated = db.update(table, values, whereClause, null) > 0
    } catch(e: Exception) {
      return false
    }
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
    return updated
  }
  
  fun updateDayVolume(packageName: String, volume: Int) {
    val values = ContentValues()
    values.put("day_volume", volume)
    val whereClause = "package_name='$packageName'"
    
    update("apps", values, whereClause)
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
  }
  fun updateNightVolume(packageName: String, volume: Int) {
    val values = ContentValues()
    values.put("night_volume", volume)
    val whereClause = "package_name='$packageName'"

    update("apps", values, whereClause)
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
  }
  
  fun updateDayBrightness(packageName: String, brightness: Int) {
    val values = ContentValues()
    values.put("day_brightness", brightness)
    val whereClause = "package_name='$packageName'"

    update("apps", values, whereClause)
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
  }
  
  fun updateNightBrightness(packageName: String, brightness: Int) {
    val values = ContentValues()
    values.put("night_brightness", brightness)
    val whereClause = "package_name='$packageName'"

    update("apps", values, whereClause)
    if(sqliteDatabase.isOpen) {
      sqliteDatabase.close()
    }
  }

  fun getApps() : List<App> {
    val q = "select * from apps"
    val list = query(q)
    
    val results = list.mapNotNull { 
      App.fromMap(it)
    }
    
    return results
  }
   
  fun getApp(packageName: String) : App? {
    val q = "select * from apps where package_name='$packageName'"
    Ln.d("getApp query $q")
    val list = query(q)

    val results = list.mapNotNull {
      App.fromMap(it)
    }
    try {
      return results.first()
    } catch(e: Exception) {
      return null
    }
  }
  

  private fun query(sqlQuery: String): MutableList<Map<String, Any?>> {
    val results = mutableListOf<Map<String, Any?>>()
    var cursor: Cursor? = null
    try {
      cursor = getReadableDatabase().rawQuery(sqlQuery, null)

      while(cursor.moveToNext()) {
        results.add(rowToMap(cursor))
      }
    } catch(e: Exception) {
      Ln.e(e.message)
    } finally {
      cursor?.close()
    }
    return results
  }
}

internal fun rowToMap(cursor: Cursor): Map<String, Any?> {
  val map = mutableMapOf<String, Any?>()
  val columns = cursor.columnNames
  for(i in columns.indices) {
    map[columns[i]] = parseDataValue(cursor, i)
  }
  return map
}
internal fun parseDataValue(cursor: Cursor, index: Int): Any? {

  return when(cursor.getType(index)) {
    Cursor.FIELD_TYPE_INTEGER -> {
      return cursor.getInt(index)
    }
    Cursor.FIELD_TYPE_FLOAT -> {
      return cursor.getDouble(index)
    }
    Cursor.FIELD_TYPE_STRING -> {
      return cursor.getString(index)
    }
    Cursor.FIELD_TYPE_BLOB -> {
      return cursor.getBlob(index)
    }
    else -> null
  }
}
