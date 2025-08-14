import 'package:artsphere/controller/artist/orderDetailController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final int orderId;
  OrderDetailPage({required this.orderId});

  final ArtistOrderController controller = Get.find<ArtistOrderController>();
  final currencyFormat = NumberFormat.currency(symbol: '\₹', decimalDigits: 2);

  // Status options with display names and colors
  final Map<String, Map<String, dynamic>> statusOptions = {
    'processing': {'name': 'Processing', 'color': Colors.orange},
    'shipped': {'name': 'Shipped', 'color': Colors.blue},
    'completed': {'name': 'Completed', 'color': Colors.green},
    'cancelled': {'name': 'Cancelled', 'color': Colors.red},
  };

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')?.trim();
  }

  @override
  Widget build(BuildContext context) {
    _getToken().then((token) {
      if (token != null) {
        controller.fetchOrderDetail(token, orderId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => controller.orderDetail.value != null
              ? _buildStatusDropdown(context)
              : const SizedBox.shrink()),
        ],
      ),
      body: _buildOrderDetailBody(),
    );
  }

  Widget _buildOrderDetailBody() {
    return Obx(() {
      final order = controller.orderDetail.value;
      if (order == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusChip(order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Placed on ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt.toLocal())}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (order.isDeliveredByCustomer)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Delivery confirmed by customer',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Section
            _sectionTitle('Customer Information'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: order.customer.profile_picture != null &&
                              order.customer.profile_picture.isNotEmpty
                          ? NetworkImage(order.customer.profile_picture)
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Failed to load profile image: $exception');
                      },
                      child: order.customer.profile_picture == null ||
                              order.customer.profile_picture.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customer.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customer.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customer.phone_no,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Shipping Address Section
            _sectionTitle('Shipping Address'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: order.shippingAddress != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddressRow(
                            Icons.home,
                            order.shippingAddress!.houseAddress,
                          ),
                          _buildAddressRow(
                            Icons.location_city,
                            '${order.shippingAddress!.city}, ${order.shippingAddress!.district}',
                          ),
                          _buildAddressRow(
                            Icons.flag,
                            order.shippingAddress!.state,
                          ),
                          _buildAddressRow(
                            Icons.markunread_mailbox,
                            order.shippingAddress!.postalCode,
                          ),
                        ],
                      )
                    : const Text('No shipping address provided.'),
              ),
            ),

            const SizedBox(height: 16),

            // Order Actions Section (using available_actions from API)
            if (order.availableActions.isNotEmpty) ...[
              _sectionTitle('Order Actions'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: order.availableActions.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getActionButtonColor(action['status']),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _confirmStatusChange(action['status']),
                            child: Text(
                              action['label'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Order Items Section
            _sectionTitle('Order Items (${order.items.length})'),
            ...order.items.map(
              (item) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.artworkDetails.imageUrl != null &&
                            item.artworkDetails.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.artworkDetails.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                size: 20,
                              ),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 20,
                            ),
                          ),
                  ),
                  title: Text(
                    item.artworkDetails.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text(
                    currencyFormat.format(double.tryParse(item.price) ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Summary Section
            _sectionTitle('Payment Summary'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPaymentRow('Subtotal', order.subtotal),
                    _buildPaymentRow('Shipping Fee', order.shippingFee),
                    const Divider(height: 20),
                    _buildPaymentRow('Total', order.total, isTotal: true),
                    const SizedBox(height: 8),
                    Text(
                      'Paid with ${order.paymentMethod}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final currentStatus = controller.orderDetail.value!.status.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.edit, semanticLabel: 'Change status'),
        itemBuilder: (context) => statusOptions.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: entry.value['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(entry.value['name']),
                if (entry.key == currentStatus)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 18),
                  ),
              ],
            ),
          );
        }).toList(),
        onSelected: (newStatus) => _confirmStatusChange(newStatus),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            currencyFormat.format(double.tryParse(amount) ?? 0),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = statusOptions[status.toLowerCase()] ?? 
        {'name': status, 'color': Colors.grey};

    return Chip(
      label: Text(statusInfo['name'].toUpperCase()),
      backgroundColor: statusInfo['color'].withOpacity(0.2),
      labelStyle: TextStyle(
        color: statusInfo['color'],
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      shape: StadiumBorder(side: BorderSide(color: statusInfo['color'])),
    );
  }

  Color _getActionButtonColor(String status) {
    switch (status.toLowerCase()) {
      case 'shipped': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.blue;
    }
  }

  Future<void> _confirmStatusChange(String newStatus) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Change Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ${controller.orderDetail.value!.status.toUpperCase()}',
            ),
            Text('New: ${statusOptions[newStatus]?['name'].toUpperCase()}'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to update the status?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: statusOptions[newStatus]?['color'],
            ),
            onPressed: () => Get.back(result: true),
            child: Text('Change to ${statusOptions[newStatus]?['name']}'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final token = await _getToken();
      if (token != null) {
        await controller.updateOrderStatus(orderId, newStatus);
      }
    }
  }
}