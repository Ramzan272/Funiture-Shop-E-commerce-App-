import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- ADD THIS IMPORT
import 'package:furniture_shop/ui/user_side/product/products_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../components/constants.dart';
import '../../models/cart_item.dart';
import '../../models/furniture.dart';
import '../services/notification_service.dart';
import 'orders_screen.dart';
import 'dart:math' as math;

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isProcessing = false;

  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'Cash on Delivery',
    'PayPal',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreviousOrderData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  Future<void> _loadPreviousOrderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('customerEmail', isEqualTo: user.email)
          .orderBy('orderDate', descending: true)
          .limit(1) // Get only the most recent one
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastOrderData = FurnitureOrder.fromMap(querySnapshot.docs.first.data(), querySnapshot.docs.first.id);

        setState(() {
          _nameController.text = lastOrderData.customerName ?? '';
          _emailController.text = lastOrderData.customerEmail ?? '';
          _phoneController.text = lastOrderData.customerPhone ?? '';
          _addressController.text = lastOrderData.shippingAddress ?? '';
          _selectedPaymentMethod = lastOrderData.paymentMethod;
        });
      } else {
        // If no previous orders, ensure email field is pre-filled if authenticated
        _emailController.text = user.email!;
      }
    } catch (e) {
      print("Error loading previous order data: $e");
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethod == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a payment method."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Create order
      final order = FurnitureOrder(
        id: '',
        items: widget.cartItems.map((item) => {
          'productId': item.productId,
          'title': item.title,
          'price': item.price,
          'quantity': item.quantity,
          'image': item.image,
        }).toList(),
        totalAmount: widget.totalAmount,
        status: 'pending',
        orderDate: DateTime.now(),
        customerEmail: _emailController.text,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        shippingAddress: _addressController.text,
        paymentMethod: _selectedPaymentMethod, // Pass the selected payment method
        adminViewed: false,
        isArchived: false,
      );
      final orderRef = await FirebaseFirestore.instance.collection('orders').add(order.toMap());
      final cartRef = FirebaseFirestore.instance.collection('cartItems');
      final cartSnapshot = await cartRef.get();
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
      await NotificationService.sendOrderStatusNotification(orderRef.id, 'confirmed');

      setState(() {
        isProcessing = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed Successfully!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text('Your order has been placed successfully with \n Order ID: ${orderRef.id.substring(0, math.min(8, orderRef.id.length))}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.offAll(
                        () => const ProductsScreen(),binding: UserProductsBinding(),
                    arguments: 3,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Orders'),
              ),            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error placing order: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Checkout"),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Order Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ...widget.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("${item.title} x${item.quantity}")),
                            Text("\$${(item.price * item.quantity).toStringAsFixed(2)}"),
                          ],
                        ),
                      )).toList(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "\$${widget.totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Shipping Information
                const Text("Shipping Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Shipping Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                const Text("Payment Method", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Select Payment Method',
                    border: OutlineInputBorder(),
                  ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // --- END NEW Payment Method Section ---

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: isProcessing
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("Processing..."),
                      ],
                    )
                        : const Text("Place Order"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}