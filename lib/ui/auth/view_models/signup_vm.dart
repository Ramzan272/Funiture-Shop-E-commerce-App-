import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../user_side/product/products_screen.dart';

class SignUpViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  var isLoading = false.obs;

  Future<void> signup(String email, String password, String confirmPassword) async {
    if(!email.contains("@")){
      Get.snackbar("Error", "Enter proper email");
      return;
    }
    if(password.length<6){
      Get.snackbar("Error", "Password must be 6 characters atleast");
      return;
    }
    if(password!=confirmPassword){
      Get.snackbar("Error", "Password and confirm password must match");
      return;
    }
    isLoading.value = true;
    try {
      await authRepository.signup(email, password);
      Get.offAll(ProductsScreen(),binding: UserProductsBinding());
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Signup failed");
    }
    isLoading.value = false;
  }

  bool isUserLoggedIn(){
    return authRepository.getLoggedInUser()!=null;
  }
}
