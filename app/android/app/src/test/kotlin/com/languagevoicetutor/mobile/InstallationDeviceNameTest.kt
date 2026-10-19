package com.languagevoicetutor.mobile

import java.nio.file.Files
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class InstallationDeviceNameTest {
    @get:Rule val temporary = TemporaryFolder()

    @Test fun nameIsPersistedAcrossLaunchesAndMetadataChanges() {
        val directory = temporary.newFolder()
        val first = InstallationDeviceName.load(directory, "Example", "Model")
        assertEquals(first, InstallationDeviceName.load(directory, "Changed", "Model"))
        assertTrue(first.startsWith("Example Model ["))
    }

    @Test fun separateSameModelInstallationsStayDistinct() {
        assertNotEquals(
            InstallationDeviceName.load(temporary.newFolder(), "Example", "Model"),
            InstallationDeviceName.load(temporary.newFolder(), "Example", "Model"))
    }

    @Test fun lengthIncludesFullUuidAndMissingMetadataHasStableFallback() {
        val bounded = InstallationDeviceName.load(temporary.newFolder(), "x".repeat(200), "y".repeat(200))
        assertEquals(128, bounded.length)
        assertTrue(bounded.matches(Regex(".* \\[([0-9a-f-]{36})\\]")))
        val fallbackDirectory = temporary.newFolder()
        val fallback = InstallationDeviceName.load(fallbackDirectory, null, "")
        assertTrue(fallback.startsWith("Android device ["))
        assertEquals(fallback, InstallationDeviceName.load(fallbackDirectory, "Example", "Model"))
    }

    @Test fun unavailableOrCorruptPersistenceDoesNotCreateAnUnstableReplacement() {
        val directory = temporary.newFolder()
        Files.write(directory.toPath().resolve("orralen-device-name-v1"), "corrupt".toByteArray())
        assertThrows(IllegalArgumentException::class.java) {
            InstallationDeviceName.load(directory, "Example", "Model")
        }
    }
}
