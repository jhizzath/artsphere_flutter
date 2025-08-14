class SalesReport {
  final String period;
  final double totalSales;
  final int totalOrders;
  final int totalItems;
  final int pendingOrders;
  final int completedOrders;
  final List<ArtworkPerformance> artworkPerformance;
  final List<DailySales> dailySales;
  final List<TopCustomer> topCustomers;

  SalesReport({
    required this.period,
    required this.totalSales,
    required this.totalOrders,
    required this.totalItems,
    required this.pendingOrders,
    required this.completedOrders,
    required this.artworkPerformance,
    required this.dailySales,
    required this.topCustomers,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      period: json['period'],
      totalSales: json['total_sales']?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] ?? 0,
      totalItems: json['total_items'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      artworkPerformance: List<ArtworkPerformance>.from(
          json['artwork_performance'].map((x) => ArtworkPerformance.fromJson(x))),
      dailySales: List<DailySales>.from(
          json['daily_sales'].map((x) => DailySales.fromJson(x))),
      topCustomers: List<TopCustomer>.from(
          json['top_customers'].map((x) => TopCustomer.fromJson(x))),
    );
  }
}

class ArtworkPerformance {
  final int artworkId;
  final String title;
  final double totalSales;
  final int totalQuantity;

  ArtworkPerformance({
    required this.artworkId,
    required this.title,
    required this.totalSales,
    required this.totalQuantity,
  });

  factory ArtworkPerformance.fromJson(Map<String, dynamic> json) {
    return ArtworkPerformance(
      artworkId: json['artwork__id'],
      title: json['artwork__title'],
      totalSales: json['total_sales']?.toDouble() ?? 0.0,
      totalQuantity: json['total_quantity'] ?? 0,
    );
  }
}

class DailySales {
  final String date;
  final double total;
  final int count;

  DailySales({
    required this.date,
    required this.total,
    required this.count,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'],
      total: json['total']?.toDouble() ?? 0.0,
      count: json['count'] ?? 0,
    );
  }
}

class TopCustomer {
  final String username;
  final String? profilePictureUrl;  // Add this field
  final double totalSpent;
  final int orderCount;

  TopCustomer({
    required this.username,
    this.profilePictureUrl,  // Add this
    required this.totalSpent,
    required this.orderCount,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      username: json['order__customer__username'] ?? json['username'] ?? 'Unknown',
      profilePictureUrl: json['order__customer__profile_picture'] ?? json['profile_picture'],
      totalSpent: json['total_spent']?.toDouble() ?? 0.0,
      orderCount: json['order_count'] ?? 0,
    );
  }
}