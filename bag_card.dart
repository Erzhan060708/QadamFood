import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bag_model.dart';

class BagCard extends StatelessWidget {
  final Bag bag;
  final VoidCallback onTap;
  final String? tag; // 'Popular' | 'Selling Fast' | 'New' | null

  const BagCard({super.key, required this.bag, required this.onTap, this.tag});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return GestureDetector(
      onTap: bag.isSoldOut ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Верх: логотип магазина ───
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Text(
                      bag.storeName.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                  ),
                ),

                // Sold Out overlay
                if (bag.isSoldOut)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Text('Sold Out',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                // Тег (Popular / Selling Fast / New)
                if (tag != null && !bag.isSoldOut)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEFCB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag!,
                        style: const TextStyle(
                            color: Color(0xFF005C4B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                // Сердечко избранного
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Избранное — скоро ✨')),
                      );
                    },
                  ),
                ),

                // Рейтинг
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('${bag.storeRating}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── Низ: инфо ───
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(bag.title,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(currency.format(bag.originalPrice),
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(currency.format(bag.discountedPrice),
                              style: const TextStyle(
                                  color: Color(0xFF005C4B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(bag.storeName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 15, color: Color(0xFF005C4B)),
                      const SizedBox(width: 4),
                      Text('Pick up ${bag.pickupDate} | ${bag.pickupTime}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}