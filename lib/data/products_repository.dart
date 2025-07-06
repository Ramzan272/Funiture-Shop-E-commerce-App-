import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Product.dart'; // Ensure this path is correct

class ProductsRepository {
  late CollectionReference productsCollection;
  ProductsRepository() {
    productsCollection = FirebaseFirestore.instance.collection('products');
  }
  Future<void> addProduct(Product product) {
    var doc = productsCollection.doc();
    product.id = doc.id;
    return doc.set(product.toMap());
  }
  Future<void> updateProduct( product) async {
    return productsCollection.doc(product.id).set(product.toMap());
  }

  Future<void> deleteProduct( product) {
    return productsCollection.doc(product.id).delete();
  }
  Stream<List<Product>> loadAllProducts() {
    return productsCollection.snapshots().map(
          (snapshot) {
        return convertToProducts(snapshot);
      },
    );
  }
  Future<List<Product>> loadAllProductsOnce() async {
    var snapshot = await productsCollection.get();
    return convertToProducts(snapshot);
  }
  List<Product> convertToProducts(QuerySnapshot snapshot) {
    List<Product> products = [];
    for (var snap in snapshot.docs) {
      products.add(Product.fromMap(snap.data() as Map<String, dynamic>));
    }
    return products;
  }
}