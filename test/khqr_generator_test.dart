import 'package:khqr_generator/khqr_generator.dart';
import 'package:test/test.dart';

void main() {
  group('KHQR Generator', () {
    // ===========================================================================
    // Test Cases for CRC and MD5 Calculation
    // ===========================================================================
    group('CRC and MD5', () {
      test('should calculate CRC correctly', () {
        const data = '123456789';
        final crc = calculateCRC(data);
        expect(crc, '29B1');
      });

      test('should calculate MD5 correctly', () {
        const data = 'test';
        final md5 = calculateMD5(data);
        expect(md5, '098F6BCD4621D373CADE4E832627B4F6');
      });
    });

    // ===========================================================================
    // Test Cases for Individual QR Generation
    // ===========================================================================
    group('generateIndividual', () {
      test('should generate a valid individual QR code', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);

        expect(response.status.code, 0);
        expect(response.data, isNotNull);
        expect(response.data!.qr, isNotEmpty);
        expect(KHQRGenerator.verify(response.data!.qr).isValid, isTrue);
      });

      test('should generate a valid individual QR code with amount', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
          amount: 100.0,
          currency: KHQRCurrency.usd.code,
          expirationTimestamp: DateTime.now().millisecondsSinceEpoch + 100000,
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);

        expect(response.status.code, 0);
        expect(response.data, isNotNull);
        expect(response.data!.qr, isNotEmpty);
        expect(KHQRGenerator.verify(response.data!.qr).isValid, isTrue);
      });

      test('should generate a valid individual QR code with all fields', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
          amount: 100.0,
          currency: KHQRCurrency.usd.code,
          billNumber: '12345',
          mobileNumber: '012345678',
          storeLabel: 'My Store',
          terminalLabel: 'T1',
          purposeOfTransaction: 'Payment',
          expirationTimestamp: DateTime.now().millisecondsSinceEpoch + 100000,
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);

        expect(response.status.code, 0);
        expect(response.data, isNotNull);
        expect(response.data!.qr, isNotEmpty);
        expect(KHQRGenerator.verify(response.data!.qr).isValid, isTrue);
      });

      test('should return an error for missing Bakong account ID', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: '',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);

        expect(response.status.code, 1);
        expect(
          response.status.errorCode,
          ErrorCode.BAKONG_ACCOUNT_ID_REQUIRED['code'].toString(),
        );
      });

      test('should return an error for invalid amount for KHR currency', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
          amount: 100.5,
          currency: KHQRCurrency.khr.code,
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);

        expect(response.status.code, 1);
        expect(
          response.status.errorCode,
          ErrorCode.TRANSACTION_AMOUNT_INVALID['code'].toString(),
        );
      });
    });

    // ===========================================================================
    // Test Cases for Merchant QR Generation
    // ===========================================================================
    group('generateMerchant', () {
      test('should generate a valid merchant QR code', () {
        final merchantInfo = MerchantInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
          merchantID: '1234567890',
          acquiringBank: 'Test Bank',
        );

        final response = KHQRGenerator.generateMerchant(merchantInfo);

        expect(response.status.code, 0);
        expect(response.data, isNotNull);
        expect(response.data!.qr, isNotEmpty);
        expect(KHQRGenerator.verify(response.data!.qr).isValid, isTrue);
      });

      test('should return an error for missing merchant ID', () {
        final merchantInfo = MerchantInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
          merchantID: '',
          acquiringBank: 'Test Bank',
        );

        final response = KHQRGenerator.generateMerchant(merchantInfo);
        expect(response.status.code, 1);
        expect(
          response.status.errorCode,
          ErrorCode.MERCHANT_ID_REQUIRED['code'].toString(),
        );
      });
    });

    // ===========================================================================
    // Test Cases for QR Code Verification
    // ===========================================================================
    group('verify', () {
      test('should return true for a valid QR code', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);
        final result = KHQRGenerator.verify(response.data!.qr);
        expect(result.isValid, isTrue);
      });

      test('should return false for an invalid QR code (bad CRC)', () {
        const invalidQR =
            '00020101021129320016A0000006770101110113012345678901252045999530384054041.005802KH5913Test Merchant6010Phnom Penh6304FFFF';
        final result = KHQRGenerator.verify(invalidQR);
        expect(result.isValid, isFalse);
      });

      test('should return false for a QR code with invalid format', () {
        const invalidQR = 'this is not a valid qr code';
        final result = KHQRGenerator.verify(invalidQR);
        expect(result.isValid, isFalse);
      });

      test('should return false for a QR code with invalid length', () {
        const invalidQR = '0002016304E69C';
        final result = KHQRGenerator.verify(invalidQR);
        expect(result.isValid, isFalse);
      });
    });

    // ===========================================================================
    // Test Cases for QR Code Decoding
    // ===========================================================================
    group('decode', () {
      test('should decode a valid QR code', () {
        final individualInfo = IndividualInfo(
          bakongAccountID: 'test@test',
          merchantName: 'Test Merchant',
          merchantCity: 'Phnom Penh',
          amount: 100.0,
          currency: KHQRCurrency.usd.code,
          billNumber: '12345',
          mobileNumber: '012345678',
          storeLabel: 'My Store',
          terminalLabel: 'T1',
          purposeOfTransaction: 'Payment',
          expirationTimestamp: DateTime.now().millisecondsSinceEpoch + 100000,
        );

        final response = KHQRGenerator.generateIndividual(individualInfo);
        final decodedResponse = KHQRGenerator.decode(response.data!.qr);

        expect(decodedResponse.status.code, 0);
        final decodedData = decodedResponse.data!.decodedData;
        expect(decodedData, isNotNull);
        expect(
          decodedData![EMV.PAYLOAD_FORMAT_INDICATOR],
          EMV.DEFAULT_PAYLOAD_FORMAT_INDICATOR,
        );
        expect(decodedData[EMV.POINT_OF_INITIATION_METHOD], EMV.DYNAMIC_QR);
        expect(
          decodedData[EMV.MERCHANT_CATEGORY_CODE],
          EMV.DEFAULT_MERCHANT_CATEGORY_CODE,
        );
        expect(
          decodedData[EMV.TRANSACTION_CURRENCY],
          KHQRCurrency.usd.code.toString(),
        );
        expect(decodedData[EMV.TRANSACTION_AMOUNT], '100.00');
        expect(decodedData[EMV.COUNTRY_CODE], EMV.DEFAULT_COUNTRY_CODE);
        expect(decodedData[EMV.MERCHANT_NAME], 'Test Merchant');
        expect(decodedData[EMV.MERCHANT_CITY], 'Phnom Penh');
      });

      test('should return an error for an invalid QR code', () {
        const invalidQR = 'this is not a valid qr code';
        final response = KHQRGenerator.decode(invalidQR);

        expect(response.status.code, 1);
        expect(
          response.status.errorCode,
          ErrorCode.KHQR_INVALID['code'].toString(),
        );
      });
    });
  });
}
