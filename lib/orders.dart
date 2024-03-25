import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/cartPizza.dart';

class Orders extends StatefulWidget {
  State<StatefulWidget> createState() => OrderState();
}

class OrderState extends State<Orders> {
  DatabaseReference orderRef = FirebaseDatabase.instance.ref('orders');
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = "";
  List<CartPizza> orderPizzas = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      userId = _auth.currentUser!.uid.toString();
      DataSnapshot pizzaSnapshot =
          await orderRef.child(userId).child('pizzas').get();
      for (DataSnapshot pizza in pizzaSnapshot.children) {
        CartPizza orderPizza = CartPizza.fromSnapshot(pizza);
        orderPizzas.add(orderPizza);
      }
      setState(() {});
    } catch (error) {
      _showSnackBar("Failed fetching Orders!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Orders",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: orderPizzas.isEmpty
          ? Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.0),
              itemCount: orderPizzas.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 16.0);
              },
              itemBuilder: (BuildContext context, int index) {
                final orderPizza = orderPizzas[index];
                return Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80.0,
                        height: 80.0,
                        child: Image.network(
                          orderPizza.pImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderPizza.pName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Price: \$${orderPizza.pPrice}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        'Quantity: ${orderPizza.pQuantity}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
