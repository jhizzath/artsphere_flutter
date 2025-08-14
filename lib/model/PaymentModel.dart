import 'package:flutter/material.dart';

class PaymentMethod {
  final int id;
  final String name;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
  });
}