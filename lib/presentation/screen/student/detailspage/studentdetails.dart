import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({Key? key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late File imageFile;
  PlatformFile? pickedFile;
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text(
          "Details",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mazzard'),
        ),
        actions: [
          pickedFile != null
              ? GestureDetector(
                  onTap: () async {
                    setState(() {
                      showLoading = true;
                    });
                    progressIndicator(context, showLoading = true);

                    // Uploading image file to Firebase Storage
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('profileImg')
                        .child(pickedFile!.name.toString());
                    await ref.putFile(imageFile);
                    String url = await ref.getDownloadURL();

                    // Update user details in Firestore
                    updateUserDetails(url);

                    setState(() {
                      showLoading = false;
                      pickedFile = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 28.0),
                    child: Center(
                        child: Text("Save",
                            style:
                                TextStyle(fontSize: 17, color: Colors.white))),
                  ))
              : const SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: fetchUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.hasData) {
                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return buildUserDetails(userData);
                } else {
                  return const Text('No data available');
                }
              }
            }
          },
        ),
      ),
    );
  }

  Future<DocumentSnapshot> fetchUserDetails() async {
    // Fetch user details from Firestore directly
    User? user = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection('User')
        .doc(user!.uid)
        .get();
  }

  Widget buildUserDetails(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        backgroundImage: pickedFile != null
                            ? FileImage((File("${pickedFile!.path}")))
                            : NetworkImage(userData['UserImage'])
                                as ImageProvider,
                        radius: 70,
                      ),
                    ),
                    Positioned(
                      right: 3,
                      top: 110,
                      child: buildCircle(
                          all: 8,
                          child: GestureDetector(
                            onTap: () {
                              showImageSourceDialog(); // Update this line
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue.shade900,
                              size: 20,
                            ),
                          )),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${userData['FirstName'] ?? ''} ${userData['Lastname'] ?? ''}',
                style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black),
              const SizedBox(height: 20),
              buildDetailRow('Room No', userData['RoomNo']),
              buildDetailRow('Email', userData['Email']),
              buildDetailRow('Mobile No', userData['MobileNo']),
              buildDetailRow('Adhaar Number', userData['Adhaar Number']),
              buildDetailRow('Class', userData['Class']),
              buildDetailRow('Coaching Name', userData['Coaching Name']),
              buildDetailRow('DOB', userData['DOB']),
              buildDetailRow('Electricity Meter Reading',
                  userData['Electricity Meter Reading at Start']),
              buildDetailRow('Father Name', userData['Father Number']),
              buildDetailRow(
                  'Father Whatsapp Number', userData['Father Whatsapp Number']),
              buildDetailRow('Mother Name', userData['Mother Name']),
              buildDetailRow(
                  'Mother Whatsapp Number', userData['Mother Whatsapp Number']),
              buildDetailRow('Home Address', userData['Home Address']),
              buildDetailRow('City', userData['City']),
              buildDetailRow('State', userData['State']),
              buildDetailRow('Date of Joining',
                  '${userData['time']?.toDate().day ?? ''}/${userData['time']?.toDate().month ?? ''}/${userData['time']?.toDate().year ?? ''}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            value ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Future<void> showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: const Text(
            'Select Image Source',
            style:
                TextStyle(fontWeight: FontWeight.bold), // Make title font bold
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set button color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Make button text bold
                        color: Colors.white, // Set button text color
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0), // Add spacing between buttons
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 0, 0, 0), // Set button color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Make button text bold
                        color: Colors.white, // Set button text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        pickedFile = PlatformFile(
          name: pickedImage.path.split('/').last,
          path: pickedImage.path,
          size: File(pickedImage.path).lengthSync(),
        );
      });
    }
  }

  Future<dynamic>? progressIndicator(BuildContext context, showLoading) {
    if (showLoading == true) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
    } else
      return null;
  }

  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
        padding: EdgeInsets.all(all),
        color: Colors.white,
        child: child,
      ));

  Future<void> updateUserDetails(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('User').doc(user!.uid).update({
      'UserImage': imageUrl,
      // Add other fields here as required
    });
  }
}
