import 'package:flutter/material.dart';
import 'graduand_home_screen.dart';
import 'graduand_booking_screen.dart';
import 'graduand_payment_screen.dart';
import 'graduand_profile_screen.dart';

// Main App Screen with BottomNavigationBar
class GraduandMainScreen extends StatefulWidget {
  const GraduandMainScreen({super.key});

  @override
  State<GraduandMainScreen> createState() => _GraduandMainScreenState();
}

class _GraduandMainScreenState extends State<GraduandMainScreen> {
  int _currentIndex = 0;

  // Define the screens for the BottomNavigationBar
  final List<Widget> _screens = [
    GraduandHomeScreen(),
    GraduandBookingScreen(),
    GraduandPaymentScreen(),
    GraduandProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Show the selected screen
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
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
