# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# WebView Flutter
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Prevent obfuscation of specific flutter classes
-keep class com.google.crypto.tink.** { *; }

# Handle View in AR / Model Viewer
-keep class com.google.ar.core.** { *; }
-keep class com.google.ar.sceneform.** { *; }

# General optimization rules
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Strip debug and verbose logs for security and performance
-assumenosideeffects class android.util.Log {
    public static int d(...);
    public static int v(...);
    public static int i(...);
}

# Keep for debugging if needed (comment out for production)
#-keepattributes SourceFile,LineNumberTable
