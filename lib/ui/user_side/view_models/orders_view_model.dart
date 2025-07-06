import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../models/furniture.dart'; // For order ID shortening


class OrdersViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser; // Pass current user for order filtering

  List<FurnitureOrder> _allOrders = [];
  List<FurnitureOrder> _filteredOrders = [];
  bool _isLoading = true;
  bool _showingFullHistory = false; // Corresponds to `isArchived` filter
  String _selectedFilter = 'All'; // Corresponds to status filter
  StreamSubscription? _orderSubscription;

  final List<String> statusFilters = [
    'All',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  // Public getters for UI to consume
  List<FurnitureOrder> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  bool get showingFullHistory => _showingFullHistory;
  String get selectedFilter => _selectedFilter;
  List<String> get getStatusFilters => statusFilters;
  List<FurnitureOrder> get allOrders => _allOrders; // Expose all orders for `_moveAllOrdersToHistory`

  OrdersViewModel(this._currentUser) {
    _subscribeToOrders();
  }

  // --- Order Subscription and Filtering ---
  void _subscribeToOrders() {
    _orderSubscription?.cancel(); // Cancel any existing subscription

    if (_currentUser == null) {
      _isLoading = false;
      _allOrders = [];
      _filteredOrders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    Query<Map<String, dynamic>> query = _firestore
        .collection('orders')
        .where('customerEmail', isEqualTo: _currentUser!.email) // Filter by current user's email
        .orderBy('orderDate', descending: true);

    // Apply history filter based on _showingFullHistory
    query = query.where('isArchived', isEqualTo: _showingFullHistory);


    _orderSubscription = query.snapshots().listen(
          (snapshot) {
        _allOrders = snapshot.docs
            .map((doc) => FurnitureOrder.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        _applyFilter(); // Apply status filter after data fetch
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        print("Error loading orders: $error"); // Log error
        // You might want to expose this error to the UI (e.g., via a StreamController<String> errorMessages)
        notifyListeners();
      },
    );
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredOrders = List.from(_allOrders);
    } else {
      _filteredOrders = _allOrders
          .where((order) => order.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void toggleShowFullHistory(bool show) {
    if (_showingFullHistory != show) {
      _showingFullHistory = show;
      _selectedFilter = 'All'; // Reset filter when toggling history
      _subscribeToOrders(); // Re-subscribe with new history filter
      notifyListeners();
    }
  }

  // --- Order Actions (move to history, delete, cancel) ---

  /// Moves all non-archived orders for the current user to archived status.
  /// Returns a message string for UI feedback.
  Future<String> moveAllOrdersToHistory() async {
    if (_showingFullHistory) {
      return "This option is only for orders to delete.";
    }
    if (_allOrders.isEmpty) { // Check _allOrders, not filtered
      return "No active orders to delete.";
    }

    try {
      WriteBatch batch = _firestore.batch();
      for (var order in _allOrders.where((o) => o.isArchived == false)) {
        batch.update(_firestore.collection('orders').doc(order.id), {'isArchived': true});
      }
      await batch.commit();
      return "All active orders have been moved to history!";
    } catch (e) {
      print("Error moving all orders to history: $e");
      throw Exception("Failed to delete all orders: $e"); // Re-throw for UI error handling
    }
  }

  /// Moves a specific order to archived status.
  /// Returns true on success, false on failure.
  Future<bool> moveSpecificOrderToHistory(FurnitureOrder order) async {
    try {
      await _firestore.collection('orders').doc(order.id).update({'isArchived': true});
      return true;
    } catch (e) {
      print("Error moving order to history: $e");
      throw Exception("Failed to delete order: ${order.id.substring(0, math.min(8, order.id.length))}"); // Re-throw for UI
    }
  }

  /// Permanently deletes a specific order from history.
  /// Returns true on success, false on failure.
  Future<bool> deleteSpecificOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      return true;
    } catch (e) {
      print("Error deleting order: $e");
      throw Exception("Failed to permanently delete order: ${orderId.substring(0, math.min(8, orderId.length))}"); // Re-throw for UI
    }
  }

  /// Attempts to cancel an order based on its status.
  /// Returns true if cancellation initiated, throws error if not cancellable or failed.
  Future<String> cancelOrder(FurnitureOrder order) async {
    final bool isCancellableStatus =
        order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'processing';

    if (!isCancellableStatus) {
      String cancellationReason;
      if (order.status.toLowerCase() == 'shipped') {
        cancellationReason = "because the order already has been shipped.";
      } else if (order.status.toLowerCase() == 'delivered') {
        cancellationReason = "because the order already has been delivered.";
      } else if (order.status.toLowerCase() == 'cancelled') {
        cancellationReason = "because the order has already been cancelled.";
      } else {
        cancellationReason = "as its status is no longer eligible for cancellation.";
      }
      throw Exception("This order cannot be cancelled $cancellationReason");
    }

    try {
      await _firestore.collection('orders').doc(order.id).update({'status': 'cancelled'});
      return "Order #${order.id.substring(0, math.min(8, order.id.length))} has been cancelled";
    } catch (e) {
      print("Error cancelling order: $e");
      throw Exception("Failed to cancel order: ${order.id.substring(0, math.min(8, order.id.length))}");
    }
  }

  // Helper for status color (can remain here or be a utility in UI)
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}