// KHQR Generator for Dart
// Based on khqr-1.0.20.min.js

import 'dart:convert';

import 'src/md5.dart';

// ============================================================================
// Constants and Error Codes
// ============================================================================

/// Represents the supported currencies for KHQR transactions.
enum KHQRCurrency {
  /// Cambodian Riel (KHR) currency with code 116.
  khr(116, 'khr'),

  /// United States Dollar (USD) currency with code 840.
  usd(840, 'usd');

  /// The numeric code of the currency.
  final int code;

  /// The name of the currency.
  final String name;

  /// Creates a [KHQRCurrency] with the given [code] and [name].
  const KHQRCurrency(this.code, this.name);
}

/// Represents the type of merchant for a KHQR transaction.
enum MerchantType {
  /// Indicates an individual merchant.
  individual,

  /// Indicates a business merchant.
  merchant,
}

/// EMV (Europay, MasterCard, and Visa) constants used in KHQR generation.
class EMV {
  /// Tag for Payload Format Indicator.
  static const PAYLOAD_FORMAT_INDICATOR = '00';

  /// Default value for Payload Format Indicator.
  static const DEFAULT_PAYLOAD_FORMAT_INDICATOR = '01';

  /// Tag for Point of Initiation Method.
  static const POINT_OF_INITIATION_METHOD = '01';

  /// Value for Static QR in Point of Initiation Method.
  static const STATIC_QR = '11';

  /// Value for Dynamic QR in Point of Initiation Method.
  static const DYNAMIC_QR = '12';

  /// Tag for Merchant Account Information (Individual).
  static const MERCHANT_ACCOUNT_INFORMATION_INDIVIDUAL = '29';

  /// Tag for Merchant Account Information (Merchant).
  static const MERCHANT_ACCOUNT_INFORMATION_MERCHANT = '30';

  /// Sub-tag for Bakong Account Identifier within Merchant Account Information.
  static const BAKONG_ACCOUNT_IDENTIFIER = '00';

  /// Sub-tag for Merchant ID within Merchant Account Information.
  static const MERCHANT_ACCOUNT_INFORMATION_MERCHANT_ID = '01';

  /// Sub-tag for Individual Account Information within Merchant Account Information.
  static const INDIVIDUAL_ACCOUNT_INFORMATION = '01';

  /// Sub-tag for Acquiring Bank within Merchant Account Information.
  static const MERCHANT_ACCOUNT_INFORMATION_ACQUIRING_BANK = '02';

  /// Tag for Merchant Category Code.
  static const MERCHANT_CATEGORY_CODE = '52';

  /// Default value for Merchant Category Code.
  static const DEFAULT_MERCHANT_CATEGORY_CODE = '5999';

  /// Tag for Transaction Currency.
  static const TRANSACTION_CURRENCY = '53';

  /// Tag for Transaction Amount.
  static const TRANSACTION_AMOUNT = '54';

  /// Default value for Transaction Amount.
  static const DEFAULT_TRANSACTION_AMOUNT = '0';

  /// Tag for Country Code.
  static const COUNTRY_CODE = '58';

  /// Default value for Country Code (Cambodia).
  static const DEFAULT_COUNTRY_CODE = 'KH';

  /// Tag for Merchant Name.
  static const MERCHANT_NAME = '59';

  /// Tag for Merchant City.
  static const MERCHANT_CITY = '60';

  /// Default value for Merchant City (Phnom Penh).
  static const DEFAULT_MERCHANT_CITY = 'Phnom Penh';

  /// Tag for CRC (Cyclic Redundancy Check).
  static const CRC = '63';

  /// Length of the CRC field.
  static const CRC_LENGTH = '04';

  /// Tag for Additional Data Field.
  static const ADDITIONAL_DATA_TAG = '62';

  /// Sub-tag for Bill Number within Additional Data Field.
  static const BILLNUMBER_TAG = '01';

  /// Sub-tag for Mobile Number within Additional Data Field.
  static const ADDITIONAL_DATA_FIELD_MOBILE_NUMBER = '02';

  /// Sub-tag for Store Label within Additional Data Field.
  static const STORELABEL_TAG = '03';

  /// Sub-tag for Terminal Label within Additional Data Field.
  static const TERMINAL_TAG = '07';

  /// Sub-tag for Purpose of Transaction within Additional Data Field.
  static const PURPOSE_OF_TRANSACTION = '08';

