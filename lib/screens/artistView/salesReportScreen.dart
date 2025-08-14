import 'package:artsphere/controller/artist/salesReprotController.dart';
import 'package:artsphere/model/salesReportModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatefulWidget {
  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final SalesReportController _controller = Get.put(SalesReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _controller.fetchSalesReport(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final report = _controller.salesReport.value;
        if (report == null) {
          return Center(child: Text('No sales data available'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(report),
              SizedBox(height: 20),
              Text('Top Selling Artworks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildArtworkSalesList(report.artworkPerformance),
              SizedBox(height: 20),
              Text('Daily Sales Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildSalesChart(report.dailySales),
              SizedBox(height: 20),
              Text('Top Customers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildTopCustomersList(report.topCustomers),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(SalesReport report) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(report.period, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(),
            ListTile(
              title: Text('Total Sales'),
              trailing: Text(currencyFormat.format(report.totalSales)),
            ),
            ListTile(
              title: Text('Total Orders'),
              trailing: Text(report.totalOrders.toString()),
            ),
            ListTile(
              title: Text('Items Sold'),
              trailing: Text(report.totalItems.toString()),
            ),
            ListTile(
              title: Text('Pending Orders'),
              trailing: Text(report.pendingOrders.toString()),
            ),
            ListTile(
              title: Text('Completed Orders'),
              trailing: Text(report.completedOrders.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkSalesList(List<ArtworkPerformance> sales) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final item = sales[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text('Quantity: ${item.totalQuantity}'),
          trailing: Text('₹${item.totalSales.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Widget _buildSalesChart(List<DailySales> dailySales) {
    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: dailySales.map((data) {
            return BarChartGroupData(
              x: dailySales.indexOf(data),
              barRods: [
                BarChartRodData(
                  toY: data.total,
                  color: Colors.blue,
                  width: 16,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(dailySales[value.toInt()].date.substring(5));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTopCustomersList(List<TopCustomer> customers) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: customers.length,
    itemBuilder: (context, index) {
      final customer = customers[index];
      final profilePicUrl = customer.profilePictureUrl != null
          ? customer.profilePictureUrl!.replaceFirst(
              'http://192.168.145.221:8000/api/artist/sales-report',
              'http://192.168.145.221:8000'
            )
          : null;

      return ListTile(
        leading: _buildCustomerAvatar(profilePicUrl, customer.username),
        title: Text(customer.username),
        subtitle: Text('Orders: ${customer.orderCount}'),
        trailing: Text('₹${customer.totalSpent.toStringAsFixed(2)}'),
      );
    },
  );
}

Widget _buildCustomerAvatar(String? profilePicUrl, String username) {
  if (profilePicUrl == null || profilePicUrl.isEmpty) {
    return CircleAvatar(
      child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
    );
  }

  return CachedNetworkImage(
    imageUrl: profilePicUrl,
    imageBuilder: (context, imageProvider) => CircleAvatar(
      backgroundImage: imageProvider,
    ),
    placeholder: (context, url) => CircleAvatar(
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context, url, error) => CircleAvatar(
      child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
    ),
  );
}
}