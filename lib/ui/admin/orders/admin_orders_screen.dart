
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/admin/orders/view_models/admin_orders_viewmodel.dart';
import 'package:get/get.dart'; // Import GetX
import '../../components/constants.dart';
import 'components/order_card.dart';
import 'components/order_filter_chips.dart';

class AdminOrdersScreen extends StatelessWidget { // Changed to StatelessWidget
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the ViewModel. Get.put() ensures it's created and managed by GetX.
    final AdminOrdersViewModel viewModel = Get.put(AdminOrdersViewModel());

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin - Orders Management"),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: viewModel.loadOrders, // Call ViewModel method
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Obx(() => OrderFilterChips( // Wrap with Obx to react to selectedFilter changes
                filters: viewModel.statusFilters,
                selectedFilter: viewModel.selectedFilter.value, // Access RxString value
                onFilterChanged: viewModel.onFilterChanged, // Call ViewModel method
              )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => Row( // Wrap with Obx to react to filteredOrders changes
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Displaying: ${viewModel.filteredOrders.length} orders", // Access RxList length
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Total Revenue: \$${viewModel.calculateTotalRevenue().toStringAsFixed(2)}", // Call ViewModel method
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              )),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() { // Obx for the main content based on loading/empty/data state
                if (viewModel.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.selectedFilter.value == 'All'
                              ? "No orders found."
                              : "No ${viewModel.selectedFilter.value} orders found.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: viewModel.loadOrders, // Call ViewModel method
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: viewModel.filteredOrders.length, // Access RxList length
                    itemBuilder: (context, index) {
                      final order = viewModel.filteredOrders[index]; // Access RxList item
                      return OrderCard(
                        order: order,
                        onStatusUpdate: viewModel.updateOrderStatus, // Call ViewModel method
                        isArchived: order.isArchived ?? false,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}