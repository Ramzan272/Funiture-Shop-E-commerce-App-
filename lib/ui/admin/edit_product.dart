import 'dart:io';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/admin/product/view_models/edit_product_vm.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart'; // Ensure these paths are correct
import '../../data/media_repository.dart';
import '../../data/products_repository.dart';
import '../../models/Product.dart';
import '../admin/admin_home.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}
class _EditProductScreenState extends State<EditProductScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  late EditProductViewModel editProductVM;
  late Product product; // This will be initialized in initState

  @override
  void initState() {
    super.initState();
    editProductVM = Get.find<EditProductViewModel>();
    product =Get.arguments;
    if (product !=null) {
      priceController = TextEditingController(text: product!.price.toString());
      titleController = TextEditingController(text: product!.title);
      descriptionController = TextEditingController(text: product!.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => AdminHome());
          },
          icon: const Icon(Icons.arrow_back),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    "Edit Product",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () =>
                    editProductVM.image.value == null
                        ? (product.image != null &&
                                product
                                    .image!
                                    .isNotEmpty // Display existing image
                            ? Image.network(
                              product.image!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                  ),
                            )
                            : const Icon(
                              Icons.image,
                              size: 80,
                            )) // Placeholder if no image
                        : Image.file(
                          File(editProductVM.image.value!.path),
                          width: 800,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
              ),

              ElevatedButton(
                onPressed: () {
                  editProductVM.pickImage();
                },
                child: const Text('Pick Image'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter product title',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter product description',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter price',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Obx(() {
                return editProductVM.isUpdating.value
                    ? const CircularProgressIndicator()
                    : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              color: const Color(0xFF1E232C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onPressed: () {
                                // Ensure product is valid before attempting update
                                if (product != null) {
                                  editProductVM.updateProduct(
                                    product,
                                    priceController.text,
                                    titleController.text,
                                    descriptionController.text,
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(ProductsRepository());
    Get.put(MediaRepository());
    Get.put(EditProductViewModel());
  }
}
