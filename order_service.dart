import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  /// Получить все заказы пользователя (сначала активные, потом история)
  Future<List<OrderModel>> getUserOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('orders')
        .select('''
          id, bag_id, qr_code, status, created_at,
          bags (
            title, pickup_start, pickup_end, discounted_price,
            stores ( name )
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  /// Пометить заказ как "забрали" (после сканирования QR продавцом)
  Future<void> completeOrder(String orderId) async {
    await _supabase
        .from('orders')
        .update({'status': 'completed'}).eq('id', orderId);
  }
}