# MRZ Scanner
A package that allows you to Scan any kind of documents that have any mrz format

##  supported formats
* T1 (Official Travel Documents )
* T2 (Official Travel Documents )
* T3 ( Machine Readable Passports )
* MRVA ( Machine Readable Visas document )
* MRVB ( Machine Readable Visas document )


If you have any feature that you want to see in this package, please feel free to issue a suggestion. 🎉

## Note : to use this package you need real device not an emulator

A Flutter plugin for iOS, Android and Web allowing access to the device cameras.

|                | Android | iOS      |
|----------------|---------|----------|
| **Support**    | SDK 21+ | iOS 10+* |


# Before using the package you need to add permission for camera

### For Android
Add
```
<uses-permission android:name="android.permission.CAMERA" />
```
to `AndroidManifest.xml`

### For iOS
```xml
    <key>NSCameraUsageDescription</key>
    <string>Allow Camera to scan MRZ</string>
```
to `Info.plist`

Import the package and use it in your Flutter App.
```dart
import 'package:mrz_scanner/mrz_scanner.dart';
```
# Simple usage of the package , see a full code in example project <p><a href="https://github.com/F-BONAPARTA/mrz_scanner/tree/main/example">here</a></p>

```dart
 MRZScanner(
      onSuccess: (mrzResult) {},
    ),
```
