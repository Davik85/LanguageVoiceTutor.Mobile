package com.languagevoicetutor.mobile

import java.io.File
import java.util.UUID

/** Supply Android's noBackupFilesDir; this file must never be backed up. */
internal object InstallationDeviceName {
    @Synchronized
    fun load(directory: File, manufacturer: String?, model: String?): String {
        val file = File(directory, "orralen-device-name-v1")
        if (file.exists()) {
            val saved = file.readText()
            require(saved.length <= 128 && saved.matches(Regex(".* \\[([0-9a-f-]{36})\\]")))
            return saved
        }
        val description = listOf(manufacturer, model)
            .filterNotNull().filter { it.isNotBlank() }.joinToString(" ")
            .replace(Regex("[\\p{Cntrl}\\s]+"), " ").trim().ifBlank { "Android device" }
        val name = description.take(89) + " [" + UUID.randomUUID().toString() + "]"
        val temporary = File(directory, "orralen-device-name-v1.tmp")
        temporary.writeText(name)
        check(temporary.renameTo(file))
        return name
    }
}
