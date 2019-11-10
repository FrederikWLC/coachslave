## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## Firebase
-keepattributes Signature
# This rule will properly ProGuard all the model classes in
# the package com.coachslave.models
-keepclassmembers class com.coachslave.models.** { *; }

-ignorewarnings

## Revenuecat
-keep class com.revenuecat.purchases.** { *; }
