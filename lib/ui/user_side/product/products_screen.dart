import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // Svg is imported but not used in the provided snippet
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../components/constants.dart';
import '../../../data/AuthRepository.dart';
import '../../auth/login.dart';
import '../cart_screen.dart';
import '../chat_screen.dart';
import '../orders_screen.dart';
import '../wishlist_screen.dart';
import 'components/body.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final AuthRepository authRepository = Get.find();
  int _selectedIndex = 0;
  late PageController _pageController;

  final CollectionReference cartRef = FirebaseFirestore.instance.collection('cartItems');
  final CollectionReference wishlistRef = FirebaseFirestore.instance.collection('wishlistItems');
  final CollectionReference conversationsRef = FirebaseFirestore.instance.collection('conversations');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId; // This will hold the current user's ID

  static final List<Widget> _widgetOptions = <Widget>[
    Body(),
    WishlistScreen(),
    const CartScreen(),
    const OrdersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    super.initState();
    // It's crucial to get the current user ID here or whenever authentication state changes.
    // FirebaseAuth.instance.authStateChanges() is ideal for reacting to login/logout.
    _auth.authStateChanges().listen((User? user) {
      if (mounted) { // Ensure widget is still in the tree
        setState(() {
          _currentUserId = user?.uid;
        });
      }
    });

    if (Get.arguments != null && Get.arguments is int) {
      _selectedIndex = Get.arguments as int;
    }
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _selectedIndex == 0 ? _buildHomeAppBar(context) : null,
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
        drawer: _buildDrawer(context),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              // Pass _currentUserId to filter wishlist items
              icon: _buildCollectionBadgedIcon(Icons.favorite, wishlistRef, _currentUserId),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              // Pass _currentUserId to filter cart items
              icon: _buildCollectionBadgedIcon(Icons.shopping_cart, cartRef, _currentUserId),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.airport_shuttle_rounded),
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

  // Modified function to accept currentUserId
  Widget _buildCollectionBadgedIcon(IconData iconData, CollectionReference collectionRef, String? userId) {
    // If no user is logged in, return an icon without a badge
    if (userId == null) {
      return Icon(iconData);
    }

    return StreamBuilder<QuerySnapshot>(
      // Filter the stream by userId
      stream: collectionRef.where('userId', isEqualTo: userId).snapshots(),
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

  AppBar _buildHomeAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          const Text('Roomify'),
          const Spacer(),
          _currentUserId == null // Only show chat icon if user is logged in
              ? const SizedBox.shrink()
              : StreamBuilder<QuerySnapshot>(
            // Assuming 'conversations' collection has a 'userId' field matching current user
            // And 'userHasUnreadMessages'/'userUnreadCount' for unread status
            stream: conversationsRef.where('userId', isEqualTo: _currentUserId).limit(1).snapshots(),
            builder: (context, snapshot) {
              int unreadCountForUser = 0;
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final conversationData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                // It's important to check the actual fields in your conversation document
                // For simplicity, assuming a 'userUnreadCount' field.
                // You might have a more complex structure, e.g., mapping unread counts per user.
                final int? unreadCount = conversationData['userUnreadCount'] as int?;
                if (unreadCount != null && unreadCount > 0) {
                  unreadCountForUser = unreadCount;
                }
                // The previous logic for 'userHasUnreadMessages' and 'userUnreadCount' was slightly
                // redundant if 'userUnreadCount' directly gives the count.
                // Keeping a simplified check here.
              }
              return _buildBadgedIconForChat(Icons.chat, unreadCountForUser);
            },
          ),
        ],
      ),
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  Widget _buildBadgedIconForChat(IconData iconData, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(iconData),
          onPressed: () {
            if (_currentUserId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please log in to chat."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              Get.to(() => const ChatScreen());
            }
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
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
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
                    Icons.chair,
                    size: 40,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Furniture Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Display user email if logged in
                _currentUserId != null
                    ? StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userData = snapshot.data!.data() as Map<String, dynamic>?;
                      final email = userData?['email'] ?? 'Welcome back!';
                      return Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    }
                    return const Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    );
                  },
                )
                    : const Text(
                  'Welcome back!',
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
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.airport_shuttle_rounded,
                  title: 'My Orders',
                  subtitle: 'Track your orders',
                  onTap: () {
                    Navigator.pop(context);
                    if (_currentUserId == null) {
                      _showLoginRequiredSnackBar("view your orders");
                      return;
                    }
                    _onItemTapped(3);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart,
                  title: 'Shopping Cart',
                  subtitle: 'View cart items',
                  onTap: () {
                    Navigator.pop(context);
                    if (_currentUserId == null) {
                      _showLoginRequiredSnackBar("view your cart");
                      return;
                    }
                    _onItemTapped(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite,
                  title: 'Wishlist',
                  subtitle: 'Your favorite items',
                  onTap: () {
                    Navigator.pop(context);
                    if (_currentUserId == null) {
                      _showLoginRequiredSnackBar("view your wishlist");
                      return;
                    }
                    _onItemTapped(1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat,
                  title: 'Customer Support',
                  subtitle: 'Chat with us',
                  onTap: () {
                    Navigator.pop(context);
                    if (_currentUserId == null) {
                      _showLoginRequiredSnackBar("chat with support");
                      return;
                    }
                    Get.to(() => const ChatScreen());
                  },
                ),
                const Divider(thickness: 1),
                _currentUserId != null
                    ? _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                )
                    : _buildDrawerItem(
                  icon: Icons.login,
                  title: 'Login',
                  subtitle: 'Sign in to your account',
                  iconColor: kPrimaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    Get.offAll(() => SignIn(), binding: LoginBinding());
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
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Version 1.0.0',
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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
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

  void _showLoginRequiredSnackBar(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please log in to $action."),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class UserProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
  }
}