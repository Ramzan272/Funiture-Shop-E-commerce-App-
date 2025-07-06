import 'package:flutter/material.dart';
import '../../../components/constants.dart';
import '../../../../data/products_repository.dart';
import '../../../../models/Product.dart';
import '../../../components/search_box.dart';
import '../../../user_side/product/components/product_card.dart';
import 'category_list.dart';

class AdminBody extends StatefulWidget {
  @override
  _AdminBodyState createState() => _AdminBodyState();
}

class _AdminBodyState extends State<AdminBody> {
  String searchQuery = "";
  List<Product> filteredProducts = [];
  List<Product> _allProducts = [];

  late ProductsRepository _productRepository;
  Stream<List<Product>>? _productsStream;

  @override
  void initState() {
    super.initState();
    _productRepository = ProductsRepository();
    _productsStream = _productRepository.loadAllProducts();
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = _allProducts.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          SearchBox(
            onChanged: updateSearch,
          ),
          CategoryList(),
          SizedBox(height: kDefaultPadding / 2),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading products: ${snapshot.error}",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  );
                }
                _allProducts = snapshot.data!;
                filteredProducts = _allProducts.where((product) {
                  return product.title.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 70),
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    // Display filtered products using ListView.builder
                    ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) => ProductCard(
                        itemIndex: index,
                        product: filteredProducts[index],
                        press: () {

                        },
                        key: ValueKey(filteredProducts[index].id),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}