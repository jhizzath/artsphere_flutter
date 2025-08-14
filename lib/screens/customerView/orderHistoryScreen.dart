import 'package:artsphere/controller/customer/orderController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artsphere/model/orderModel.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  final OrderController _orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_orderController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_orderController.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                TextButton(
                  onPressed: () => _orderController.fetchOrders(),
                  child: Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _orderController.fetchOrders(),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _orderController.orders.length,
            itemBuilder: (context, index) {
              final order = _orderController.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(Order order) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  dateFormat.format(order.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Spacer(),
            Chip(
              label: Text(
                order.status.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: _getStatusColor(order.status),
            ),
          ],
        ),
        subtitle: Text(
          'Total: ${currencyFormat.format(order.total)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...order.items.map((item) => _buildOrderItem(item)).toList(),
                SizedBox(height: 16),
                _buildOrderSummary(order),

                // Cancel Order button
                if (order.status.toLowerCase() == 'processing')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showCancelConfirmation(order.id),
                      child: Text('Cancel Order'),
                    ),
                  ),

                // Confirm Delivery button
                if (order.showConfirmDelivery)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _confirmDelivery(order.id),
                      child: Text('Confirm Delivery'),
                    ),
                  ),
                
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Image
          item.imageUrl.isNotEmpty
              ? Image.network(
                  'http://YOUR_BACKEND_IP:8000${item.imageUrl}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Color.fromARGB(255, 210, 227, 236),
                    child: Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Color.fromARGB(255, 210, 227, 236),
                  child: Icon(Icons.image),
                ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Qty: ${item.quantity}'),
                Text('Price: ₹${item.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryRow('Subtotal', order.subtotal),
        _buildSummaryRow('Shipping', order.shippingFee),
        Divider(),
        _buildSummaryRow('Total', order.total, isTotal: true),
        SizedBox(height: 16),
        if (order.shippingAddress != null) ...[
          Text(
            'Shipping Address:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(order.shippingAddress.toString()),
          SizedBox(height: 16),
        ],
        Text(
          'Payment Method: ${order.paymentMethod.toUpperCase()}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: isTotal
                ? TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showCancelConfirmation(int orderId) {
    Get.defaultDialog(
      title: 'Confirm Cancellation',
      middleText: 'Are you sure you want to cancel this order?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _orderController.cancelOrder(orderId.toString());
      },
    );
  }

  void _confirmDelivery(int orderId) {
    Get.defaultDialog(
      title: 'Confirm Delivery',
      middleText: 'Have you received this order?',
      textConfirm: 'Yes, I received it',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _orderController.confirmDelivery(orderId);
      },
    );
  }
}
