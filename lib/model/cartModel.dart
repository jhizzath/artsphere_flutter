class CartItem {
  final int? id;
  final int artworkId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
     this.id,
    required this.artworkId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      artworkId: json['artwork'],
      title: json['artwork_title'],
      price: double.parse(json['artwork_price'].toString()),
      imageUrl: json['artwork_image'] ?? '',
      quantity: json['quantity'],
    );
  }
}