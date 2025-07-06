import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/admin/product/components/body.dart';
import 'package:furniture_shop/ui/admin/product/view_models/products_vm.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../auth/login.dart';
import '../components/constants.dart';
import '../../data/products_repository.dart';
import 'add_products.dart';
import 'chats/admin_chat_list_screen.dart';
import 'orders/admin_orders_screen.dart';
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}
class _AdminHomeState extends State<AdminHome> {
  final AuthRepository authRepository = Get.find();
  int _selectedIndex = 0;
  late PageController _pageController;
  final CollectionReference conversationsRef = FirebaseFirestore.instance.collection('conversations');
  final CollectionReference ordersRef = FirebaseFirestore.instance.collection('orders');
  static final List<Widget> _widgetOptions = <Widget>[
    AdminBody(),
    const AdminOrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _selectedIndex == 0 ? _buildAdminHomeAppBar(context) : null,
        backgroundColor: kPrimaryColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _widgetOptions,
        ),
        drawer: _buildAdminDrawer(context),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
          onPressed: () async {
            var result = await Get.to(() => const AddProductScreen(), binding: AddProductBinding());
            if (result == true) {
              Get.snackbar("Success", "Product added successfully", snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
        )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildOrdersBadgedIcon(Icons.shopping_cart),
              label: 'Orders',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
  AppBar _buildAdminHomeAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: const Text('Roomify (Admin)'),
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        _buildChatBadgedIcon(Icons.chat),
        const SizedBox(width: 8),
      ],
    );
  }
  Widget _buildOrdersBadgedIcon(IconData iconData) {
    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef
          .where('status', whereIn: ['pending', 'processing'])
          .where('adminViewed', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData && snapshot.data != null) {
          count = snapshot.data!.docs.length;
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(iconData),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  Widget _buildChatBadgedIcon(IconData iconData) {
    return StreamBuilder<QuerySnapshot>(
      stream: conversationsRef.where('hasUnreadMessages', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData && snapshot.data != null) {
          count = snapshot.data!.docs.length;
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(iconData),
              onPressed: () {
                Get.to(() => const AdminChatListScreen());
              },
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Admin Drawer Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryColor, Color(0xFF2E7D32)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Furniture Shop Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.inventory,
                  title: 'Product Management',
                  subtitle: 'Add, edit & manage products',
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  title: 'Order Management',
                  subtitle: 'View & manage customer orders',
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat,
                  title: 'Customer Support',
                  subtitle: 'Chat with customers',
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(2); // Select Chat tab
                  },
                ),

                const Divider(thickness: 1),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of admin panel',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admin Panel v1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? kPrimaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? kPrimaryColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Logout'),
          content: const Text('Are you sure you want to logout from the admin panel?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authRepository.logout();
                Get.offAll(() => SignIn(), binding: LoginBinding());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(ProductsRepository());
    Get.put(ProductsViewModel());
  }
}