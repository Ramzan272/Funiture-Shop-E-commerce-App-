import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/AuthRepository.dart';
import '../../admin/admin_home.dart';
import '../../user_side/product/products_screen.dart';

class LoginViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  var isLoading = false.obs;


  Future<void> login(String email, String password) async {
    if(!email.contains("@")){
      Get.snackbar("Error", "Enter proper email");
      return;
    }
    if(password.length<6){
      Get.snackbar("Error", "Password must be 6 characters atleast");
      return;
    }
    isLoading.value = true;
    try {
      await authRepository.login(email, password);
      if(email =='ramzanmustafa865@gmail.com' && password =='123456'){
        Get.offAll(AdminHome(),binding: ProductsBinding());
      }else
      Get.offAll(ProductsScreen(),binding: UserProductsBinding());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Login failed");
    }
    isLoading.value = false;
  }

  bool isUserLoggedIn(){
    return authRepository.getLoggedInUser()!=null;
  }
}
