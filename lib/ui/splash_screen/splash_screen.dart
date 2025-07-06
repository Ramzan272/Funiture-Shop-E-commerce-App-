import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/AuthRepository.dart';
import '../admin/admin_home.dart';
import '../auth/login.dart';
import '../user_side/product/products_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final User? user = _authRepository.getLoggedInUser();

    if (user == null) {
      Get.offAll(() => SignIn());
    } else {
      if (user.email == 'ramzanmustafa865@gmail.com') {
        Get.offAll(() => const AdminHome(), binding: ProductsBinding());
      }
      else {
        Get.offAll(() => const ProductsScreen(), binding: UserProductsBinding());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 150),
            SizedBox(height: 30),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}