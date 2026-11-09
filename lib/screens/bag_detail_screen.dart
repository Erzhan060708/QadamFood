import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bag_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'order_qr_screen.dart';
import 'auth_screen.dart';

class BagDetailScreen extends StatefulWidget {
  final Bag bag;
  const BagDetailScreen({super.key, required this.bag});

  @override
  State<BagDetailScreen> createState() => _BagDetailScreenState();
}

class _BagDetailScreenState extends State<BagDetailScreen> {
  bool isBuying = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.getIds().then((ids) {
      if (mounted) setState(() => isFavorite = ids.contains(widget.bag.id));
    });
  }

  Future<void> _buyBag() async {
    setState(() => isBuying = true);
    try {
      final res = await ApiService.createOrder(int.parse(widget.bag.id));
      if (!mounted) return;
      final orderModel = OrderModel(
        id: res['order_id'].toString(),
        bagId: widget.bag.id,
        qrCode: res['qr_code'],
        status: 'paid',
        createdAt: DateTime.now(),
        bagTitle: widget.bag.title,
        storeName: widget.bag.storeName,
        pickupTime: widget.bag.pickupTime,
        discountedPrice: widget.bag.discountedPrice,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderQrScreen(order: orderModel)),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('кіріңіз') || msg.contains('401') || msg.contains('Қате токен')) {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Қате: $e')));
      }
    } finally {
      if (mounted) setState(() => isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bag = widget.bag;
    final currency = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    final image = bag.imageUrl ?? bag.storeImageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: const Color(0xFF0A5443),
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      onPressed: () async {
                        final next = await FavoritesService.toggle(bag.id);
                        setState(() => isFavorite = next);
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(bag.storeName, style: const TextStyle(fontSize: 16)),
                    background: image != null
                        ? Image.network(image, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0A5443)))
                        : Container(color: const Color(0xFF0A5443)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8A00).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '−${bag.discountPercent.toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFFFF8A00),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(bag.storeCategory, style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(bag.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0A2E26))),
                        const SizedBox(height: 8),
                        Text(
                          bag.description ?? 'Сюрприз-пакет: кафенің күн соңындағы тағамдары 50–70% арзан.',
                          style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(currency.format(bag.originalPrice),
                                style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 16)),
                            const SizedBox(width: 10),
                            Text(currency.format(bag.discountedPrice),
                                style: const TextStyle(color: Color(0xFF0A5443), fontWeight: FontWeight.bold, fontSize: 28)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _infoTile(Icons.access_time, 'Алып кету', bag.pickupTime),
                        _infoTile(Icons.place_outlined, 'Мекенжай', bag.storeAddress.isEmpty ? 'Алматы' : bag.storeAddress),
                        _infoTile(Icons.inventory_2_outlined, 'Қалды', '${bag.quantityAvailable} пакет'),
                        _infoTile(Icons.star, 'Рейтинг', '${bag.storeRating}'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCEFCB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Сатып алғаннан кейін QR-код шығады. Оны кафе қызметкеріне көрсетіңіз.',
                            style: TextStyle(height: 1.4, color: Color(0xFF0A2E26)),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isBuying || bag.isSoldOut ? null : _buyBag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A5443),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isBuying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          bag.isSoldOut ? 'Таусылған' : 'Сатып алу · ${currency.format(bag.discountedPrice)}',
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0A5443), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
