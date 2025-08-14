import 'package:artsphere/controller/customer/cartController.dart';
import 'package:artsphere/controller/customer/custArtworkController.dart';
import 'package:artsphere/model/artworkModel.dart';
import 'package:artsphere/screens/customerView/CheckoutPage.dart';
import 'package:artsphere/screens/customerView/custArtworkDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController cartController = Get.put(CartController());
  final CustomerArtworkController artworkController = Get.put(
    CustomerArtworkController(),
  );

  @override
  void initState() {
    super.initState();
    cartController.fetchCartItems();
  }

  double getTotalAmount() {
    return cartController.cartItems.fold(0, (sum, item) {
      return sum + (item.price * item.quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (cartController.cartItems.isEmpty) {
                return Center(child: Text("Cart is empty"));
              }
              return ListView.builder(
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  final artwork = artworkController.artworkList[index];
                  return Dismissible(
                    key: Key(item.id.toString()), // Unique key for each item
                    direction:
                        DismissDirection.endToStart, // Only allow swipe left
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    confirmDismiss: (direction) async {
                      // Show confirmation dialog
                      return await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text("Remove Item"),
                              content: Text(
                                "Are you sure you want to remove this item from your cart?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) {
                      cartController.removeFromCart(item.artworkId);
                      Get.snackbar(
                        "Removed",
                        "${item.title} removed from cart",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Icon(Icons.image, size: 60),
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          "Price: \₹${item.price.toStringAsFixed(2)} x ${item.quantity}",
                        ),
                        trailing: Text(
                          "\₹${(item.price * item.quantity).toStringAsFixed(2)}",
                        ),

                        onTap: () {
                          final artworkModel = ArtworkModel(
                            id: artwork.id,
                            title: artwork.title,
                            description: artwork.description,
                            price: artwork.price,
                            count: artwork.count,
                            artist: artwork.artist,
                            category: artwork.category,
                            subcategories: artwork.subcategories,
                            images: artwork.images,
                            isApproved:
                                artwork.isApproved ??
                                false, // Add this with appropriate default
                            isFeatured:
                                artwork.isFeatured ??
                                false, // Add this with appropriate default
                            approvalStatus: artwork.approvalStatus ?? 'pending',
                          );
                          Get.to(
                            () => ArtworkDetailsPage(artwork: artworkModel),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (cartController.cartItems.isEmpty) return SizedBox();
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\₹${getTotalAmount().toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (cartController.cartItems.isEmpty) {
                          Get.snackbar("Error", "Your cart is empty");
                        } else {
                          Get.to(
                            () => CheckoutPage.fromCart(
                              cartItems: cartController.cartItems,
                            ),
                          );
                        }
                      },
                      child: Text("PROCEED TO CHECKOUT"),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
