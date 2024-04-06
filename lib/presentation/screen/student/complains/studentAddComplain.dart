import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hostelapplication/presentation/screen/student/complains/studentcomplainscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StudentAddComplaintScreen extends StatefulWidget {
  final String complainTitle;
  final String studentId;

  const StudentAddComplaintScreen(this.complainTitle, this.studentId,
      {Key? key})
      : super(key: key);

  @override
  _StudentAddComplaintScreenState createState() =>
      _StudentAddComplaintScreenState();
}

class _StudentAddComplaintScreenState extends State<StudentAddComplaintScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _selectedComplaintType;
  late String _complaintDescription;
  late String _userName;
  late String _roomNo;
  late File? _image = null;

  Future<DocumentSnapshot> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection('User')
        .doc(user?.uid)
        .get();
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    final fileName = 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('complaints_images')
        .child(fileName);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.black,
        hintColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Add Complaint",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mazzard',
                fontSize: 22),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    final userData = snapshot.data!;
                    _userName =
                        userData['FirstName'] + ' ' + userData['Lastname'];
                    _roomNo = userData['RoomNo'];
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Complaint Details',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: $_userName',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Room No.: $_roomNo',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Date: ${DateTime.now().toString().split(' ')[0]}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'Complaint Type',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Dropdown for complaint type
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Type',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedComplaintType,
                        items: <String>[
                          'Electricity',
                          'Water',
                          'Internet',
                          'Room Condition',
                          'Others',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedComplaintType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'Complaint Description',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Multiline text field for complaint description
                      TextFormField(
                        onChanged: (value) => _complaintDescription = value,
                        decoration: InputDecoration(
                          hintText: 'Type your complaint here...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5, // Reduced the number of lines
                        keyboardType: TextInputType.multiline,
                        maxLength: 1000,
                      ),
                      const SizedBox(height: 20),
                      // Button to attach image
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _getImage(ImageSource.camera),
                            icon: Icon(Icons.camera_alt),
                            label: Text('Take Photo'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _getImage(ImageSource.gallery),
                            icon: Icon(Icons.image),
                            label: Text(' Gallery'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Display selected image
                      _image != null
                          ? Image.file(_image!)
                          : SizedBox(), // Show nothing if no image is selected
                      const SizedBox(height: 20),
                      // Button to submit complaint
                      // Button to submit complaint
                      // Button to submit complaint
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Show CircularProgressIndicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            // Generate a unique complaint ID
                            final complaintId = FirebaseFirestore.instance
                                .collection('StudentComplaint')
                                .doc()
                                .id;

                            // Upload image
                            String imageUrl = '';
                            if (_image != null) {
                              imageUrl = await _uploadImage(_image!);
                            }

                            // Save complaint
                            final user = FirebaseAuth.instance.currentUser;
                            await FirebaseFirestore.instance
                                .collection('StudentComplaint')
                                .doc(
                                    complaintId) // Use the generated complaint ID
                                .set({
                              'complaintId':
                                  complaintId, // Add complaint ID to the document
                              'complaintTitle': widget.complainTitle,
                              'studentId': widget.studentId,
                              'complaintType': _selectedComplaintType,
                              'complaintDescription': _complaintDescription,
                              'userName': _userName,
                              'roomNo': _roomNo,
                              'userUid': user?.uid, // Store user UID
                              'imageUrl': imageUrl, // Store image URL
                              'timestamp': FieldValue.serverTimestamp(),
                              'status': 'Pending', // Initial status
                            });

                            // Reset form fields
                            _formKey.currentState!.reset();

                            // Close the CircularProgressIndicator dialog
                            Navigator.pop(context);

                            // Show SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Complaint added successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Navigate back to complaint screen after a delay
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StudentComplainScreen()),
                              );
                            });
                          }
                        },
                        child: Text('Submit Complaint'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
