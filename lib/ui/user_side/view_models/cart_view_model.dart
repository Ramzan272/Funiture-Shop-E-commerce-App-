import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../../models/cart_item.dart';

class CartViewModel extends ChangeNotifier {
  final cartRef = FirebaseFirestore.instance.collection('cartItems');
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  Set<String> _updatingItems = {}; // To track items currently being updated

  User? _currentUser; // Holds the current authenticated user

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  Set<String> get updatingItems => _updatingItems;
  String? get currentUserId => _currentUser?.uid; // Expose current user ID

  CartViewModel() {
    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      // When auth state changes, reload the cart specific to the new user (or clear if logged out)
      _loadCartItems();
    });
  }

  Future<void> _loadCartItems() async {
    if (_currentUser == null) {
      // If no user is logged in, clear the cart and stop loading
      _cartItems = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Query cart items filtered by the current user's ID
      final snapshot = await cartRef
          .where('userId', isEqualTo: _currentUser!.uid) // <--- Filter by user ID
          .orderBy('timestamp', descending: true)
          .get();

      _cartItems = snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error loading cart: $e");
      // Consider adding error handling for the UI here
    }
  }

  // Method to add an item to the cart (you'll need to call this from your product detail/listing screen)
  Future<void> addItemToCart(String productId, String title, String image, double price, int quantity) async {
    if (_currentUser == null) {
      print("Cannot add to cart: No user logged in.");
      // You might want to show a message to the user in the UI
      return;
    }

    try {
      // Check if the item already exists in the user's cart
      final existingCartItemSnapshot = await cartRef
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: _currentUser!.uid)
          .limit(1)
          .get();

      if (existingCartItemSnapshot.docs.isNotEmpty) {
        // Item exists, update quantity
        final existingItem = CartItem.fromMap(existingCartItemSnapshot.docs.first.data() as Map<String, dynamic>, existingCartItemSnapshot.docs.first.id);
        await updateQuantity(existingItem, existingItem.quantity + quantity);
      } else {
        // Item does not exist, add new
        final newCartItem = CartItem(
          id: '', // Firestore will generate this
          productId: productId,
          title: title,
          image: image,
          price: price,
          quantity: quantity,
          userId: _currentUser!.uid, // <--- Assign current user's ID
        );
        await cartRef.add(newCartItem.toMap());
        await _loadCartItems(); // Reload to get the new item with its generated ID
      }
      // You might want to add a success message here for the UI
    } catch (e) {
      print("Error adding item to cart: $e");
      // Add error handling for the UI
    }
  }

  Future<void> clearCart() async {
    if (_currentUser == null) {
      print("Cannot clear cart: No user logged in.");
      return;
    }

    try {
      // Query documents belonging to the current user
      final snapshot = await cartRef.where('userId', isEqualTo: _currentUser!.uid).get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await _loadCartItems(); // Reload after clearing
    } catch (e) {
      print("Error clearing cart: $e");
      // Notify UI for error
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (_currentUser == null) {
      print("Cannot update quantity: No user logged in.");
      return;
    }
    if (_updatingItems.contains(item.id)) return;

    try {
      _updatingItems.add(item.id);
      notifyListeners();

      if (newQuantity <= 0) {
        await deleteItem(item.id);
        return;
      }

      await cartRef.doc(item.id).update({'quantity': newQuantity});

      // Update the item in the local list without reloading the entire cart
      final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
      if (index != -1) {
        _cartItems[index] = CartItem(
          id: item.id,
          productId: item.productId,
          title: item.title,
          image: item.image,
          price: item.price,
          quantity: newQuantity,
          userId: item.userId, // Ensure userId is carried over
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error updating quantity: $e");
      // Notify UI for error
    } finally {
      _updatingItems.remove(item.id);
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    if (_currentUser == null) {
      print("Cannot delete item: No user logged in.");
      return;
    }

    try {
      // Before deleting, verify the item belongs to the current user
      final itemDoc = await cartRef.doc(id).get();
      if (itemDoc.exists && itemDoc.data()?['userId'] == _currentUser!.uid) {
        await cartRef.doc(id).delete();
        await _loadCartItems(); // Reload after deletion
      } else {
        print("Attempted to delete item not belonging to user or non-existent.");
      }
    } catch (e) {
      print("Error removing item: $e");
      // Notify UI for error
    }
  }

  double calculateTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}