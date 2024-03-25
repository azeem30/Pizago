import 'package:firebase_database/firebase_database.dart';

class CartPizza {
  String pImage;
  String pName;
  double pQuantity;
  double pPrice;

  CartPizza(
      {required this.pImage,
      required this.pName,
      required this.pPrice,
      required this.pQuantity});

  factory CartPizza.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> json = snapshot.value as Map<dynamic, dynamic>;
    return CartPizza(
        pImage: json['pImage'],
        pName: json['pName'],
        pPrice: json['pPrice'].toDouble(),
        pQuantity: json['pQuantity'].toDouble());
  }

  Map<String, dynamic> toJson() {
    return {
      'pImage': pImage,
      'pName': pName,
      'pPrice': pPrice,
      'pQuantity': pQuantity,
    };
  }
}
