package com.mixaline.varity

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.sqlite.db.SupportSQLiteDatabase
// import androidx.work.OneTimeWorkRequest
// import androidx.work.WorkManager
import com.mixaline.varity.model.App
import com.mixaline.varity.model.AppDao
import com.mixaline.varity.utils.runOnAsyncTask


@Database(entities = [App::class], version = 1, exportSchema = false)
//@TypeConverters(DatabaseConverters::class)
abstract class AppDatabase : RoomDatabase() {

  abstract fun appDao(): AppDao

  companion object {
    const val DATABASE_NAME = "varity.db"
    // For Singleton instantiation
    @Volatile private var instance: AppDatabase? = null

    fun getInstance(context: Context): AppDatabase {
      return instance ?: synchronized(this) {
        instance ?: buildDatabase(context).also { instance = it }
      }
    }

    // Create and pre-populate the database. See this article for more details:
    // https://medium.com/google-developers/7-pro-tips-for-room-fbadea4bfbd1#4785
    private fun buildDatabase(context: Context): AppDatabase {
      return Room.databaseBuilder(context, AppDatabase::class.java, DATABASE_NAME)
        .addCallback(
          object : RoomDatabase.Callback() {
            override fun onCreate(db: SupportSQLiteDatabase) {
              super.onCreate(db)
              //  val request = OneTimeWorkRequest.Builder(AppDatabaseWorker::class.java).build()
              //  WorkManager.getInstance(context).enqueue(request)
            }
          }
        )
        .allowMainThreadQueries()
        .build()
    }
  }
}
