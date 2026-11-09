import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String qrCode;
  const OrderSuccessScreen({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ оформлен')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF005C4B), size: 64),
            const SizedBox(height: 16),
            const Text('Покажите этот код в магазине', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            QrImageView(data: qrCode, size: 200),
            const SizedBox(height: 16),
            Text(qrCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}