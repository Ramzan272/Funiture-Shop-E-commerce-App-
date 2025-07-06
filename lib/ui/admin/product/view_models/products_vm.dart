import 'package:get/get.dart';

import 'package:get/get_core/src/get_main.dart';

import '../../../../data/AuthRepository.dart';
import '../../../../data/products_repository.dart';
import '../../../../models/Product.dart';




class ProductsViewModel extends GetxController {
  AuthRepository authRepository = Get.find();

  ProductsRepository productsRepository = Get.find();

  var isLoading = false.obs;

  var products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllProducts();
  }

  void loadAllProducts() {
    productsRepository.loadAllProducts().listen((data) {
      products.value = data;
    });
  }

  Future<void> deleteProduct(Product product) async {
    await productsRepository.deleteProduct(product);
  }
}