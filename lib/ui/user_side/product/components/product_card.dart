import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

import '../../../components/constants.dart';
import '../../../../models/Product.dart';
import '../../../../models/wishlist_item.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    required Key? key,
    required this.itemIndex,
    required this.product,
    required this.press,
  }) : super(key: key);

  final int itemIndex;
  final Product product;
  final VoidCallback press;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isInWishlist = false;
  bool isLoading = false;
  final wishlistRef = FirebaseFirestore.instance.collection('wishlistItems');
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
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return; // Stop if no user is logged in
    }

    if (isLoading) return; // Prevent multiple rapid taps

    setState(() {
      isLoading = true;
    });

    try {
      if (isInWishlist) {
        // Remove from wishlist
        final snapshot = await wishlistRef
            .where('productId', isEqualTo: widget.product.id)
            .where('userId', isEqualTo: _currentUser!.uid) // Filter by user ID
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          isInWishlist = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.heart_broken, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("${widget.product.title} removed from wishlist"),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

        setState(() {
          isInWishlist = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("${widget.product.title} added to wishlist"),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
            duration: const Duration(seconds: 3),
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
    Size size = MediaQuery.of(context).size;
    // Optionally disable button if no user is logged in
    final bool isButtonDisabled = isLoading || _currentUser == null;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      height: 160,
      child: InkWell(
        onTap: widget.press,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            // Background Card (unchanged)
            Container(
              height: 136,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: widget.itemIndex.isEven ? kBlueColor : kPrimaryColor,
                boxShadow: [kDefaultShadow],
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),

            // Product Image (unchanged)
            Positioned(
              top: 27,
              right: 0,
              child: Hero(
                tag: '${widget.product.id}',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  height: 130,
                  width: 185,
                  child: (widget.product.image != null && widget.product.image!.isNotEmpty)
                      ? ClipOval(
                    child: Image.network(
                      widget.product.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                          ) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (
                          BuildContext context,
                          Object exception,
                          StackTrace? stackTrace,
                          ) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  )
                      : Image.asset(
                    'assets/images/placeholder.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Favorites Button (Modified)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: isButtonDisabled ? null : _toggleWishlist, // Disable if no user or loading
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isInWishlist ? Colors.red : Colors.grey,
                      ),
                    ),
                  )
                      : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isInWishlist),
                      color: isInWishlist ? Colors.red : (_currentUser == null ? Colors.grey.withOpacity(0.5) : Colors.grey), // Dim if not logged in
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // Product Info (unchanged)
            Positioned(
              bottom: 0,
              left: 0,
              child: SizedBox(
                height: 136,
                width: size.width - 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      child: Text(
                        widget.product.title,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 1.5,
                        vertical: kDefaultPadding / 4,
                      ),
                      decoration: const BoxDecoration(
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: Text(
                        "\$${widget.product.price}",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}