  /// Tag for Timestamp.
  static const TIMESTAMP_TAG = '99';

  /// Sub-tag for Creation Timestamp within Timestamp.
  static const CREATION_TIMESTAMP = '00';

  /// Sub-tag for Expiration Timestamp within Timestamp.
  static const EXPIRATION_TIMESTAMP = '01';

  /// Tag for Merchant Information Language Template.
  static const MERCHANT_INFORMATION_LANGUAGE_TEMPLATE = '64';

  /// Sub-tag for Language Preference within Merchant Information Language Template.
  static const LANGUAGE_PREFERENCE = '00';

  /// Sub-tag for Merchant Name Alternate Language within Merchant Information Language Template.
  static const MERCHANT_NAME_ALTERNATE_LANGUAGE = '01';

  /// Sub-tag for Merchant City Alternate Language within Merchant Information Language Template.
  static const MERCHANT_CITY_ALTERNATE_LANGUAGE = '02';

  /// Tag for UnionPay Merchant Account.
  static const UNIONPAY_MERCHANT_ACCOUNT = '15';

  /// Defines invalid lengths for various EMV fields.
  static const INVALID_LENGTH = {
    'KHQR': 12,
    'MERCHANT_NAME': 25,
    'BAKONG_ACCOUNT': 32,
    'AMOUNT': 13,
    'COUNTRY_CODE': 3,
    'MERCHANT_CATEGORY_CODE': 4,
    'MERCHANT_CITY': 15,
    'TIMESTAMP': 13,
    'TRANSACTION_AMOUNT': 14,
    'TRANSACTION_CURRENCY': 3,
    'BILL_NUMBER': 25,
    'STORE_LABEL': 25,
    'TERMINAL_LABEL': 25,
    'PURPOSE_OF_TRANSACTION': 25,
    'MERCHANT_ID': 32,
    'ACQUIRING_BANK': 32,
    'MOBILE_NUMBER': 25,
    'ACCOUNT_INFORMATION': 32,
    'MERCHANT_INFORMATION_LANGUAGE_TEMPLATE': 99,
    'UPI_MERCHANT': 99,
    'LANGUAGE_PREFERENCE': 2,
    'MERCHANT_NAME_ALTERNATE_LANGUAGE': 25,
    'MERCHANT_CITY_ALTERNATE_LANGUAGE': 15,
  };
}

/// Defines a collection of error codes and messages for KHQR generation and validation.
class ErrorCode {
  /// Error for when Bakong Account ID is required but not provided.
  static const BAKONG_ACCOUNT_ID_REQUIRED = {
    'code': 1,
    'message': 'Bakong Account ID cannot be null or empty',
  };

  /// Error for when Merchant Name is required but not provided.
  static const MERCHANT_NAME_REQUIRED = {
    'code': 2,
    'message': 'Merchant name cannot be null or empty',
  };

  /// Error for when Bakong Account ID is invalid.
  static const BAKONG_ACCOUNT_ID_INVALID = {
    'code': 3,
    'message': 'Bakong Account ID is invalid',
  };

  /// Error for when Transaction Amount is invalid.
  static const TRANSACTION_AMOUNT_INVALID = {
    'code': 4,
    'message': 'Amount is invalid',
  };

  /// Error for when Merchant Type is required but not provided.
  static const MERCHANT_TYPE_REQUIRED = {
    'code': 5,
    'message': 'Merchant type cannot be null or empty',
  };

  /// Error for when Bakong Account ID length is invalid.
  static const BAKONG_ACCOUNT_ID_LENGTH_INVALID = {
    'code': 6,
    'message': 'Bakong Account ID Length is Invalid',
  };

  /// Error for when Merchant Name length is invalid.
  static const MERCHANT_NAME_LENGTH_INVALID = {
    'code': 7,
    'message': 'Merchant Name Length is invalid',
  };

  /// Error for when the provided KHQR string is invalid.
  static const KHQR_INVALID = {
    'code': 8,
    'message': 'KHQR provided is invalid',
  };

  /// Error for when Currency Type is required but not provided.
  static const CURRENCY_TYPE_REQUIRED = {
    'code': 9,
    'message': 'Currency type cannot be null or empty',
  };

