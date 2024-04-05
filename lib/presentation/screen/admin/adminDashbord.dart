import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hostelapplication/presentation/screen/admin/adminPaymentCheckScreen.dart';
import 'package:hostelapplication/presentation/screen/admin/leave/AdminLeave.dart';
import 'package:hostelapplication/presentation/screen/admin/service/AdminServices.dart';
import 'package:hostelapplication/presentation/screen/admin/complaint/AdmincomplaintScreen.dart';
import 'package:hostelapplication/presentation/screen/admin/notice/adminNotice.dart';

class AdminDashbordScreen extends StatefulWidget {
  const AdminDashbordScreen({super.key});

  @override
  State<AdminDashbordScreen> createState() => _AdminDashbordScreenState();
}

class _AdminDashbordScreenState extends State<AdminDashbordScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    AdminHome(),
    AdminComplaintScreen(),
    MenuScreen(),
    AdminPaymentCheckScreen(), // Added AdminPaymentCheckScreen
  ];

  // Add a Timer variable to hold the timer reference
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initialize the timer in initState
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Your timer callback logic here
    });
  }

  @override
  void dispose() {
    // Cancel the timer in dispose to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.blue,
              tabs: const [
                GButton(
                  icon: Icons.home_outlined,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.description_outlined,
                  textSize: 5,
                  text: 'Report',
                ),
                GButton(
                  icon: Icons.menu,
                  text: 'Menu',
                ),
                GButton(
                  icon: Icons.payment_outlined, // Icon for payment check
                  text: 'Payments', // Text for payment check
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
