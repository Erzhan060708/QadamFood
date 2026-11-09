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
  final String status;
  final int quantityAvailable;
  final String? imageUrl;
  final String storeAddress;
  final String storeCategory;
  final String? storeImageUrl;
  final int? storeId;

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
    this.imageUrl,
    this.storeAddress = '',
    this.storeCategory = 'Кафе',
    this.storeImageUrl,
    this.storeId,
  });

  bool get isSoldOut => status == 'sold_out' || quantityAvailable <= 0;

  double get discountPercent => originalPrice <= 0
      ? 0
      : ((originalPrice - discountedPrice) / originalPrice * 100);

  factory Bag.fromJson(Map<String, dynamic> json) {
    final store = json['stores'] as Map<String, dynamic>?;
    return Bag(
      id: json['id'].toString(),
      title: json['title'] ?? 'Surprise Bag',
      description: json['description'] as String?,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble() ?? 0,
      storeName: store?['name'] ?? 'Store',
      storeRating: (store?['rating'] as num?)?.toDouble() ?? 5.0,
      pickupTime: '${json['pickup_start'] ?? ''} - ${json['pickup_end'] ?? ''}',
      pickupDate: json['pickup_date'] ?? 'today',
      status: json['status'] ?? 'active',
      quantityAvailable: json['quantity_available'] ?? 0,
      imageUrl: json['image_url'] as String?,
      storeAddress: store?['address'] ?? '',
      storeCategory: store?['category'] ?? 'Кафе',
      storeImageUrl: store?['image_url'] as String?,
      storeId: store?['id'] as int? ?? json['store_id'] as int?,
    );
  }
}