  /// Error for when Merchant City is required but not provided.
  static const MERCHANT_CITY_TAG_REQUIRED = {
    'code': 27,
    'message': 'Merchant City cannot be null or empty',
  };

  /// Error for when Merchant City length is invalid.
  static const MERCHANT_CITY_LENGTH_INVALID = {
    'code': 20,
    'message': 'Merchant city Length is invalid',
  };

  /// Error for when Merchant Category Tag is required but not provided.
  static const MERCHANT_CATEGORY_TAG_REQUIRED = {
    'code': 25,
    'message': 'Merchant category tag required',
  };

  /// Error for when Merchant Code length is invalid.
  static const MERCHANT_CODE_LENGTH_INVALID = {
    'code': 18,
    'message': 'Merchant code Length is invalid',
  };

  /// Error for when an invalid Merchant Category Code is provided.
  static const INVALID_MERCHANT_CATEGORY_CODE = {
    'code': 51,
    'message': 'Invalid merchant category code',
  };

  /// Error for when Merchant ID is required but not provided.
  static const MERCHANT_ID_REQUIRED = {
    'code': 30,
    'message': 'Merchant ID cannot be null or empty',
  };

  /// Error for when Acquiring Bank is required but not provided.
  static const ACQUIRING_BANK_REQUIRED = {
    'code': 31,
    'message': 'Acquiring Bank cannot be null or empty',
  };

  /// Error for when Merchant ID length is invalid.
  static const MERCHANT_ID_LENGTH_INVALID = {
    'code': 32,
    'message': 'Merchant ID Length is invalid',
  };

  /// Error for when Acquiring Bank length is invalid.
  static const ACQUIRING_BANK_LENGTH_INVALID = {
    'code': 33,
    'message': 'Acquiring Bank Length is invalid',
  };

  /// Error for when Account Information length is invalid.
  static const ACCOUNT_INFORMATION_LENGTH_INVALID = {
    'code': 35,
    'message': 'Account Information Length is invalid',
  };

  /// Error for when Expiration Timestamp is required for dynamic KHQR but not provided.
  static const EXPIRATION_TIMESTAMP_REQUIRED = {
    'code': 45,
    'message': 'Expiration timestamp is required for dynamic KHQR',
  };

  /// Error for when Expiration Timestamp length is invalid.
  static const EXPIRATION_TIMESTAMP_LENGTH_INVALID = {
    'code': 49,
    'message': 'Expiration timestamp length is invalid',
  };

  /// Error for when a dynamic KHQR has an invalid transaction amount field.
  static const INVALID_DYNAMIC_KHQR = {
    'code': 47,
    'message': 'This dynamic KHQR has invalid field transaction amount',
  };

  /// Error for when Expiration Timestamp is in the past.
  static const EXPIRATION_TIMESTAMP_IN_THE_PAST = {
    'code': 50,
    'message': 'Expiration timestamp is in the past',
  };

  /// Error for when a dynamic KHQR has expired.
  static const KHQR_EXPIRED = {
    'code': 46,
    'message': 'This dynamic KHQR has expired',
  };

  /// Error for when an unsupported currency is used.
  static const UNSUPPORTED_CURRENCY = {
    'code': 28,
    'message': 'Unsupported currency',
  };
}

// ============================================================================
// Response Classes
// ============================================================================

/// Represents the status of a KHQR operation, including success or error details.
class Status {
  /// The status code. 0 for success, 1 for error.
  final int code;

  /// The error code, if an error occurred.
  final String? errorCode;

  /// A human-readable message describing the status or error.
  final String? message;

  /// Creates a [Status] object.
  Status({required this.code, required this.errorCode, required this.message});

  @override
  String toString() {
    return 'Status{code: $code, errorCode: $errorCode, message: $message}';
  }
}

/// Represents the response from a KHQR generation or decoding operation.
class KHQRResponse {
  /// The status of the operation.
  final Status status;

  /// The generated or decoded KHQR data, if the operation was successful.
  final KHQRData? data;

  /// Creates a [KHQRResponse] object.
  ///
  /// [data] is the KHQR data if successful.
  /// [errorCode] is a map containing error details if an error occurred.
  KHQRResponse(this.data, Map<String, dynamic>? errorCode)
    : status = Status(
        code: errorCode == null ? 0 : 1,
        errorCode: errorCode?['code']?.toString(),
        message: errorCode?['message'],
      );

