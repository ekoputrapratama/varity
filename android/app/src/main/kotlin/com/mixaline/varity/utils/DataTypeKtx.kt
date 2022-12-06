package com.mixaline.varity.utils

fun Boolean.toInt(): Int {
  return if (this) 1 else 0
}

fun Any.toInt(): Int {
  return when (this) {
    is Boolean -> this.toInt()
    is String -> this.toInt()
    is Long -> this.toInt()
    is Int -> this
    else -> 0
  }
}

fun Int.toBoolean(): Boolean {
  return this > 0
}

fun String.contains(str: String?): Boolean {
  return contains(str?.toRegex() ?: "".toRegex())
}

internal fun Int.isFlagSet(value: Int): Boolean {
  return (this and value) == value
}

fun Map<*, *>.getLong(key: String) : Long? {
  return if (this[key] == null || this[key] is Long) (this[key] as Long) else (this[key] as Int).toLong()
}

fun Map<*, *>.getInt(key: String) : Int? {
  return if (this[key] == null || this[key] is Int) (this[key] as Int) 
  else if(this[key] is String) (this[key] as String).toInt()
  else 0
}

fun Map<*, *>.getString(key: String) : String? {
  return if (this[key] == null || this[key] is String) (this[key] as String) 
  else null
}
