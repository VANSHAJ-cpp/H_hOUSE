import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class StudentPaymentSubmissionScreen extends StatefulWidget {
  const StudentPaymentSubmissionScreen({Key? key}) : super(key: key);

  @override
  _StudentPaymentSubmissionScreenState createState() =>
      _StudentPaymentSubmissionScreenState();
}

class _StudentPaymentSubmissionScreenState
    extends State<StudentPaymentSubmissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Submission'),
      ),
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
  final picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _studentIDController = TextEditingController();
  TextEditingController _transactionDetailsController = TextEditingController();

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
        title: Text('Submit Payment'),
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
                      margin: EdgeInsets.only(bottom: 20),
                    )
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.attach_file,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      margin: EdgeInsets.only(bottom: 20),
                    ),
              ElevatedButton.icon(
                onPressed: getImage,
                icon: Icon(Icons.attach_file),
                label: Text('Attach Screenshot'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _studentIDController,
                decoration: InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _transactionDetailsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Transaction Details',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
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

                  // Extract payment details from controllers
                  String name = _nameController.text;
                  String studentID = _studentIDController.text;
                  String transactionDetails =
                      _transactionDetailsController.text;

                  // Upload image to Firebase Storage
                  String imageUrl = '';
                  if (_image != null) {
                    firebase_storage.Reference ref = firebase_storage
                        .FirebaseStorage.instance
                        .ref()
                        .child('payment_images')
                        .child(
                            DateTime.now().millisecondsSinceEpoch.toString());
                    await ref.putFile(_image!);
                    imageUrl = await ref.getDownloadURL();
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
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  // Hide CircularProgressIndicator
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
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
                child: Text('Submit'),
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
        title: Text('Payment History'),
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No payment history available.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var payment = snapshot.data!.docs[index];
              return ListTile(
                title: Text('Transaction ID: ${payment.id}'),
                subtitle: Text('Date: ${payment['timestamp'].toDate()}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: ThemeData(
                          brightness: Brightness.dark,
                        ),
                        child: AlertDialog(
                          title: Text(
                            'Payment Details',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${payment['name']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Student ID: ${payment['studentID']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Transaction Details: ${payment['transactionDetails']}',
                                  style: TextStyle(color: Colors.white),
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
                              child: Text('Close',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentForm()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