  @override
  String toString() {
    return 'KHQRResponse{status: $status, data: $data}';
  }
}

/// Represents the data contained within a KHQR code.
class KHQRData {
  /// The raw QR string.
  final String qr;

  /// The MD5 hash of the QR string.
  final String md5;

  /// The decoded data from the QR string, if available.
  final Map<String, dynamic>? decodedData;

  /// Creates a [KHQRData] object.
  KHQRData(this.qr, this.md5, {this.decodedData});

  @override
  String toString() {
    return 'KHQRData{qr: $qr, md5: $md5, decodedData: $decodedData}';
  }
}

/// Represents the result of a KHQR verification operation.
class VerificationResult {
  /// True if the KHQR is valid, false otherwise.
  final bool isValid;

  /// Creates a [VerificationResult] object.
  VerificationResult(this.isValid);
}

// ============================================================================
// Base Tag Class
// ============================================================================

/// Represents an EMV Tag-Length-Value (TLV) structure.
class Tag {
  /// The tag identifier.
  final String tag;

  /// The value associated with the tag.
  final String value;

  /// The length of the value, formatted as a two-digit string.
  late final String length;

  /// Creates a [Tag] object with the given [tag] and [value].
  Tag(this.tag, this.value) {
    final n = value.length;
    length = n < 10 ? '0$n' : n.toString();
  }

  @override
  String toString() => '$tag$length$value';
}

// ============================================================================
// Individual Info and Merchant Info Classes
// ============================================================================

/// Represents the information required to generate a KHQR for an individual account.
class IndividualInfo {
  /// The Bakong account ID.
  final String bakongAccountID;

  /// Additional account information.
  final String? accountInformation;

  /// The acquiring bank.
  final String? acquiringBank;

  /// The currency of the transaction.
  final int? currency;

  /// The transaction amount.
  final dynamic amount;

  /// The name of the merchant.
  final String merchantName;

  /// The city of the merchant.
  final String merchantCity;

  /// The bill number.
  final String? billNumber;

  /// The store label.
  final String? storeLabel;

  /// The terminal label.
  final String? terminalLabel;

  /// The mobile number.
  final String? mobileNumber;

  /// The purpose of the transaction.
  final String? purposeOfTransaction;

  /// The language preference.
  final String? languagePreference;

  /// The merchant name in an alternate language.
  final String? merchantNameAlternateLanguage;

  /// The merchant city in an alternate language.
  final String? merchantCityAlternateLanguage;

  /// The UnionPay merchant account.
  final String? upiMerchantAccount;

  /// The expiration timestamp for dynamic QR codes.
  final int? expirationTimestamp;

  /// The merchant category code.
  final String? merchantCategoryCode;

  /// Creates an [IndividualInfo] object.
  IndividualInfo({
    required this.bakongAccountID,
    required this.merchantName,
    required this.merchantCity,
    this.accountInformation,
    this.acquiringBank,
    this.currency,
    this.amount,
    this.billNumber,
    this.storeLabel,
    this.terminalLabel,
    this.mobileNumber,
    this.purposeOfTransaction,
    this.languagePreference,
    this.merchantNameAlternateLanguage,
    this.merchantCityAlternateLanguage,
    this.upiMerchantAccount,
    this.expirationTimestamp,
    this.merchantCategoryCode,
  });
}

/// Represents the information required to generate a KHQR for a merchant account.
class MerchantInfo extends IndividualInfo {
  /// The merchant ID.
  final String merchantID;

  /// The acquiring bank.
  final String acquiringBank;

  /// Creates a [MerchantInfo] object.
  MerchantInfo({
    required String bakongAccountID,
    required String merchantName,
    required String merchantCity,
    required this.merchantID,
    required this.acquiringBank,
    String? accountInformation,
    int? currency,
    dynamic amount,
    String? billNumber,
    String? storeLabel,
    String? terminalLabel,
    String? mobileNumber,
    String? purposeOfTransaction,
    String? languagePreference,
    String? merchantNameAlternateLanguage,
    String? merchantCityAlternateLanguage,
    String? upiMerchantAccount,
    int? expirationTimestamp,
    String? merchantCategoryCode,
  }) : super(
         bakongAccountID: bakongAccountID,
         merchantName: merchantName,
         merchantCity: merchantCity,
         accountInformation: accountInformation,
         acquiringBank: acquiringBank,
         currency: currency,
         amount: amount,
         billNumber: billNumber,
         storeLabel: storeLabel,
         terminalLabel: terminalLabel,
         mobileNumber: mobileNumber,
         purposeOfTransaction: purposeOfTransaction,
         languagePreference: languagePreference,
         merchantNameAlternateLanguage: merchantNameAlternateLanguage,
         merchantCityAlternateLanguage: merchantCityAlternateLanguage,
         upiMerchantAccount: upiMerchantAccount,
         expirationTimestamp: expirationTimestamp,
         merchantCategoryCode: merchantCategoryCode,
       );
}

