
import 'package:furniture_shop/ui/auth/view_models/login_vm.dart';
import 'package:furniture_shop/ui/auth/view_models/signup_vm.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../admin/admin_home.dart';
import '../user_side/product/products_screen.dart';
class AppInitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(LoginViewModel());
    Get.put(SignUpViewModel());
    UserProductsBinding().dependencies();
    ProductsBinding().dependencies();
  }
}