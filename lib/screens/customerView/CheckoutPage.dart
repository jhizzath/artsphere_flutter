
import 'package:artsphere/controller/customer/CustomerProfileController.dart';
import 'package:artsphere/controller/customer/orderController.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:artsphere/model/custPorfileModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artsphere/controller/customer/cartController.dart';
import 'package:artsphere/model/cartModel.dart';

class CheckoutPage extends StatefulWidget {
  // For cart checkout
  final List<CartItem>? cartItems;
  // For single-item checkout
  final ArtworkModel? artwork;
  final int? quantity;

  // Named constructor for cart checkout
  const CheckoutPage.fromCart({
    Key? key,
    required this.cartItems,
  })  : artwork = null,
        quantity = null,
        super(key: key);

  // Named constructor for single-item checkout
  const CheckoutPage.fromSingleItem({
    Key? key,
    required this.artwork,
    required this.quantity,
  })  : cartItems = null,
        super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController _cartController = Get.find();
  final CustomerProfileController _profileController = Get.find();
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = [
    'Cash on delivery',
    'PayPal',
    'Bank Transfer',
    'UPI'
  ];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = _paymentMethods.first;
    _profileController.fetchProfile();
  }

  double get subtotal {
  if (widget.cartItems != null) {
    return widget.cartItems!.fold(
        0, (sum, item) => sum + (item.price * item.quantity));
  } else if (widget.artwork != null) {
    return widget.artwork!.price * (widget.quantity ?? 1);
  }
  return 0;
}

double get shippingFee => _calculateShippingFee();
double get total => subtotal + shippingFee;

  double _calculateShippingFee() {
    if (subtotal > 5000) return 0;
    return 50.0;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Checkout'),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Section
          _buildSectionHeader('Order Summary'),
          if (widget.cartItems != null && widget.cartItems!.isNotEmpty)
            Column(
              children: widget.cartItems!
                  .map((item) => _buildCartItemCard(item))
                  .toList(),
            )
          else if (widget.artwork != null)
            _buildSingleItemCard(widget.artwork!, widget.quantity ?? 1)
          else
            const Center(child: Text('No items to checkout')),
          
          const SizedBox(height: 20),

          // Delivery Address Section
          _buildSectionHeader('Delivery Address'),
          _buildAddressSection(),
          const SizedBox(height: 20),

          // Payment Method Section
          _buildSectionHeader('Payment Method'),
          _buildPaymentMethodDropdown(),
          const SizedBox(height: 20),

          // Price Breakdown
          _buildSectionHeader('Price Breakdown'),
          _buildPriceBreakdown(),
          const SizedBox(height: 20),

          // Place Order Button
          _buildPlaceOrderButton(),
        ],
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Add this new method to display single item
Widget _buildSingleItemCard(ArtworkModel artwork, int quantity) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Item Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: artwork.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _buildImageUrl(artwork.images.first.image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : const Icon(Icons.image, size: 40),
          ),
          const SizedBox(width: 16),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Qty: $quantity'),
                const SizedBox(height: 8),
                Text(
                  '₹${artwork.price} each',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Item Total
          Text(
            '₹${(artwork.price * quantity)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

// Add this helper method (similar to what you have in ArtworkDetailsPage)
String _buildImageUrl(String path) {
  // Implement your image URL building logic here
  if (path.isEmpty) return 'https://via.placeholder.com/150';
  if (path.startsWith('http')) return path;
  return 'http://192.168.145.221:8000${path.startsWith('/') ? path : '/$path'}';
}

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: item.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                    )
                  : const Icon(Icons.image, size: 40),
            ),
            const SizedBox(width: 16),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Qty: ${item.quantity}'),
                  const SizedBox(height: 8),
                  Text(
                    '₹${item.price.toStringAsFixed(2)} each',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Item Total
            Text(
              '₹${(item.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Obx(() {
      if (_profileController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final profile = _profileController.profile.value;
      if (profile == null || profile.addresses.isEmpty) {
        return _buildNoAddressCard();
      }
      
      final address = profile.addresses.first;
      return _buildAddressCard(address, profile);
    });
  }

  Widget _buildNoAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.location_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text("No delivery address saved"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to add address screen
              },
              child: const Text("Add Address"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address, CustomerProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Delivery Address",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(profile.username,
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            Text(address.houseAddress),
            Text('${address.city}, ${address.district}'),
            Text('${address.state} - ${address.postalCode}'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(profile.phoneNo ?? 'Phone not provided'),
              ],
            ),
            if (address.isDefault) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEFAULT ADDRESS',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Show address selection
                },
                child: const Text('Change Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButton<String>(
          value: _selectedPaymentMethod,
          isExpanded: true,
          underline: const SizedBox(),
          items: _paymentMethods.map((String method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPaymentMethod = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriceRow('Subtotal', subtotal),
            _buildPriceRow('Shipping', shippingFee),
            const Divider(height: 20),
            _buildPriceRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : null,
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : null,
              fontWeight: isTotal ? FontWeight.bold : null,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        if ((widget.cartItems == null || widget.cartItems!.isEmpty) && 
            widget.artwork == null) {
          Get.snackbar('Error', 'No items to order');
          return;
        }

        final profile = _profileController.profile.value;
        if (profile == null || profile.addresses.isEmpty) {
          Get.snackbar('Error', 'Please add a delivery address');
          return;
        }

        try {
          final orderController = Get.find<OrderController>();
          
          if (widget.cartItems != null) {
            // Cart checkout - set fromCart to true
            await orderController.createOrder(
              items: widget.cartItems!.map((item) => {
                'artwork_id': item.artworkId,
                'quantity': item.quantity,
              }).toList(),
              shippingAddressId: profile.addresses.first.id!,
              paymentMethod: _selectedPaymentMethod ?? 'Cash on delivery',
              fromCart: true,  // This tells backend to clear cart
            );
            _cartController.clearCart();  // Clear local cart immediately
          } else {
            // Single item checkout
            await orderController.createOrder(
              items: [{
                'artwork_id': widget.artwork!.id,
                'quantity': widget.quantity ?? 1,
              }],
              shippingAddressId: profile.addresses.first.id!,
              paymentMethod: _selectedPaymentMethod ?? 'Cash on delivery',
              // fromCart defaults to false
            );
          }

          Get.offAllNamed('/order-confirmation');
        } catch (e) {
          Get.snackbar('Error', 'Failed to place order: ${e.toString()}');
        }
      },
      child: const Text('PLACE ORDER'),
    ),
  );
}

}