// ============================================================================
// CRC Calculation
// ============================================================================

/// Calculates the Cyclic Redundancy Check (CRC) for the given [data].
///
/// The CRC is used for error detection in the KHQR string.
String calculateCRC(String data) {
  int crc = 0xFFFF;
  for (int i = 0; i < data.length; i++) {
    crc ^= data.codeUnitAt(i) << 8;
    for (int j = 0; j < 8; j++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc <<= 1;
      }
      crc &= 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}

/// Calculates the MD5 hash of the given [data].
String calculateMD5(String data) {
  final bytes = utf8.encode(data);
  final hash = md5(bytes);
  return hash
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}

// ============================================================================
// Main KHQR Generator Class
// ============================================================================

/// A utility class for generating, verifying, and decoding KHQR codes.
class KHQRGenerator {
  /// Generates a KHQR code for an individual account.
  ///
  /// Takes an [IndividualInfo] object containing the necessary details
  /// and returns a [KHQRResponse] with the generated QR string and its MD5 hash,
  /// or an error if generation fails.
  static KHQRResponse generateIndividual(IndividualInfo info) {
    try {
      final qr = _generateQR(info, MerchantType.individual.name);
      final data = KHQRData(qr, calculateMD5(qr));
      return KHQRResponse(data, null);
    } catch (e) {
      if (e is KHQRResponse) return e;
      return KHQRResponse(null, {'code': -1, 'message': e.toString()});
    }
  }

  /// Generates a KHQR code for a merchant account.
  ///
  /// Takes a [MerchantInfo] object containing the necessary details
  /// and returns a [KHQRResponse] with the generated QR string and its MD5 hash,
  /// or an error if generation fails.
  static KHQRResponse generateMerchant(MerchantInfo info) {
    try {
      final qr = _generateQR(info, MerchantType.merchant.name);
      final data = KHQRData(qr, calculateMD5(qr));
      return KHQRResponse(data, null);
    } catch (e) {
      if (e is KHQRResponse) return e;
      return KHQRResponse(null, {'code': -1, 'message': e.toString()});
    }
  }

  /// Verifies the validity of a given KHQR string.
  ///
  /// Checks the CRC format and calculates the CRC to ensure the KHQR is valid.
  /// Returns a [VerificationResult] indicating whether the QR is valid.
  static VerificationResult verify(String qr) {
    try {
      // Check CRC format
      if (!RegExp(r'6304[A-Fa-f0-9]{4}$').hasMatch(qr)) {
        return VerificationResult(false);
      }

      // Verify CRC
      final providedCRC = qr.substring(qr.length - 4);
      final dataWithoutCRC = qr.substring(0, qr.length - 8);
      final calculatedCRC = calculateCRC(
        dataWithoutCRC + EMV.CRC + EMV.CRC_LENGTH,
      );

      if (calculatedCRC.toUpperCase() != providedCRC.toUpperCase()) {
        return VerificationResult(false);
      }

      // Check minimum length
      if (qr.length < (EMV.INVALID_LENGTH['KHQR'] ?? 12)) {
        return VerificationResult(false);
      }

      return VerificationResult(true);
    } catch (e) {
      return VerificationResult(false);
    }
  }

  /// Decode KHQR string
  static KHQRResponse decode(String qr) {
    try {
      if (!verify(qr).isValid) {
        return KHQRResponse(null, ErrorCode.KHQR_INVALID);
      }
      final decoded = _decodeQR(qr);
      final data = KHQRData(qr, calculateMD5(qr), decodedData: decoded);
      return KHQRResponse(data, null);
    } catch (e) {
      if (e is KHQRResponse) return e;
      return KHQRResponse(null, ErrorCode.KHQR_INVALID);
    }
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  static String _generateQR(IndividualInfo info, String merchantType) {
    // Validate inputs
    _validateBakongAccount(info.bakongAccountID);
    _validateMerchantName(info.merchantName);
    _validateMerchantCity(info.merchantCity);

    final currency = info.currency ?? KHQRCurrency.khr.code;
    if (info.amount != null && info.amount != 0) {
      var amount = info.amount;
      if (currency == KHQRCurrency.khr.code) {
        if (amount is num && amount % 1 != 0) {
          throw KHQRResponse(null, ErrorCode.TRANSACTION_AMOUNT_INVALID);
        }
        amount = amount.round();
      } else {
        amount = double.parse(amount.toString()).toStringAsFixed(2);
      }
    }

    final components = <Tag>[];

    // Payload Format Indicator
    components.add(
      Tag(EMV.PAYLOAD_FORMAT_INDICATOR, EMV.DEFAULT_PAYLOAD_FORMAT_INDICATOR),
    );

    // Point of Initiation Method
    final isStatic = info.amount == null || info.amount == 0;
    final poiMethod = isStatic ? EMV.STATIC_QR : EMV.DYNAMIC_QR;
    components.add(Tag(EMV.POINT_OF_INITIATION_METHOD, poiMethod));

    // Merchant Account Information
    final accountTag = merchantType == MerchantType.merchant.name
        ? EMV
              .MERCHANT_ACCOUNT_INFORMATION_INDIVIDUAL // Note: Using tag 29 for both
        : EMV.MERCHANT_ACCOUNT_INFORMATION_INDIVIDUAL;

    String accountInfo = Tag(
      EMV.BAKONG_ACCOUNT_IDENTIFIER,
      info.bakongAccountID,
    ).toString();

    if (merchantType == MerchantType.merchant.name && info is MerchantInfo) {
      if (info.merchantID.isEmpty) {
        throw KHQRResponse(null, ErrorCode.MERCHANT_ID_REQUIRED);
      }
      accountInfo += Tag(
        EMV.MERCHANT_ACCOUNT_INFORMATION_MERCHANT_ID,
        info.merchantID,
      ).toString();
      accountInfo += Tag(
        EMV.MERCHANT_ACCOUNT_INFORMATION_ACQUIRING_BANK,
        info.acquiringBank,
      ).toString();
    } else if (info.accountInformation != null) {
      accountInfo += Tag(
        EMV.INDIVIDUAL_ACCOUNT_INFORMATION,
        info.accountInformation!,
      ).toString();
    }

    components.add(Tag(accountTag, accountInfo));

    // Merchant Category Code
    final mcc = info.merchantCategoryCode ?? EMV.DEFAULT_MERCHANT_CATEGORY_CODE;
    _validateMerchantCategoryCode(mcc);
    components.add(Tag(EMV.MERCHANT_CATEGORY_CODE, mcc));

    // Transaction Currency
    components.add(Tag(EMV.TRANSACTION_CURRENCY, currency.toString()));

    // Transaction Amount (if provided)
    if (info.amount != null && info.amount != 0) {
      var amount = info.amount;
      if (currency == KHQRCurrency.khr.code) {
        amount = amount.round();
      } else {
        amount = double.parse(amount.toString()).toStringAsFixed(2);
      }
      components.add(Tag(EMV.TRANSACTION_AMOUNT, amount.toString()));
    }

    // Country Code
    components.add(Tag(EMV.COUNTRY_CODE, EMV.DEFAULT_COUNTRY_CODE));

    // Merchant Name
    components.add(Tag(EMV.MERCHANT_NAME, info.merchantName));

    // Merchant City
    components.add(Tag(EMV.MERCHANT_CITY, info.merchantCity));

    // Additional Data
    if (info.billNumber != null ||
        info.mobileNumber != null ||
        info.storeLabel != null ||
        info.terminalLabel != null ||
        info.purposeOfTransaction != null) {
      String additionalData = '';
      if (info.billNumber != null) {
        additionalData += Tag(EMV.BILLNUMBER_TAG, info.billNumber!).toString();
      }
      if (info.mobileNumber != null) {
        additionalData += Tag(
          EMV.ADDITIONAL_DATA_FIELD_MOBILE_NUMBER,
          info.mobileNumber!,
        ).toString();
      }
      if (info.storeLabel != null) {
        additionalData += Tag(EMV.STORELABEL_TAG, info.storeLabel!).toString();
      }
      if (info.terminalLabel != null) {
        additionalData += Tag(EMV.TERMINAL_TAG, info.terminalLabel!).toString();
      }
      if (info.purposeOfTransaction != null) {
        additionalData += Tag(
          EMV.PURPOSE_OF_TRANSACTION,
          info.purposeOfTransaction!,
        ).toString();
      }
      components.add(Tag(EMV.ADDITIONAL_DATA_TAG, additionalData));
    }

    // Timestamp for dynamic QR
    if (!isStatic) {
      if (info.expirationTimestamp == null) {
        throw KHQRResponse(null, ErrorCode.EXPIRATION_TIMESTAMP_REQUIRED);
      }
      String timestampData = '';
      timestampData += Tag(
        EMV.CREATION_TIMESTAMP,
        DateTime.now().millisecondsSinceEpoch.toString(),
      ).toString();
      timestampData += Tag(
        EMV.EXPIRATION_TIMESTAMP,
        info.expirationTimestamp.toString(),
      ).toString();
      components.add(Tag(EMV.TIMESTAMP_TAG, timestampData));
    }

    // Build QR string
    String qrData = components.map((c) => c.toString()).join();
    String dataToCRC = qrData + EMV.CRC + EMV.CRC_LENGTH;
    qrData = dataToCRC + calculateCRC(dataToCRC);

    return qrData;
  }

  static Map<String, dynamic> _decodeQR(String qr) {
    final result = <String, dynamic>{};
    String remaining = qr;

    while (remaining.isNotEmpty) {
      if (remaining.length < 4) break;

      final tag = remaining.substring(0, 2);
      final lengthStr = remaining.substring(2, 4);
      final length = int.tryParse(lengthStr);

      if (length == null || remaining.length < 4 + length) break;

      final value = remaining.substring(4, 4 + length);
      result[tag] = value;

      remaining = remaining.substring(4 + length);
    }

    return result;
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  static void _validateBakongAccount(String accountId) {
    if (accountId.isEmpty) {
      throw KHQRResponse(null, ErrorCode.BAKONG_ACCOUNT_ID_REQUIRED);
    }
    if (accountId.length > (EMV.INVALID_LENGTH['BAKONG_ACCOUNT'] ?? 32)) {
      throw KHQRResponse(null, ErrorCode.BAKONG_ACCOUNT_ID_LENGTH_INVALID);
    }
    if (!accountId.contains('@') || accountId.split('@').length != 2) {
      throw KHQRResponse(null, ErrorCode.BAKONG_ACCOUNT_ID_INVALID);
    }
  }

  static void _validateMerchantName(String name) {
    if (name.isEmpty) {
      throw KHQRResponse(null, ErrorCode.MERCHANT_NAME_REQUIRED);
    }
    if (name.length > (EMV.INVALID_LENGTH['MERCHANT_NAME'] ?? 25)) {
      throw KHQRResponse(null, ErrorCode.MERCHANT_NAME_LENGTH_INVALID);
    }
  }

  static void _validateMerchantCity(String city) {
    if (city.isEmpty) {
      throw KHQRResponse(null, ErrorCode.MERCHANT_CITY_TAG_REQUIRED);
    }
    if (city.length > (EMV.INVALID_LENGTH['MERCHANT_CITY'] ?? 15)) {
      throw KHQRResponse(null, ErrorCode.MERCHANT_CITY_LENGTH_INVALID);
    }
  }

  static void _validateMerchantCategoryCode(String code) {
    if (code.isEmpty) {
      throw KHQRResponse(null, ErrorCode.MERCHANT_CATEGORY_TAG_REQUIRED);
    }
    if (code.length > (EMV.INVALID_LENGTH['MERCHANT_CATEGORY_CODE'] ?? 4)) {
      throw KHQRResponse(null, ErrorCode.MERCHANT_CODE_LENGTH_INVALID);
    }
    if (!RegExp(r'^\d+$').hasMatch(code)) {
      throw KHQRResponse(null, ErrorCode.INVALID_MERCHANT_CATEGORY_CODE);
    }
    final codeInt = int.tryParse(code);
    if (codeInt == null || codeInt < 0 || codeInt > 9999) {
      throw KHQRResponse(null, ErrorCode.INVALID_MERCHANT_CATEGORY_CODE);
    }
  }
}
