import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../../models/Product.dart';
import '../../../models/wishlist_item.dart';

class WishlistButton extends StatefulWidget {
  final Product product;

  const WishlistButton({Key? key, required this.product}) : super(key: key);

  @override
  _WishlistButtonState createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  bool isInWishlist = false;
  bool isLoading = false;
  User? _currentUser; // To hold the current user

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get current user
    if (_currentUser != null) { // Only check status if a user is logged in
      _checkWishlistStatus();
    }
  }

  Future<void> _checkWishlistStatus() async {
    if (_currentUser == null) return; // Do nothing if no user is logged in

    try {
      final wishlistRef = FirebaseFirestore.instance.collection('wishlistItems');
      final snapshot = await wishlistRef
          .where('productId', isEqualTo: widget.product.id)
          .where('userId', isEqualTo: _currentUser!.uid) // Filter by user ID
          .get();

      if (mounted) {
        setState(() {
          isInWishlist = snapshot.docs.isNotEmpty;
        });
      }
    } catch (e) {
      print("Error checking wishlist status: $e");
      // Optionally show a SnackBar error for the user here as well
    }
  }

  Future<void> _toggleWishlist() async {
    if (_currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please log in to manage your wishlist."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // Stop if no user is logged in
    }

    setState(() {
      isLoading = true;
    });

    try {
      final wishlistRef = FirebaseFirestore.instance.collection('wishlistItems');

      if (isInWishlist) {
        // Remove from wishlist
        final snapshot = await wishlistRef
            .where('productId', isEqualTo: widget.product.id)
            .where('userId', isEqualTo: _currentUser!.uid) // Filter by user ID
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        if (mounted) {
          setState(() {
            isInWishlist = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.product.title} removed from wishlist"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Add to wishlist
        final wishlistItem = WishlistItem(
          id: '',
          productId: widget.product.id,
          title: widget.product.title,
          image: widget.product.image ?? '',
          price: widget.product.price,
          description: widget.product.description,
          timestamp: DateTime.now(),
          userId: _currentUser!.uid, // Add current user's ID
        );

        await wishlistRef.add(wishlistItem.toMap());

        if (mounted) {
          setState(() {
            isInWishlist = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.product.title} added to wishlist"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating wishlist: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optionally disable button if no user is logged in
    final bool isButtonDisabled = isLoading || _currentUser == null;

    return IconButton(
      onPressed: isButtonDisabled ? null : _toggleWishlist,
      icon: isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Icon(
        isInWishlist ? Icons.favorite : Icons.favorite_border,
        color: isInWishlist ? Colors.red : (_currentUser == null ? Colors.grey.withOpacity(0.5) : Colors.grey), // Dim if not logged in
        size: 28,
      ),
    );
  }
}