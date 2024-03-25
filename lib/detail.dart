import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:flutter_app/pizza.dart';

class Detail extends StatefulWidget {
  final Pizza pizza;
  const Detail({required this.pizza});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  int _quantity = 1;
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid.toString();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pizza Details'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.network(
              widget.pizza.pImage,
              width: double.infinity,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              widget.pizza.pName,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              '\$${widget.pizza.pPrice.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text(
                  '$_quantity',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addToCart,
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart() async {
    try {
      DatabaseReference cartRef =
          FirebaseDatabase.instance.ref('cart').child(userId);

      String cartItemId = cartRef.push().key.toString();
      Map<String, dynamic> cartItemData = {
        'pName': widget.pizza.pName,
        'pImage': widget.pizza.pImage,
        'pPrice': widget.pizza.pPrice * _quantity,
        'pQuantity': _quantity,
      };
      await cartRef.child(cartItemId).set(cartItemData);
      _showSnackBar("Added to Cart");
    } catch (error) {
      _showSnackBar("Failed to Add to Cart");
    }
  }
}
