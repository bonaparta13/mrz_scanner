# MRZ Scanner

A lightweight Flutter plugin for scanning and parsing Machine Readable Zones (MRZ) from passports, ID cards, and visas. Supports both **live camera scanning** and **image file parsing**.

## Supported Formats

| Format | Description | Lines |
|--------|-------------|-------|
| TD1 | ID Cards | 3 x 30 chars |
| TD2 | ID Cards | 2 x 36 chars |
| TD3 | Passports | 2 x 44 chars |
| MRVA | Visas | 2 x 44 chars |
| MRVB | Visas | 2 x 36 chars |

## Platform Support

|                | Android | iOS      |
|----------------|---------|----------|
| **Support**    | SDK 24+ | iOS 13+  |

> **Note:** Camera scanning requires a real device, not an emulator.

## Setup

### Android

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS

Add to `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Allow Camera to scan MRZ</string>
```

## Usage

```dart
import 'package:mrz_scanner/mrz_scanner.dart';
```

### Camera Scanning

Use the `MRZScanner` widget for live camera-based scanning:

```dart
MRZScanner(
  onSuccess: (mrzResult, lines) {
    print(mrzResult.documentNumber);
    print(mrzResult.givenNames);
    print(mrzResult.surnames);
    print(mrzResult.birthDate);
    print(mrzResult.expiryDate);
    print(mrzResult.sex);
    print(mrzResult.countryCode);
  },
)
```

#### Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onSuccess` | `Function(MRZResult, List<String>)` | required | Callback with parsed result and raw MRZ lines |
| `initialDirection` | `CameraLensDirection` | `back` | Camera to use |
| `showOverlay` | `bool` | `true` | Show document frame overlay |
| `controller` | `MRZController?` | `null` | Controller for resetting scan state |

#### Resetting the Scanner

Use a controller to reset scanning after a successful read:

```dart
final controller = MRZController();

MRZScanner(
  controller: controller,
  onSuccess: (result, lines) {
    // Process result, then allow scanning again
    controller.currentState?.resetScanning();
  },
)
```

### Image File Scanning

Use `MRZScanner.scanImage()` to parse an MRZ from a file path (e.g. from gallery or file picker):

```dart
try {
  final result = await MRZScanner.scanImage('/path/to/document.jpg');
  print(result.documentNumber);
} on FormatException {
  print('No valid MRZ found in image');
}
```

### MRZResult Fields

| Field | Type | Description |
|-------|------|-------------|
| `documentType` | `String` | Document type (P, I, V, etc.) |
| `countryCode` | `String` | Issuing country code |
| `surnames` | `String` | Holder's surnames |
| `givenNames` | `String` | Holder's given names |
| `documentNumber` | `String` | Document number |
| `nationalityCountryCode` | `String` | Nationality country code |
| `birthDate` | `DateTime` | Date of birth |
| `sex` | `Sex` | `Sex.male`, `Sex.female`, or `Sex.none` |
| `expiryDate` | `DateTime` | Expiry date |
| `personalNumber` | `String` | Personal/optional number |

## Demo

![Demo](demo.gif)

## License

`mrz_scanner` is released under a [MIT License](https://opensource.org/licenses/MIT). See `LICENSE` for details.
