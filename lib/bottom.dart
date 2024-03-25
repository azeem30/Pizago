import 'package:flutter/material.dart';

class BottomNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavigationMenu({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.black, // Set the background color to black
      selectedItemColor: Colors.yellow, // Set the color of the selected item
      unselectedItemColor: Colors.white, // Set the color of unselected items
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        )
      ],
    );
  }
}
