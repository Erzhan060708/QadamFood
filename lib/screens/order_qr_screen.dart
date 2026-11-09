import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/order_model.dart';

class OrderQrScreen extends StatelessWidget {
  final OrderModel order;

  const OrderQrScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F8F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Show this at the store',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ─── Инфо о заказе ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.bagTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(order.storeName,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Color(0xFF005C4B)),
                        const SizedBox(width: 4),
                        Text('Pick up: ${order.pickupTime}',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── QR-код ───
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: order.qrCode,
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF005C4B),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF005C4B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Order code: ${order.qrCode}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Подсказка ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEFCB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF005C4B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Show this QR code to the store staff when you pick up your bag. They will scan it to confirm.',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}