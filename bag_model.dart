class Bag {
  final String id;
  final String title;
  final String? description;
  final double originalPrice;
  final double discountedPrice;
  final String storeName;
  final double storeRating;
  final String pickupTime;
  final String pickupDate;
  final String status; // 'active' | 'sold_out' | 'expired'
  final int quantityAvailable;

  Bag({
    required this.id,
    required this.title,
    this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.storeName,
    required this.storeRating,
    required this.pickupTime,
    required this.pickupDate,
    required this.status,
    required this.quantityAvailable,
  });

  bool get isSoldOut => status == 'sold_out' || quantityAvailable <= 0;

  factory Bag.fromJson(Map<String, dynamic> json) {
    final store = json['stores'] as Map<String, dynamic>?;
    return Bag(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      originalPrice: (json['original_price'] as num).toDouble(),
      discountedPrice: (json['discounted_price'] as num).toDouble(),
      storeName: store?['name'] ?? 'Store',
      storeRating: (store?['rating'] as num?)?.toDouble() ?? 5.0,
      pickupTime: '${json['pickup_start']} - ${json['pickup_end']}',
      pickupDate: json['pickup_date'] ?? 'today',
      status: json['status'] ?? 'active',
      quantityAvailable: json['quantity_available'] ?? 0,
    );
  }
}