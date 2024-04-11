import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostelapplication/presentation/screen/admin/adminDashbord.dart';
import 'package:hostelapplication/presentation/screen/student/studentDashbord.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onBordingScreen.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class SplashScreen1 extends StatefulWidget {
  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  int loginNum = 0;
  var emailAddress;
  @override
  void initState() {
    super.initState();
    checkUserType();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => loginNum == 1
              ? const AdminDashbordScreen()
              : loginNum == 2
                  ? const StudentDashboardScreen()
                  : const OnboardingScreen(),
        ),
      ),
    );
  }

  checkUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAdminLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;

    if (isAdminLoggedIn) {
      setState(() {
        loginNum = 1; // Admin user is already logged in
      });
    } else {
      var auth = FirebaseAuth.instance;
      auth.authStateChanges().listen((user) {
        if (user != null) {
          user = auth.currentUser;
          emailAddress = user!.email;
          if (emailAddress == 'admin@gmail.com') {
            if (this.mounted) {
              setState(() {
                loginNum = 1; // Set loginNum to 1 for admin user
              });
              // Save admin login state to shared preferences
              prefs.setBool('isAdminLoggedIn', true);
            }
          } else {
            // Check if the user has completed the registration form
            FirebaseFirestore.instance
                .collection('User')
                .doc(user.uid)
                .get()
                .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.exists && snapshot.data()!['Class'] != null) {
                // User has completed the registration form
                setState(() {
                  loginNum = 2; // Set loginNum to 2 for student user
                });
              } else {
                // User has not completed the registration form
                setState(() {
                  loginNum = 4; // Set loginNum to 4 for first-time login
                });
              }
            });
          }
        } else {
          if (this.mounted) {
            setState(() {
              loginNum = 3; // Set loginNum to 3 for guest user
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo1.png',
              height: 250,
              width: 250,
            ),
            const SizedBox(
              height: 150,
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
