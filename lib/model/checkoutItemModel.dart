// models/checkout_item.dart
import 'package:artsphere/model/artworkModel.dart';
import 'package:flutter/material.dart';

class CheckoutItem {
  final ArtworkModel artwork;
  int quantity;
  
  CheckoutItem({required this.artwork, this.quantity = 1});
}

// models/payment_method.dart
class PaymentMethod {
  final int id;
  final String name;
  final IconData icon;
  final String? cardNumber; // Last 4 digits for cards
  final String? expiryDate;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.cardNumber,
    this.expiryDate,
  });
}