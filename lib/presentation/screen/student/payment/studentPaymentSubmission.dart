// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class StudentPaymentSubmissionScreen extends StatefulWidget {
  const StudentPaymentSubmissionScreen({super.key});

  @override
  _StudentPaymentSubmissionScreenState createState() =>
      _StudentPaymentSubmissionScreenState();
}

class _StudentPaymentSubmissionScreenState
    extends State<StudentPaymentSubmissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   title: const Text(
      //     'Payment Submission',
      //     style: TextStyle(
      //         color: Colors.white,
      //         fontWeight: FontWeight.bold,
      //         fontFamily: 'Mazzard',
      //         fontSize: 22),
      //   ),
      // ),
      body: PaymentForm(),
    );
  }
}

class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  File? _image;
  String _selectedOption = 'Hostel';
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _transactionDetailsController =
      TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Submit Payment',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mazzard',
              fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _image != null
                  ? Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                    )
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: const Icon(
                        Icons.attach_file,
                        size: 80,
                        color: Color.fromARGB(255, 57, 0, 0),
                      ),
                    ),
              ElevatedButton.icon(
                onPressed: getImage,
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.black)),
                icon: const Icon(
                  Icons.attach_file,
                  color: Colors.white,
                ),
                label: const Text(
                  'Attach Screenshot',
                  style: TextStyle(fontFamily: 'Mazzard', color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                elevation: 5,
                isExpanded: true,
                decoration: InputDecoration(
                  // labelText: 'Paying For:',
                  prefixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(
                      255, 0, 0, 0), // Set background color
                ),
                value: _selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOption = newValue!;
                  });
                },
                items: <String>['Hostel', 'Electricity', 'Mess']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      child: Text(
                        value,
                        style: const TextStyle(
                            fontFamily: 'Mazzard', color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _studentIDController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _transactionDetailsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Transaction Details',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Check if any field is empty
                  if (_nameController.text.isEmpty ||
                      _transactionDetailsController.text.isEmpty ||
                      _image == null) {
                    // Show snackbar with red background and white text
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Please fill in all fields and attach a screenshot.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                    return; // Exit function if any field is empty
                  }

                  // Show CircularProgressIndicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  // Extract payment details from controllers
                  String name = _nameController.text;
                  String studentID = _studentIDController.text;
                  String transactionDetails =
                      _transactionDetailsController.text;

                  // Upload image to Firebase Storage
                  String imageUrl = '';
                  firebase_storage.Reference ref;
                  try {
                    ref = firebase_storage.FirebaseStorage.instance
                        .ref()
                        .child('payment_images')
                        .child(
                            DateTime.now().millisecondsSinceEpoch.toString());
                    await ref.putFile(_image!);
                    imageUrl = await ref.getDownloadURL();
                  } catch (e) {
                    print('Error uploading image: $e');
                  }

                  // Save payment details to Firestore under the current user's UID
                  String uid = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('payments')
                      .doc(uid)
                      .collection('transactions')
                      .add({
                    'name': name,
                    'studentID': studentID,
                    'transactionDetails': transactionDetails,
                    'imageUrl': imageUrl,
                    'status': 'Pending',
                    'option': _selectedOption,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  // Hide CircularProgressIndicator
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment details submitted successfully!'),
                    ),
                  );

                  // Clear input fields and image
                  _nameController.clear();
                  _studentIDController.clear();
                  _transactionDetailsController.clear();
                  setState(() {
                    _image = null;
                  });

                  // Navigate to PaymentHistoryScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentHistoryScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Set button color to black
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Mazzard',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Payment History',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mazzard',
              fontSize: 22),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No payment history available.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var payment = snapshot.data!.docs[index];
              String status = payment['status'] ?? 'Pending';
              String selectedOption = payment['option'] ?? 'Hostel';
              Color statusColor;
              if (status == 'Approve') {
                statusColor = Colors.green;
              } else if (status == 'Deny') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.yellow;
              }
              Icon _getIcon(String selectedOption) {
                switch (selectedOption) {
                  case 'Electricity':
                    return const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 18,
                    );
                  case 'Hostel':
                    return const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 18,
                    );
                  case 'Mess':
                    return const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 18,
                    );
                  default:
                    return const Icon(
                      Icons.tag,
                      color: Colors.white,
                      size: 18,
                    );
                }
              }

              return Card(
                shadowColor: statusColor,
                elevation: 4,
                color: Colors.black,
                child: ListTile(
                  title: Text('Transaction ID: ${payment.id}',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${payment['timestamp'].toDate()}',
                          style: const TextStyle(color: Colors.white)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Status: $status',
                              style: TextStyle(color: statusColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[
                                  800], // Set background color to a darker shade
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(
                                      0.5), // Set shadow color and opacity
                                  spreadRadius: 2, // Set spread radius
                                  blurRadius: 3, // Set blur radius
                                  offset: const Offset(0, 2), // Set offset
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _getIcon(selectedOption),
                                const SizedBox(
                                    width:
                                        7), // Add some spacing between icon and text
                                Text(
                                  selectedOption,
                                  style: const TextStyle(
                                    color:
                                        Colors.white, // Set text color to white
                                    fontWeight:
                                        FontWeight.bold, // Make text bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Text('Status: $status',
                      //     style: TextStyle(color: statusColor)),
                      const SizedBox(height: 10),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Theme(
                          data: ThemeData(
                            brightness: Brightness.dark,
                          ),
                          child: AlertDialog(
                            title: const Text(
                              'Payment Details',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: ${payment['name']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Student ID: ${payment['studentID']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Transaction Details: ${payment['transactionDetails']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (payment['imageUrl'] != null)
                                    Image.network(payment['imageUrl']),
                                ],
                              ),
                            ),
                            backgroundColor: Colors.black,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentForm()),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
