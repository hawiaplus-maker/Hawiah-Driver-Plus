import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load local.properties
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// Flutter version
val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"

// Load keystore
val keystoreProperties = Properties()
val keystoreFile = rootProject.file("key.properties")
if (keystoreFile.exists()) {
    keystoreProperties.load(FileInputStream(keystoreFile))
}

android {
    namespace = "com.future.hawiah.driver.plus"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.future.hawiah.driver.plus"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName

        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }

        externalNativeBuild {
            cmake {
                arguments(
                    "-DANDROID_STL=c++_shared"
                    // -Wl,-z,max-page-size=16384 لا يمكن فرضه مباشرة على Android
                )
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packagingOptions {
        jniLibs.useLegacyPackaging = false
    }
}

// Flutter source
flutter {
    source = "../.."
}

// Dependencies
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// Task لتعديل محاذاة مكتبات .so إلى 16KB
tasks.register("alignNativeLibs") {
    group = "build"
    description = "Align native .so libraries to 16KB page size"

    doLast {
        val libDir = File(buildDir, "intermediates/cmake/release/obj")
        if (!libDir.exists()) {
            println("No native libraries found at ${libDir.absolutePath}")
            return@doLast
        }

        val soFiles = libDir.walkTopDown().filter { it.extension == "so" }
        soFiles.forEach { soFile ->
            val tempFile = File(soFile.parent, "${soFile.name}.tmp")
            val ndkObjcopy = "${android.ndkDirectory}/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-objcopy.exe"

            if (File(ndkObjcopy).exists()) {
                println("Aligning ${soFile.name} to 16KB pages...")
                exec {
                    commandLine(
                        ndkObjcopy,
                        "--pad-to=16384",
                        soFile.absolutePath,
                        tempFile.absolutePath
                    )
                }
                soFile.delete()
                tempFile.renameTo(soFile)
            } else {
                println("NDK objcopy not found at $ndkObjcopy")
            }
        }
    }
}

// ربط Task مع assembleRelease بعد تحميل المشروع
afterEvaluate {
    tasks.findByName("assembleRelease")?.let { assembleReleaseTask ->
        assembleReleaseTask.finalizedBy("alignNativeLibs")
    }
}
