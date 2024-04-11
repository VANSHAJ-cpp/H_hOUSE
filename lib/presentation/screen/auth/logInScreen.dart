import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hostelapplication/core/constant/string.dart';
import 'package:hostelapplication/core/constant/textController.dart';
import 'package:hostelapplication/presentation/screen/auth/loading_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool showPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Updated background color
      body: WillPopScope(
        onWillPop: () async {
          // Navigate to onboarding screen when back button is pressed
          Navigator.pushReplacementNamed(context, onboardingScreen);
          return true;
        },
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo1.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'H House',
                      style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcomes You',
                      style: GoogleFonts.breeSerif(
                        fontSize: 30,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 169, 0, 0),
                        ),
                        children: [
                          TextSpan(text: 'Student should do '),
                          TextSpan(
                            text: 'Google SignIn',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: _signInWithGoogle,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white, // Updated button color
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/images/google_logo.svg',
                                width: 20, height: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.email, color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ), // Updated border color and width
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0), // Added padding
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                        suffixIcon: IconButton(
                          icon: Icon(showPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ), // Updated border color and width
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0), // Added padding
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Check if email and password match the credentials
                        if (emailController.text == 'admin@gmail.com' &&
                            passwordController.text == 'admin@1234') {
                          // Navigate to admin dashboard
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isAdminLoggedIn', true);

                          Navigator.pushReplacementNamed(
                              context, '/adminDashbordScreenRoute');
                        } else {
                          // Show alert for invalid credentials
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Invalid Credentials'),
                              content: const Text(
                                  'Please enter valid email and password.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Discover the best hostel services with H House.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Get the user's email from Google sign-in
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        final userEmail = googleUser?.email;

        // Check if the email exists in Firestore
        final bool emailExistsInFirestore =
            await checkEmailExistsInFirestore(userEmail);

        if (emailExistsInFirestore) {
          // Proceed with sign-in
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          final User? user = userCredential.user;
          if (user != null) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/firstTimeLoginForm',
              (route) => false,
            );

            setState(() {
              _isLoading = false; // Hide loading indicator
            });
          }
        } else {
          // Email not registered, sign out and show alert
          await googleSignIn.signOut();
          setState(() {
            _isLoading = false; // Hide loading indicator in case of error
          });
          alertBox(context,
              'Please contact the house owner to register your email.');
        }
      }
    } catch (error) {
      print(error.toString());
      alertBox(context, 'An error occurred. Please try again later.');
    }
  }

  Future<bool> checkEmailExistsInFirestore(String? email) async {
    // Check if the email exists in Firestore
    try {
      if (email != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .where('Email', isEqualTo: email)
            .get();
        return userSnapshot.docs.isNotEmpty;
      } else {
        return false;
      }
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  Future<bool> checkUserExists(String? email) async {
    // Assuming you are using Firestore as your database
    try {
      if (email != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .where('Email', isEqualTo: email)
            .get();
        return userSnapshot.docs.isNotEmpty;
      } else {
        return false;
      }
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  Future<void> alertBox(BuildContext context, String message) {
    return Alert(
      context: context,
      title: "",
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ALERT",
              style: TextStyle(
                fontFamily: 'Mazzard',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Mazzard',
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Mazzard',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      closeFunction: () => Navigator.pop(context),
      style: AlertStyle(
        backgroundColor: Colors.transparent,
        overlayColor: Colors.black.withOpacity(0.5),
        isCloseButton: false,
        isOverlayTapDismiss: false,
      ),
    ).show();
  }
}
