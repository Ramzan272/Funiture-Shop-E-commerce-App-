import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for specific types
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed for getting current user
import 'package:furniture_shop/ui/user_side/reviews_order_screen.dart';
import 'package:furniture_shop/ui/user_side/view_models/orders_view_model.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../components/constants.dart';
import '../../models/furniture.dart'; // Needed for FurnitureOrder model
import '../admin/orders/components/order_filter_chips.dart'; // Still needed for UI component
import 'dart:math' as math;


class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // ViewModel instance, initialized in initState
  late OrdersViewModel _ordersViewModel;

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel with the current user
    _ordersViewModel = OrdersViewModel(FirebaseAuth.instance.currentUser);
  }

  @override
  void dispose() {
    _ordersViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrdersViewModel>.value(
      value: _ordersViewModel,
      child: Consumer<OrdersViewModel>(
        builder: (context, ordersViewModel, child) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(ordersViewModel.showingFullHistory ? "Order History" : "My Orders"),
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                actions: [

                  if (!ordersViewModel.showingFullHistory) // Only show "Clear All" for active orders
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      tooltip: 'Clear All Orders',
                      onPressed: () async {
                        final bool? confirmClear = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete All Orders'),
                              content: const Text(
                                'Are you sure you want to delete all your active orders? They will be moved to history.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Yes, Delete All'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmClear == true) {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            String message = await ordersViewModel.moveAllOrdersToHistory();
                            if (mounted) Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: OrderFilterChips(
                      filters: ordersViewModel.getStatusFilters,
                      selectedFilter: ordersViewModel.selectedFilter,
                      onFilterChanged: (filter) {
                        ordersViewModel.setSelectedFilter(filter);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Displaying: ${ordersViewModel.filteredOrders.length} orders",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ordersViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ordersViewModel.filteredOrders.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            ordersViewModel.showingFullHistory
                                ? "No orders found in history."
                                : "No orders found.",
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                        : RefreshIndicator(
                      onRefresh: () async => ordersViewModel.toggleShowFullHistory(ordersViewModel.showingFullHistory), // Re-subscribe on refresh
                      child: ListView.builder(
                        itemCount: ordersViewModel.filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = ordersViewModel.filteredOrders[index];
                          final bool canCancelOrder =
                          (!order.isArchived &&
                              (order.status.toLowerCase() == 'pending' ||
                                  order.status.toLowerCase() == 'processing'));

                          final Widget orderCardWidget = Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: InkWell(
                              onLongPress: () async {
                                if (!mounted) return;

                                if (order.isArchived) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Deleted orders cannot be modified."),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final bool? shouldCancel = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Cancel Order'),
                                        content: Text(
                                          'Are you sure you want to cancel order #${order.id.substring(0, math.min(8, order.id.length))}?\n\nThis action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Keep Order'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Cancel Order'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldCancel == true) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                    String message = await ordersViewModel.cancelOrder(order);
                                    if (mounted) Navigator.of(context).pop();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) Navigator.of(context).pop();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              onTap: () async {
                                if (order.status.toLowerCase() == 'delivered') {
                                  final bool? reviewSubmitted = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewOrderScreen(order: order),
                                    ),
                                  );
                                  if (reviewSubmitted == true) {
                                    // Re-fetch to update UI if needed (e.g., if review status is shown)
                                    ordersViewModel.toggleShowFullHistory(ordersViewModel.showingFullHistory);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Only delivered orders can be reviewed."),
                                      backgroundColor: Colors.blueGrey,
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Order #${order.id.substring(0, math.min(8, order.id.length))}",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (canCancelOrder)
                                      Tooltip(
                                        message: "Long press to cancel",
                                        child: Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Total: \$${order.totalAmount.toStringAsFixed(2)}"),
                                    Text("Date: ${order.orderDate.toLocal().toString().split(' ')[0]}"),
                                    if (canCancelOrder)
                                      const Text(
                                        "Long press to cancel",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ordersViewModel.getStatusColor(order.status), // Use ViewModel's helper
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        ...order.items.map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text("${item['title'] ?? 'Unknown Item'} x${item['quantity'] ?? 1}"),
                                              ),
                                              Text(
                                                "\$${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(
                                              "\$${order.totalAmount.toStringAsFixed(2)}",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        if (canCancelOrder) ...[
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                try {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) => const Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  );
                                                  String message = await ordersViewModel.cancelOrder(order);
                                                  if (mounted) Navigator.of(context).pop();
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(message),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) Navigator.of(context).pop();
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Error: ${e.toString()}"),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              icon: const Icon(Icons.cancel),
                                              label: const Text("Cancel Order"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (!ordersViewModel.showingFullHistory) {
                            return Dismissible(
                              key: Key('archive_${order.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.blueGrey,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.archive, color: Colors.white, size: 36),
                              ),
                              confirmDismiss: (direction) async {
                                final bool? confirmArchive = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Order'),
                                      content: Text('Are you sure you want to delete order #${order.id.substring(0, math.min(8, order.id.length))} ?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmArchive == true) {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                    bool success = await ordersViewModel.moveSpecificOrderToHistory(order);
                                    if (mounted) Navigator.of(context).pop();
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Order #${order.id.substring(0, math.min(8, order.id.length))} has been moved to history."),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                    return success;
                                  } catch (e) {
                                    if (mounted) Navigator.of(context).pop();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Error: ${e.toString()}"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return false;
                                  }
                                }
                                return false;
                              },
                              onDismissed: (direction) {
                               },
                              child: orderCardWidget,
                            );
                          } else { // For history orders, allow permanent deletion
                            return Dismissible(
                              key: Key('delete_${order.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete_forever, color: Colors.white, size: 36),
                              ),
                              confirmDismiss: (direction) async {
                                final bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Order Permanently'),
                                      content: const Text('Are you sure you want to permanently delete this order from your history? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Delete Permanently'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                    bool success = await ordersViewModel.deleteSpecificOrder(order.id);
                                    if (mounted) Navigator.of(context).pop();
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Order permanently deleted from history."),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                    return success;
                                  } catch (e) {
                                    if (mounted) Navigator.of(context).pop();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Error: ${e.toString()}"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return false;
                                  }
                                }
                                return false;
                              },
                              onDismissed: (direction) {
                                // No need to manually update state here; stream will handle it
                              },
                              child: orderCardWidget,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}