import 'package:flutter/material.dart';

class Order {
  final int id;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double total;
  final DateTime createdAt;
  final String paymentMethod;
  final List<OrderItem> items;
  final ShippingAddress? shippingAddress;
  final bool isDeliveredByCustomer;
  final bool canConfirmDelivery;

  Order({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.createdAt,
    required this.paymentMethod,
    required this.items,
    this.shippingAddress,
    required this.isDeliveredByCustomer,
    required this.canConfirmDelivery,
  });

  factory Order.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    
    final items = <OrderItem>[];
    if (json['items'] is List) {
      for (var item in json['items']) {
        try {
          if (item != null) {
            items.add(OrderItem.fromJson(item));
          }
        } catch (e) {
          debugPrint('Failed to parse order item: $e');
        }
      }
    }

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.tryParse(json['created_at']?.toString() ?? '');
    } catch (e) {
      debugPrint('Failed to parse date: $e');
    }

    return Order(
      id: asInt(json['id']),
      status: asString(json['status'], fallback: 'pending'),
      subtotal: asDouble(json['subtotal']),
      shippingFee: asDouble(json['shipping_fee']),
      total: asDouble(json['total']),
      createdAt: parsedDate ?? DateTime.now(),
      paymentMethod: asString(json['payment_method'], fallback: 'unknown'),
      items: items,
      shippingAddress: json['shipping_address'] is Map 
          ? ShippingAddress.fromJson(json['shipping_address']) 
          : null,
      isDeliveredByCustomer: json['is_delivered_by_customer'] ?? false,
      canConfirmDelivery: json['can_confirm_delivery'] ?? 
                        (json['status']?.toString().toLowerCase() == 'shipped'),
    );
  }

  bool get showConfirmDelivery {
    return status.toLowerCase() == 'shipped' && 
           !isDeliveredByCustomer;
  }
}

// Helper functions
int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String asString(dynamic value, {String fallback = ''}) {
  if (value is String) return value;
  return value?.toString() ?? fallback;
}

class ShippingAddress {
  final String houseAddress;
  final String city;
  final String district;
  final String state;
  final String postalCode;
  
  ShippingAddress({
    required this.houseAddress,
    required this.city,
    required this.district,
    required this.state,
    required this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return ShippingAddress(
      houseAddress: asString(json['house_address']),
      city: asString(json['city']),
      district: asString(json['district']),
      state: asString(json['state']),
      postalCode: asString(json['postal_code']),
    );
  }

  @override
  String toString() {
    return '$houseAddress, $city, $district, $state $postalCode';
  }
}

class OrderItem {
  final int id;
  final int artworkId;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.artworkId,
    required this.title,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    final artworkDetails = json['artwork_details'] is Map 
        ? json['artwork_details'] 
        : {};
    
    return OrderItem(
      id: asInt(json['id']),
      artworkId: asInt(json['artwork']),
      title: asString(artworkDetails['title'], fallback: 'Unknown Artwork'),
      imageUrl: asString(artworkDetails['image']),
      quantity: asInt(json['quantity']),
      price: asDouble(json['price']),
    );
  }
}