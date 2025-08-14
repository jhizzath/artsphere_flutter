//Artist


class OrderModel {
  final int id;
  final CustomerModel customer;
  final ShippingAddress? shippingAddress; // Made nullable
  final String paymentMethod;
  final String subtotal;
  final String shippingFee;
  final String total;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;
  final bool isDeliveredByCustomer;
  final List<Map<String, dynamic>> availableActions;

  OrderModel({
    required this.id,
    required this.customer,
    this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.isDeliveredByCustomer,
    required this.availableActions,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customer: CustomerModel.fromJson(json['customer']),
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      paymentMethod: json['payment_method'],
      subtotal: json['subtotal'],
      shippingFee: json['shipping_fee'],
      total: json['total'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      isDeliveredByCustomer: json['is_delivered_by_customer'] ?? false,
      availableActions: (json['available_actions'] as List?)?.map((action) {
        return {
          'status': action[0],
          'label': action[1],
        };
      }).toList() ?? [],
    );
  }
}

class OrderItem {
  final int id;
  final ArtworkDetails artworkDetails;
  final int quantity;
  final String price;

  OrderItem({
    required this.id,
    required this.artworkDetails,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      artworkDetails: ArtworkDetails.fromJson(json['artwork_details']),
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class ArtworkDetails {
  final String title;
  final String imageUrl; // Made nullable

  ArtworkDetails({
    required this.title,
   required this.imageUrl,
  });

  factory ArtworkDetails.fromJson(Map<String, dynamic> json) {
    return ArtworkDetails(
      title: json['title'],
      imageUrl: json['image_url'],
    );
  }
}


class ShippingAddress {
  final int id;
  final String houseAddress;
  final String city;
  final String district;
  final String state;
  final String postalCode;

  ShippingAddress({
    required this.id,
    required this.houseAddress,
    required this.city,
    required this.district,
    required this.state,
    required this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      houseAddress: json['house_address'],
      city: json['city'],
      district: json['district'],
      state: json['state'],
      postalCode: json['postal_code'],
    );
  }
}

class CustomerModel {
  final int id;
  final String username;
  final String email;
  final String phone_no;
  final String profile_picture;

  CustomerModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone_no,
    required this.profile_picture,

  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone_no: json['phone_no'],
      profile_picture:json['profile_picture']
    );
  }
}