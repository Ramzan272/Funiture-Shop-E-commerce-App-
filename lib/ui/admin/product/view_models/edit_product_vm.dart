import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/AuthRepository.dart';
import '../../../../data/media_repository.dart';
import '../../../../data/products_repository.dart';
import '../../../../models/Product.dart';


class EditProductViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  ProductsRepository productsRepository = Get.find();
  MediaRepository mediaRepository = Get.find();

  var isUpdating = false.obs;
  Rxn<XFile> image = Rxn<XFile>();
  Future<void> updateProduct(
      Product product,
      String price,
      String title,
      String description,
      ) async {
    if (title.isEmpty) {
      Get.snackbar("Error", "Product Title cannot be empty");
      return;
    }
    if (description.isEmpty) {
      Get.snackbar("Error", "Description cannot be empty");
      return;
    }
    if (price.isEmpty) {
      Get.snackbar("Error", "Price cannot be empty");
      return;
    }
    if (double.tryParse(price) == null || double.parse(price) <= 0) {
      Get.snackbar("Error", "Price must be a number greater than 0");
      return;
    }

    isUpdating.value = true;

    try {
      if (image.value != null) {
        var imageResult = await mediaRepository.uploadImageFromXFile(image.value!);
        if (imageResult.isSuccessful) {
          product.image = imageResult.secureUrl;
        } else {
          Get.snackbar(
            "Error uploading image",
            imageResult.error?.message ?? "An error occurred while uploading image",
          );
          isUpdating.value = false;
          return;
        }
      }
      product.price = price;
      product.title = title;
      product.description = description;
      await productsRepository.updateProduct(product);
      Get.back();
      Get.snackbar(
        "Success",
        "Product updated successfully",
      );

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred while updating product: ${e.toString()}",
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        image.value = pickedImage;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        image.value = pickedImage;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to take photo: ${e.toString()}",
      );
    }
  }

  void clearImage() {
    image.value = null;
  }
}
