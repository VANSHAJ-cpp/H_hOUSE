import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hostelapplication/presentation/screen/student/Menu%20Display/Menu.dart';
import 'package:hostelapplication/presentation/screen/student/notice/StudentNoticeScreen.dart';
import 'package:hostelapplication/presentation/screen/student/complains/studentcomplainscreen.dart';
import 'package:hostelapplication/presentation/screen/student/payment/studentPaymentSubmission.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const StudentHome(),
    const StudentComplainScreen(),
    const FoodMenuScreen(),
    const StudentPaymentSubmissionScreen(),
    PaymentHistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> checkPaymentHistory(String uid) async {
    try {
      // Query the 'transactions' subcollection for the current user's document
      var querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .doc(uid)
          .collection('transactions')
          .limit(1) // Limit to 1 document to minimize reads
          .get();

      // Check if any documents were found
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors
      print('Error checking payment history: $e');
      return false; // Return false in case of any error
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Use WillPopScope to intercept the back button press
      onWillPop: () async {
        // Pop all routes until reaching the home screen
        Navigator.popUntil(context, ModalRoute.withName('/'));
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        body: SafeArea(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
          ]),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: FutureBuilder(
                future:
                    checkPaymentHistory(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  bool hasPaymentHistory = snapshot.data as bool;
                  return GNav(
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 24,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.blue, // Changed to blue
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
                        icon: Icons.food_bank,
                        text: 'Food',
                      ),
                      GButton(
                        icon: Icons.payment_outlined, // Payment icon
                        text: 'Payment', // Payment label
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) async {
                      if (index != 3) {
                        // If index is not for payment, change selected index
                        _onItemTapped(index);
                      } else {
                        // If index is for payment, check payment history
                        if (hasPaymentHistory) {
                          _onItemTapped(4);
                          // If the user has payment history, navigate to PaymentHistoryScreen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => PaymentHistoryScreen()),
                          // );
                        } else {
                          _onItemTapped(3);

                          // If the user has no payment history, navigate to PaymentForm
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) =>
                          //           const StudentPaymentSubmissionScreen()),
                          // );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
