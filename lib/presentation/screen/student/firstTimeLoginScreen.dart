// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostelapplication/presentation/screen/student/roomchecklist.dart';

class FirstTimeLoginForm extends StatefulWidget {
  // final String userId;

  const FirstTimeLoginForm({super.key});

  @override
  _FirstTimeLoginFormState createState() => _FirstTimeLoginFormState();
}

class _FirstTimeLoginFormState extends State<FirstTimeLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _coachingNameController = TextEditingController();
  final TextEditingController _fatherNumberController = TextEditingController();
  final TextEditingController _fatherWhatsappNumberController =
      TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _motherWhatsappNumberController =
      TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _electricityMeterReadingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkClassField();
    // _checkUserData();
    // Populate existing user details
    // _populateExistingUserDetails();
  }

  void _checkClassField() async {
    // Retrieve UID from Firebase
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Retrieve user document from Firestore
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(uid).get();

    if (userSnapshot.exists && userSnapshot.data()!['Class'] != null) {
      // "Class" field is available, navigate to student dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoomChecklistScreen(),
        ),
      );
    }
  }

  // void _checkUserData() async {
  //   // Retrieve UID from Firebase
  //   String uid = FirebaseAuth.instance.currentUser!.uid;
  //   // Retrieve user document from Firestore
  //   DocumentSnapshot<Map<String, dynamic>> userSnapshot =
  //       await FirebaseFirestore.instance.collection('User').doc(uid).get();

  //   if (userSnapshot.exists) {
  //     // User data already exists, navigate to dashboard
  //     Navigator.pushReplacementNamed(
  //       context,
  //       '/studentDashboard',
  //     );
  //   }
  // }

  // void _populateExistingUserDetails() async {
  //   // Retrieve existing user details from Firestore
  //   String uid = FirebaseAuth.instance.currentUser!.uid;
  //   DocumentSnapshot userSnapshot =
  //       await FirebaseFirestore.instance.collection('User').doc(uid).get();

  //   if (userSnapshot.exists) {
  //     setState(() {
  //       // Assign existing user details to corresponding TextEditingController
  //       _classController.text = userSnapshot['Class'] ?? '';
  //       _coachingNameController.text = userSnapshot['Coaching Name'] ?? '';
  //       _fatherNumberController.text = userSnapshot['Father Number'] ?? '';
  //       _fatherWhatsappNumberController.text =
  //           userSnapshot['Father Whatsapp Number'] ?? '';
  //       _motherNameController.text = userSnapshot['Mother Name'] ?? '';
  //       _motherWhatsappNumberController.text =
  //           userSnapshot['Mother Whatsapp Number'] ?? '';
  //       _aadharNumberController.text = userSnapshot['Adhaar Number'] ?? '';
  //       _homeAddressController.text = userSnapshot['Home Address'] ?? '';
  //       _cityController.text = userSnapshot['City'] ?? '';
  //       _stateController.text = userSnapshot['State'] ?? '';
  //       _dobController.text = userSnapshot['DOB'] ?? '';
  //       _electricityMeterReadingController.text =
  //           userSnapshot['Electricity Meter Reading at Start'] ?? '';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'Registration Form',
            style: TextStyle(
              fontFamily: 'Mazzard',
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Welcome to H House!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Please fill in the following details to complete your registration.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'Class',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your class';
                  }
                  return null;
                },
              ),
              // Add more TextFormField widgets for other fields
              // such as Coaching Name, Father Number, etc.
              // Add more TextFormField widgets for other fields
              TextFormField(
                controller: _coachingNameController,
                decoration: const InputDecoration(labelText: 'Coaching Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the coaching name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fatherNumberController,
                // keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Father Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter father\'s number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fatherWhatsappNumberController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Father Whatsapp Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter father\'s Whatsapp number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(labelText: 'Mother Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter mother\'s name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _motherWhatsappNumberController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Mother Whatsapp Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter mother\'s Whatsapp number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _aadharNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Aadhar Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter Aadhar number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _homeAddressController,
                decoration: const InputDecoration(labelText: 'Home Address'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter home address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter date of birth';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _electricityMeterReadingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Electricity Meter Reading at Start'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter electricity meter reading';
                  }
                  return null;
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    // Retrieve UID from Firebase
                    String uid = FirebaseAuth.instance.currentUser!.uid;

                    // Get the existing user data from Firestore
                    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
                        await FirebaseFirestore.instance
                            .collection('User')
                            .doc(uid)
                            .get();

                    // Combine existing data with new data
                    Map<String, dynamic> userData = {
                      ...userSnapshot.data() ?? {}, // Existing data
                      // Existing data
                      'Class': _classController.text,
                      'Coaching Name': _coachingNameController.text,
                      'Father Number': _fatherNumberController.text,
                      'Father Whatsapp Number':
                          _fatherWhatsappNumberController.text,
                      'Mother Name': _motherNameController.text,
                      'Mother Whatsapp Number':
                          _motherWhatsappNumberController.text,
                      'Adhaar Number': _aadharNumberController.text,
                      'Home Address': _homeAddressController.text,
                      'City': _cityController.text,
                      'State': _stateController.text,
                      'DOB': _dobController.text,
                      'Electricity Meter Reading at Start':
                          _electricityMeterReadingController.text,
                    };

                    // Save the combined data back to Firestore
                    FirebaseFirestore.instance
                        .collection('User')
                        .doc(uid)
                        .set(userData)
                        .then((value) {
                      // Data saved successfully
                      // You can navigate to another screen or show a success message
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomChecklistScreen(),
                        ),
                      );
                    }).catchError((error) {
                      // Handle errors here
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontFamily: 'Mazzard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
