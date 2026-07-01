import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties =
    Properties().apply {
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { load(it) }
        }
    }

fun dartDefine(name: String): String? {
    val encodedDefines =
        providers.gradleProperty("dart-defines").orNull
            ?: providers.environmentVariable("DART_DEFINES").orNull
            ?: return null

    return encodedDefines
        .split(',')
        .mapNotNull { encoded ->
            runCatching {
                String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
            }.getOrNull()
        }
        .firstNotNullOfOrNull { decoded ->
            val parts = decoded.split('=', limit = 2)
            parts.getOrNull(1)?.takeIf { parts.firstOrNull() == name }
        }
}

val googleMapsApiKey =
    dartDefine("GOOGLE_MAPS_API_KEY")
        ?: providers.gradleProperty("GOOGLE_MAPS_API_KEY").orNull
        ?: providers.environmentVariable("GOOGLE_MAPS_API_KEY").orNull
        ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY")
        ?: ""

android {
    namespace = "com.a2zblackcar.customer"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.a2zblackcar.customer"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
