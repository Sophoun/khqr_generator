# KHQR Generator for Dart

[![pub version](https://img.shields.io/pub/v/khqr_generator)](https://pub.dev/packages/khqr_generator)

A Dart library for generating and parsing KHQR codes, based on the Bakong KHQR specification and inspired by the [bakong-khqr npm package](https://www.npmjs.com/package/bakong-khqr).

**Disclaimer:** This library is an independent implementation and is not an official product of the National Bank of Cambodia (NBC) or the Bakong system.

## Features

- Generate KHQR codes for individual and merchant accounts.
- Support for static and dynamic QR codes.
- Verify the validity of KHQR codes.
- Decode KHQR codes to extract the embedded information.
- No external dependencies for core functionality.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  khqr_generator: latest_version
```

Then, run `flutter pub get` to install the package.

## Usage

Import the library in your Dart file:

```dart
import 'package:khqr_generator/khqr_generator.dart';
```

### Generating an Individual QR Code

To generate a QR code for an individual, use the `BakongKHQR.generateIndividual` method. You need to provide an `IndividualInfo` object with the required information.

**Example: Static QR Code**

```dart
final individualInfo = IndividualInfo(
  bakongAccountID: 'test@test',
  merchantName: 'Test Merchant',
  merchantCity: 'Phnom Penh',
);

final response = BakongKHQR.generateIndividual(individualInfo);

if (response.status.code == 0) {
  print('QR Code: ${response.data!.qr}');
  print('MD5: ${response.data!.md5}');
} else {
  print('Error: ${response.status.message}');
}
```

**Example: Dynamic QR Code (with amount)**

```dart
final individualInfo = IndividualInfo(
  bakongAccountID: 'test@test',
  merchantName: 'Test Merchant',
  merchantCity: 'Phnom Penh',
  amount: 100.0,
  currency: KHQRCurrency.usd.code,
  expirationTimestamp: DateTime.now().millisecondsSinceEpoch + 3600000, // 1 hour from now
);

final response = BakongKHQR.generateIndividual(individualInfo);

if (response.status.code == 0) {
  print('QR Code: ${response.data!.qr}');
} else {
  print('Error: ${response.status.message}');
}
```

### Generating a Merchant QR Code

To generate a QR code for a merchant, use the `BakongKHQR.generateMerchant` method with a `MerchantInfo` object.

```dart
final merchantInfo = MerchantInfo(
  bakongAccountID: 'test@test',
  merchantName: 'Test Merchant',
  merchantCity: 'Phnom Penh',
  merchantID: '1234567890',
  acquiringBank: 'Test Bank',
);

final response = BakongKHQR.generateMerchant(merchantInfo);

if (response.status.code == 0) {
  print('QR Code: ${response.data!.qr}');
} else {
  print('Error: ${response.status.message}');
}
```

### Verifying a KHQR Code

You can verify the integrity of a KHQR code using the `BakongKHQR.verify` method. This checks the CRC and format of the QR string.

```dart
String qrCode = '...'; // The KHQR string
final result = BakongKHQR.verify(qrCode);

if (result.isValid) {
  print('QR Code is valid.');
} else {
  print('QR Code is invalid.');
}
```

### Decoding a KHQR Code

To decode a KHQR code and extract the embedded information, use the `BakongKHQR.decode` method.

```dart
String qrCode = '...'; // The KHQR string
final response = BakongKHQR.decode(qrCode);

if (response.status.code == 0) {
  final decodedData = response.data!.decodedData;
  print('Decoded Data: $decodedData');
} else {
  print('Error: ${response.status.message}');
}
```

## API Reference

### `BakongKHQR`

This class contains the main methods for generating, verifying, and decoding KHQR codes.

- `static KHQRResponse generateIndividual(IndividualInfo info)`
- `static KHQRResponse generateMerchant(MerchantInfo info)`
- `static VerificationResult verify(String qr)`
- `static KHQRResponse decode(String qr)`

### `IndividualInfo`

This class holds the information for an individual QR code.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `bakongAccountID` | `String` | Yes | The Bakong account ID. |
| `merchantName` | `String` | Yes | The name of the merchant or individual. |
| `merchantCity` | `String` | Yes | The city of the merchant or individual. |
| `amount` | `double` | No | The transaction amount. If provided, the QR becomes dynamic. |
| `currency` | `int` | No | The transaction currency code (from `KHQRCurrency`). Defaults to KHR. |
| `expirationTimestamp` | `int` | No | The expiration timestamp for dynamic QR codes (in milliseconds since epoch). |
| `billNumber` | `String` | No | The bill number for the transaction. |
| `mobileNumber` | `String` | No | The mobile number associated with the transaction. |
| `storeLabel` | `String` | No | The label for the store. |
| `terminalLabel` | `String` | No | The label for the terminal. |
| `purposeOfTransaction` | `String` | No | The purpose of the transaction. |

### `MerchantInfo`

This class extends `IndividualInfo` and adds merchant-specific fields.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `merchantID` | `String` | Yes | The ID of the merchant. |
| `acquiringBank` | `String` | Yes | The acquiring bank for the merchant. |

### `KHQRCurrency`

An enum representing the supported currencies.

- `KHQRCurrency.khr` (code: 116)
- `KHQRCurrency.usd` (code: 840)

## Error Handling

The library returns a `KHQRResponse` object which contains a `status` field. If `status.code` is `0`, the operation was successful. Otherwise, it contains an error code and message.

You can find the list of error codes in the `ErrorCode` class.

```dart
final response = BakongKHQR.generateIndividual(...);

if (response.status.code != 0) {
  print('Error Code: ${response.status.errorCode}');
  print('Error Message: ${response.status.message}');
}
```
