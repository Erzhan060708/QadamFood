class OrderModel {
  final String id;
  final String bagId;
  final String qrCode;
  final String status; // 'paid' | 'completed' | 'cancelled'
  final DateTime createdAt;

  // Данные пакета (из JOIN)
  final String bagTitle;
  final String storeName;
  final String pickupTime;
  final double discountedPrice;

  OrderModel({
    required this.id,
    required this.bagId,
    required this.qrCode,
    required this.status,
    required this.createdAt,
    required this.bagTitle,
    required this.storeName,
    required this.pickupTime,
    required this.discountedPrice,
  });

  bool get isActive => status == 'paid';
  bool get isCompleted => status == 'completed';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final bag = json['bags'] as Map<String, dynamic>?;
    final store = bag?['stores'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['id'],
      bagId: json['bag_id'],
      qrCode: json['qr_code'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      bagTitle: bag?['title'] ?? 'Surprise Bag',
      storeName: store?['name'] ?? 'Store',
      pickupTime: bag != null
          ? '${bag['pickup_start']} - ${bag['pickup_end']}'
          : '',
      discountedPrice:
          (bag?['discounted_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}