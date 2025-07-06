import 'package:get/get.dart';
import '../../../../data/AuthRepository.dart';
import '../../../../data/media_repository.dart';
import '../../../../data/products_repository.dart';
import 'add_product_vm.dart';
import 'edit_product_vm.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<ProductsRepository>(() => ProductsRepository());
    Get.lazyPut<MediaRepository>(() => MediaRepository());
    Get.lazyPut<AddProductViewModel>(() => AddProductViewModel());
    Get.lazyPut<EditProductViewModel>(() => EditProductViewModel());
  }
}
