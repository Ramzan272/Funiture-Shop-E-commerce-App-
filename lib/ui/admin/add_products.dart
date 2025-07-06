import 'dart:io';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/admin/product/view_models/add_product_vm.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../../data/products_repository.dart';
import '../../data/media_repository.dart'; // Keep if you use it for image handling

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}
class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageController =
      TextEditingController();
  late AddProductViewModel addProductVM;
  @override
  void initState() {
    super.initState();
    addProductVM = Get.find<AddProductViewModel>();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
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
            Get.back();
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  child: Text(
                    "Add Product",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Obx(
                () =>
                    addProductVM.pickedImageFile.value == null
                        ? const Icon(Icons.image, size: 80)
                        : Image.file(
                          File(addProductVM.pickedImageFile.value!.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
              ),
              ElevatedButton(
                onPressed: () {
                  addProductVM
                      .pickImage();
                },
                child: const Text('Pick Image'),
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
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter product title', // Changed hint text
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
                      keyboardType:
                          TextInputType.number, // Set keyboard type for numbers
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter price', // Changed hint text
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
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Enter product description',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Obx(() {
                return addProductVM.isSaving.value
                    ? CircularProgressIndicator()
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
                                addProductVM.addProduct(
                                  priceController.text,
                                  titleController.text,
                                  descriptionController.text,
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text(
                                  "Save Product", // Changed button text
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

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(ProductsRepository());
    Get.put(MediaRepository());
    Get.put(AddProductViewModel());
  }
}
