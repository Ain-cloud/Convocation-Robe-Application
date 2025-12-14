import 'package:flutter/material.dart';
import 'adminDashboard.dart';
import 'adminBooking.dart';
import 'adminInventory.dart';
import 'adminReport.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => AdminMainState();
}

class AdminMainState extends State<AdminMain> {
  int _currentIndex = 0;

  // Screen List for Lazy Loading
  final List<Widget> _screens = [
    const AdminDashboard(),
    const AdminBooking(),
    const AdminInventory(),
    const AdminReport(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFF4C4DDC),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Dashboard
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), // Booking
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), // Inventory
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_outlined), // Reports
            label: 'Report',
          ),
        ],
      ),
    );
  }
}
