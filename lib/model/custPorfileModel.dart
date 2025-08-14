

class CustomerProfile {
  final String username;
  final String email;
  final String? phoneNo;
  final String? profilePicture;
  final List<Address> addresses;

  CustomerProfile({
    required this.username,
    required this.email,
    this.phoneNo,
    this.profilePicture,
    required this.addresses,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phone_no'],
      profilePicture: json['profile_picture'],
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((address) => Address.fromJson(address))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toUpdateJson() {
  return {
    'user': {
      'username': username,
      'email': email,
      'phone_no': phoneNo,
    },
    'address': {  // Changed from 'addresses' to 'address' to match your view
      'house_address': addresses.isNotEmpty ? addresses[0].houseAddress : '',
      'city': addresses.isNotEmpty ? addresses[0].city : '',
      'district': addresses.isNotEmpty ? addresses[0].district : '',
      'state': addresses.isNotEmpty ? addresses[0].state : '',
      'postal_code': addresses.isNotEmpty ? addresses[0].postalCode : '',
    }
  };
}
}

class Address {
  final int? id;
  final String houseAddress;
  final String city;
  final String district;
  final String state;
  final String postalCode;
  final bool isDefault;
  

  Address({
    this.id,
    required this.houseAddress,
    required this.city,
    required this.district,
    required this.state,
    required this.postalCode,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      houseAddress: json['house_address'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'house_address': houseAddress,
      'city': city,
      'district': district,
      'state': state,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }
}