import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Make sure Get is imported

import '../../../components/constants.dart';
import '../../../../data/AuthRepository.dart'; // Ensure AuthRepository is imported
import '../../../../models/Product.dart';
import '../../edit_product.dart';
import '../view_models/products_vm.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    required Key? key,
    required this.itemIndex,
    required this.product,
    required this.press,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  final int itemIndex;
  final Product product;
  final VoidCallback press;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late ProductsViewModel productsViewModel;
  final AuthRepository authRepository = Get.find();

  @override
  void initState() {
    super.initState();
    productsViewModel = Get.find<ProductsViewModel>();
  }
  void _showProductOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Get.back(); // Close the bottom sheet
                  Get.to(EditProductScreen(),binding: UpdateBinding(),arguments: widget.product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Get.back(); // Close the bottom sheet
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Delete Product",
      middleText: "Are you sure you want to delete '${widget.product.title}'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: kPrimaryColor,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // Close the dialog
        await productsViewModel.deleteProduct(widget.product); // Pass the product ID
        Get.snackbar("Success", "Product deleted successfully!", snackPosition: SnackPosition.BOTTOM);
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      height: 160,
      child: GestureDetector(
        onLongPress: () => _showProductOptions(context),
        child: InkWell(
          onTap: widget.press,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                height: 136,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: widget.itemIndex.isEven ? kBlueColor : kPrimaryColor,
                  boxShadow: [kDefaultShadow],
                ),
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                right: 0,
                child: Hero(
                  tag: '${widget.product.id}',
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    height: 130,
                    width: 185,
                    child: ClipOval(
                      child: (widget.product.image != null &&
                          widget.product.image!.isNotEmpty)
                          ? Image.network(
                        widget.product.image!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                            ) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes !=
                                  null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (
                            BuildContext context,
                            Object exception,
                            StackTrace? stackTrace,
                            ) {
                          return Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        'assets/images/placeholder.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  height: 136,
                  width: size.width - 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: Text(
                          widget.product.title,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding * 1.5,
                          vertical: kDefaultPadding / 4,
                        ),
                        decoration: BoxDecoration(
                          color: kSecondaryColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                        child: Text(
                          "\$${widget.product.price}",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}