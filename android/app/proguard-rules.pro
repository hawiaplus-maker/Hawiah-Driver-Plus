# ---------------------------------------------------------------------------
# Flutter
# ---------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter plugins are instantiated and registered at runtime.
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.embedding.engine.plugins.activity.ActivityAware { *; }
-keep class * implements io.flutter.embedding.engine.plugins.service.ServiceAware { *; }
-keep class * implements io.flutter.embedding.engine.plugins.broadcastreceiver.BroadcastReceiverAware { *; }
-keep class * implements io.flutter.embedding.engine.plugins.contentprovider.ContentProviderAware { *; }

# Keep annotations, generic signatures and source info for Gson/Firebase/crash reports.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod, SourceFile, LineNumberTable

# JNI/FFI native methods.
-keepclasseswithmembernames class * {
    native <methods>;
}

# webview_flutter JavaScript bridge.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# AndroidX @Keep.
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep <methods>;
    @androidx.annotation.Keep <fields>;
}

# ---------------------------------------------------------------------------
# flutter_local_notifications (Gson reflection)
# ---------------------------------------------------------------------------
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson serializers/adapters.
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ---------------------------------------------------------------------------
# Firebase / Google Play Services optional dependencies
# ---------------------------------------------------------------------------
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.**
-dontwarn com.google.firebase.**
-dontwarn com.google.protobuf.**
-dontwarn org.apache.**
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
