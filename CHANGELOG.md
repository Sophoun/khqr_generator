## 0.0.6

* Remove unnecessary dependencies.

---

## 0.0.5

* Update code comments.

---

## 0.0.4

* Update readme.md.

---

## 0.0.3

* Add git url.

---

## 0.0.2

* Add license below README.md.

---

## 0.0.1

* Initial release of the `khqr_generator` library.
  This library provides functionality to generate, verify, and decode KHQR codes for individual and merchant accounts.
  It includes:
  * Enums for `KHQRCurrency` (KHR, USD) and `MerchantType` (individual, merchant).
  * EMV constants and error codes for various validation scenarios.
  * Classes for structuring responses (`KHQRResponse`, `KHQRData`, `VerificationResult`).
  * Data models for `IndividualInfo` and `MerchantInfo` to facilitate QR code generation.
  * CRC and MD5 calculation utilities.
  * Static methods in `KHQRGenerator` for:
    * `generateIndividual`: Generates KHQR for individual accounts.
    * `generateMerchant`: Generates KHQR for merchant accounts.
    * `verify`: Validates KHQR string integrity.
    * `decode`: Parses KHQR string into a structured data map.
