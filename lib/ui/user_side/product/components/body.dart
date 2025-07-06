import 'package:flutter/material.dart';
import '../../../components/constants.dart';
import '../../../../data/products_repository.dart';
import '../../../../models/Product.dart';
import '../../../components/search_box.dart';
import '../../details/details_screen.dart';
import 'category_list.dart';
import 'product_card.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String searchQuery = "";
  List<Product> filteredProducts = [];
  List<Product> _allProducts = []; // To hold all products fetched from Firestore

  late ProductsRepository _productRepository; // Declare ProductRepository instance
  Stream<List<Product>>? _productsStream; // Stream to listen for product changes

  @override
  void initState() {
    super.initState();
    _productRepository = ProductsRepository(); // Initialize your ProductRepository
    _productsStream = _productRepository.loadAllProducts(); // Get the stream of products
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
              stream: _productsStream, // Use the Firestore stream
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

                // Data is available, update _allProducts and apply search filter
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                product: filteredProducts[index],
                                key: ValueKey(filteredProducts[index].id),
                              ),
                            ),
                          );
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