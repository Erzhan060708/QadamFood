import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import 'order_qr_screen.dart';
import 'auth_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await ApiService.getOrders();
      if (!mounted) return;
      setState(() {
        _orders = response.map((j) {
          final bag = j['bags'] ?? {};
          final store = bag['stores'] ?? {};
          return OrderModel(
            id: j['id'].toString(),
            bagId: '', // Бұл өріс UI-да қолданылмайды
            qrCode: j['qr_code'] ?? '',
            status: j['status'] ?? 'paid',
            createdAt: DateTime.parse(j['created_at']),
            bagTitle: bag['title'] ?? 'Surprise Bag',
            storeName: store['name'] ?? 'Store',
            pickupTime: '${bag['pickup_start']} - ${bag['pickup_end']}',
            discountedPrice:
                (bag['discounted_price'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
        _isLoggedIn = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки заказов: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoggedIn = false; // Егер токен жоқ болса, кірмеген болып саналады
      });
    }
  }

  List<OrderModel> get _activeOrders =>
      _orders.where((o) => o.isActive).toList();

  List<OrderModel> get _historyOrders =>
      _orders.where((o) => o.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAF7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAF7),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: Color(0xFF0A5443)),
                const SizedBox(height: 16),
                const Text('Тапсырыстарды көру үшін кіріңіз',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Сатып алған пакеттеріңіз осында көрінеді',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                    _load();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A5443)),
                  child:
                      const Text('Кіру', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF7),
        elevation: 0,
        title: const Text('Тапсырыстар',
            style: TextStyle(
                color: Color(0xFF173B30), fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0A5443),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF7A00),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: [
            Tab(text: 'Белсенді (${_activeOrders.length})'),
            Tab(text: 'Аяқталған (${_historyOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_activeOrders, isActive: true),
          _buildList(_historyOrders, isActive: false),
        ],
      ),
    );
  }

  Widget _buildList(List<OrderModel> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.shopping_bag_outlined : Icons.history,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Белсенді тапсырыс жоқ' : 'Тапсырыс тарихы әзірге бос',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Ұсыныстардан алғашқы пакетіңізді таңдаңыз.'
                  : 'Аяқталған тапсырыстар осында көрінеді.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF0A5443),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) => _orderCard(list[i], isActive: isActive),
      ),
    );
  }

  Widget _orderCard(OrderModel order, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFEAF3ED)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Белсенді' : 'Аяқталған',
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF0A5443)
                          : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '₸${order.discountedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A5443)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(order.bagTitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(order.storeName,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 15, color: Color(0xFF0A5443)),
                const SizedBox(width: 4),
                Text('Алып кету: ${order.pickupTime}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final refreshed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderQrScreen(order: order),
                      ),
                    );
                    if (refreshed == true) _load();
                  },
                  icon: const Icon(Icons.qr_code_2,
                      color: Colors.white, size: 20),
                  label: const Text('QR кодын көрсету',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A5443),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
