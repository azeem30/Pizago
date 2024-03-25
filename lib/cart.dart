import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/cartPizza.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Cart extends StatefulWidget {
  State<StatefulWidget> createState() => CartState();
}

class CartState extends State<Cart> {
  DatabaseReference cart = FirebaseDatabase.instance.ref('cart');
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = "";
  List<CartPizza> cartPizzas = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCart();
  }

  Future<LocationPermission> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission;
  }

  void showLocationRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Required"),
        content: Text(
            "This feature requires access to your location. Please grant permission."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              LocationPermission permission =
                  await Geolocator.requestPermission();
              // Handle the new permission status (granted or denied again)
              Navigator.pop(context);
            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }

  Future<String> getPositionOfUser() async {
    LocationPermission permission = await checkLocationPermission();
    String userAddress = "";
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        userAddress =
            '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.postalCode}, ${placemarks.first.country}';
      } else {
        showLocationRequestDialog();
      }
    }
    return userAddress;
  }

  Future<void> orderPizzas() async {
    try {
      if (cartPizzas.length != 0) {
        userId = _auth.currentUser!.uid.toString();
        DatabaseReference orderRef = FirebaseDatabase.instance
            .ref('orders')
            .child(userId)
            .child('pizzas');
        DatabaseReference userRef = FirebaseDatabase.instance
            .ref('orders')
            .child(userId)
            .child('details');
        String userAddress = await getPositionOfUser();
        for (CartPizza pizza in cartPizzas) {
          orderRef.push().set(pizza.toJson());
        }
        userRef.child('address').set(userAddress);
        userRef.child('totalPrice').set(totalPrice);
        _showSnackBar("Order place Successfully!");
      }
    } catch (error) {
      print("$error");

      _showSnackBar("Error ordering, $error");
    } finally {
      cart.child(userId).remove();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  Future<void> fetchCart() async {
    try {
      userId = _auth.currentUser!.uid.toString();
      DataSnapshot snapshot = await cart.child(userId).get();
      for (DataSnapshot child in snapshot.children) {
        CartPizza cartPizza = CartPizza.fromSnapshot(child);
        cartPizzas.add(cartPizza);
      }
      setState(() {});
    } catch (error) {
      _showSnackBar("Failed to fetch Cart items");
    }
  }

  Future<void> updateCart() async {
    try {
      userId = _auth.currentUser!.uid.toString();
      await cart
          .child(userId)
          .set(cartPizzas.map((pizza) => pizza.toJson()).toList());
      _showSnackBar("Cart updated successfully");
    } catch (error) {
      _showSnackBar("Failed to update Cart");
    }
  }

  @override
  Widget build(BuildContext context) {
    totalPrice = cartPizzas.fold(0, (total, pizza) => total + pizza.pPrice);

    return Container(
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Expanded(
              child: cartPizzas.isEmpty
                  ? Center(
                      child: Text('Your cart is empty!',
                          style: TextStyle(color: Colors.white)),
                    )
                  : ListView.builder(
                      itemCount: cartPizzas.length,
                      itemBuilder: (BuildContext context, int index) {
                        CartPizza pizza = cartPizzas[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              color: Colors.yellow,
                              child: ListTile(
                                leading: Image.network(
                                  pizza.pImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(pizza.pName),
                                subtitle: Text('Quantity: ${pizza.pQuantity}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${pizza.pPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          cartPizzas.removeAt(index);
                                          updateCart();
                                        });
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              color: Colors.black,
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total Price',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.yellow,
              height: 50.0,
              width: double.infinity,
              child: TextButton(
                onPressed: orderPizzas,
                child: Text(
                  'Order Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
