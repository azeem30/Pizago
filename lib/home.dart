import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bottom.dart';
import 'package:flutter_app/cart.dart';
import 'package:flutter_app/detail.dart';
import 'package:flutter_app/orders.dart';
import 'package:flutter_app/pizza.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_app/profile.dart';

class Home extends StatefulWidget {
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  int _currentIndex = 0;
  String _sortOption = 'Price: Low to High'; // Default sort option

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void goToOrders() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Orders()));
  }

  List<Pizza> pizzas = [];
  final menuRef = FirebaseDatabase.instance.ref('menu');
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DataSnapshot snapshot = await menuRef.get();
    Iterable<DataSnapshot> children = snapshot.children;
    for (DataSnapshot child in children) {
      pizzas.add(Pizza.fromSnapshot(child));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag),
            onPressed: goToOrders,
            color: Colors.white,
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationMenu(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
      backgroundColor: Color(0xffccb80e),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Price: Low to High'),
                onTap: () {
                  setState(() {
                    _sortOption = 'Price: Low to High';
                    _sortPizzas(true);
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: Text('Price: High to Low'),
                onTap: () {
                  setState(() {
                    _sortOption = 'Price: High to Low';
                    _sortPizzas(false);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortPizzas(bool ascending) {
    pizzas.sort((a, b) {
      if (ascending) {
        return a.pPrice.compareTo(b.pPrice);
      } else {
        return b.pPrice.compareTo(a.pPrice);
      }
    });
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return Column(
          children: [
            Container(color: Colors.black, child: _buildCarousel()),
            Container(
              width: double.infinity,
              height: 3,
              color: Colors.black,
            ),
            Expanded(child: _buildGridView())
          ],
        );
      case 1:
        return Profile();
      case 2:
        return Cart();
      default:
        return Container();
    }
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      children: pizzas.map((pizza) => _buildPizzaCard(pizza)).toList(),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider.builder(
      itemCount: pizzas.length,
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        Pizza pizza = pizzas[index];
        return GestureDetector(
          onTap: () {
            viewPizza(pizza);
          },
          child: Container(
            width: 400,
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                pizza.pImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPizzaCard(Pizza pizza) {
    return GestureDetector(
      onTap: () {
        viewPizza(pizza);
      },
      child: Card(
        color: Colors.black,
        margin: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
                child: Image.network(
                  pizza.pImage,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pizza.pName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '\$${pizza.pPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void viewPizza(Pizza pizza) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Detail(pizza: pizza)));
  }
}
