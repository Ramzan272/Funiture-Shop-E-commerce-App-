import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../../components/constants.dart';
import '../../../../models/Product.dart';

class ChatAndAddToCart extends StatelessWidget {
  final Product product;
  final VoidCallback onChat;

  const ChatAndAddToCart({
    Key? key,
    required this.product,
    required this.onChat,
  }) : super(key: key);

  Future<void> _addToCart(BuildContext context) async {
    // Get the current authenticated user's ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please log in to add items to the cart."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Stop if no user is logged in
    }
    final userId = user.uid; // Get the user's UID

    try {
      final cartRef = FirebaseFirestore.instance.collection('cartItems');

      // Check if item already exists in cart for THIS USER
      final existingItem = await cartRef
          .where('productId', isEqualTo: product.id.toString())
          .where('userId', isEqualTo: userId) // <-- Filter by userId
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Update quantity if item exists
        final doc = existingItem.docs.first;
        final currentQuantity = doc.data()['quantity'] as int;
        await doc.reference.update({'quantity': currentQuantity + 1});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product.title} quantity updated in cart"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new item to cart
        await cartRef.add({
          'productId': product.id.toString(),
          'title': product.title,
          'image': product.image,
          'price': product.price,
          'quantity': 1,
          'userId': userId, // <-- Store the userId here
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product.title} added to cart"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding to cart: $e"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(kDefaultPadding),
      padding: EdgeInsets.only(
        left: 100,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCBF1E),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: () => _addToCart(context),
            icon: SvgPicture.asset(
              "assets/icons/shopping-bag.svg",
              height: 18,
            ),
            label: Text(
              "Add to Cart",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}