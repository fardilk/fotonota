import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val keystorePresent = keystorePropertiesFile.exists()
if (keystorePresent) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    if (keystorePresent) {
        signingConfigs {
            create("release") {
                val alias = keystoreProperties["keyAlias"] as String?
                val keyPwd = keystoreProperties["keyPassword"] as String?
                val storePath = keystoreProperties["storeFile"] as String?
                val storePwd = keystoreProperties["storePassword"] as String?

                if (!alias.isNullOrBlank()) keyAlias = alias
                if (!keyPwd.isNullOrBlank()) keyPassword = keyPwd
                if (!storePath.isNullOrBlank()) storeFile = file(storePath)
                if (!storePwd.isNullOrBlank()) storePassword = storePwd
            }
        }
    }

    namespace = "com.snapcash.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
    applicationId = "com.snapcash.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use release signing if keystore available, otherwise fall back to debug signing
            // This ensures APKs are always signed and installable
            signingConfig = if (keystorePresent) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services")
