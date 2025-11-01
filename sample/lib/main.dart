import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:khqr_generator/khqr_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHQR Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: const MyHomePage(title: 'KHQR Generator'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  /// Generate KHQR example
  Future<MapEntry<KHQRResponse, KHQRResponse>> generateKhqr() async {
    // Example 1: Generate Individual KHQR
    final individualInfo = IndividualInfo(
      bakongAccountID: 'username@bank',
      merchantName: 'Jonh Doe',
      merchantCity: 'Phnom Penh',
      amount: 1000,
      currency: KHQRCurrency.khr.code,
      expirationTimestamp: 36999,
    );

    final individualQrResponse = KHQRGenerator.generateIndividual(
      individualInfo,
    );
    log('Individual KHQR: ${individualQrResponse.toString()}');

    // Example 2: Generate Merchant KHQR
    final merchantInfo = MerchantInfo(
      bakongAccountID: 'merchant@bank',
      merchantName: 'Banana Shop',
      merchantCity: 'Phnom Penh',
      merchantID: 'MERCHANTID001',
      acquiringBank: 'BankABC',
      amount: 2.20,
      currency: KHQRCurrency.usd.code,
      expirationTimestamp: 3600,
    );

    final merchantQrResponse = KHQRGenerator.generateMerchant(merchantInfo);
    log('\nMerchant KHQR: ${merchantQrResponse.toString()}');

    // Example 3: Verify KHQR
    if (individualQrResponse.data != null) {
      final qrCode = individualQrResponse.data?.qr;
      final verification = KHQRGenerator.verify(qrCode ?? "");
      log('\nQR Verification: ${verification.isValid}');
    }

    log(KHQRGenerator.decode(individualQrResponse.data?.qr ?? "").toString());

    return MapEntry(individualQrResponse, merchantQrResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: FutureBuilder(
          future: generateKhqr(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                Text('Individual KHQR: ${snapshot.data?.key.toString()}'),
                Text('Merchant KHQR: ${snapshot.data?.value.toString()}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
