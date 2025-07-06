class Product {
  String id;
  String price;
  String title;
  String description;
  String? image;

  Product(this.id, this.price, this.title, this.description);
  static Product fromMap(Map<String,dynamic> map){
    Product p=Product(map['id'], map['price'], map['title'], map['description']);
    p.image=map['image'];
    return p;
  }
  Map<String,dynamic> toMap (){
    return{
      'id': id,
      'image': image,
      'price': price,
      'title': title,
      'description': description,
    };
  }
}
