# Keep WorkManager and Room Database classes for reflection
-keep class androidx.work.** { *; }
-keep class * extends androidx.room.RoomDatabase
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.startup.** { *; }
