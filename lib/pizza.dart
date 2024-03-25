import "package:firebase_database/firebase_database.dart";

class Pizza {
  String pImage;
  String pName;
  double pPrice;

  Pizza({
    required this.pImage,
    required this.pName,
    required this.pPrice,
  });

  factory Pizza.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> json = snapshot.value as Map<dynamic, dynamic>;
    return Pizza(
      pImage: json['pImage'],
      pName: json['pName'],
      pPrice: json['pPrice'].toDouble(),
    );
  }
}
