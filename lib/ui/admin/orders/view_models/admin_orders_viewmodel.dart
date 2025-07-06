// lib/viewmodels/admin_orders_viewmodel.dart (Create this new file)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/furniture.dart';

class AdminOrdersViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference ordersRef = FirebaseFirestore.instance.collection('orders');

  final RxList<FurnitureOrder> orders = <FurnitureOrder>[].obs; // All orders from Firestore
  final RxList<FurnitureOrder> filteredOrders = <FurnitureOrder>[].obs; // Orders shown after applying filter
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'All'.obs; // Default filter

  final List<String> statusFilters = [
    'All',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'archived',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders(); // Initial load
    // Mark new orders as viewed when ViewModel is initialized
    // Using a delay to ensure UI is ready, though not strictly necessary with GetX reactive.
    Future.delayed(Duration(milliseconds: 500), () {
      markNewOrdersAsViewed();
    });
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final snapshot = await ordersRef.orderBy('orderDate', descending: true).get();
      orders.value = snapshot.docs
          .map((doc) => FurnitureOrder.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      applyFilter(); // Apply the current filter after loading
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error loading orders: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      print("Error loading orders: $e"); // Log for debugging
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNewOrdersAsViewed() async {
    try {
      final QuerySnapshot newOrdersSnapshot = await ordersRef
          .where('status', whereIn: ['pending', 'processing'])
          .where('adminViewed', isEqualTo: false)
          .get();

      if (newOrdersSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _firestore.batch();
        for (var doc in newOrdersSnapshot.docs) {
          batch.update(doc.reference, {'adminViewed': true});
        }
        await batch.commit();
        print('AdminOrdersViewModel: Successfully marked ${newOrdersSnapshot.docs.length} new orders as viewed.');

        // Update the local 'orders' list to reflect the 'adminViewed' status change
        // This is important for immediate UI update without a full reload
        // Iterate over a copy to avoid concurrent modification during update
        final List<FurnitureOrder> updatedOrders = List.from(orders);
        for (var doc in newOrdersSnapshot.docs) {
          final index = updatedOrders.indexWhere((order) => order.id == doc.id);
          if (index != -1) {
            updatedOrders[index] = updatedOrders[index].copyWith(adminViewed: true);
          }
        }
        orders.value = updatedOrders; // Assign the updated list back
        applyFilter(); // Re-apply filter after updating local data
      }
    } catch (e) {
      print("AdminOrdersViewModel: Error marking new orders as viewed: $e");
    }
  }

  void applyFilter() {
    if (selectedFilter.value == 'All') {
      filteredOrders.value = List.from(orders); // Show all orders
    } else if (selectedFilter.value == 'archived') {
      filteredOrders.value = orders
          .where((order) => order.isArchived == true) // Show only archived orders
          .toList();
    } else {
      // For status filters, show non-archived orders matching the status
      filteredOrders.value = orders
          .where((order) =>
      order.status.toLowerCase() == selectedFilter.value.toLowerCase() &&
          order.isArchived == false)
          .toList();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Update status and mark as viewed
      await ordersRef.doc(orderId).update({
        'status': newStatus,
        'adminViewed': true, // Always mark as viewed when admin interacts
      });

      // Update the local list to reflect the change
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        // Create a new list with the updated order
        final List<FurnitureOrder> updatedOrders = List.from(orders);
        updatedOrders[orderIndex] = updatedOrders[orderIndex].copyWith(
          status: newStatus,
          adminViewed: true,
        );
        orders.value = updatedOrders; // Update the observable list
        applyFilter(); // Re-apply filter to update the view
      }

      Get.snackbar(
        "Success",
        "Order status updated to $newStatus",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error updating order: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      print("Error updating order: $e"); // Log for debugging
    }
  }

  double calculateTotalRevenue() {
    return filteredOrders
        .where((order) => order.status.toLowerCase() != 'cancelled')
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Method for changing filter from UI
  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }
}