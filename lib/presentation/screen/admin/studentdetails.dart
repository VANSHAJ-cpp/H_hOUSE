import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String getFieldValue(Map<String, dynamic> data, String field) {
  return data.containsKey(field) ? data[field] as String : '';
}

class StudentDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Registered Students',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No data available'),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: snapshot.data!.docs.map((student) {
                  return StudentCard(
                    userId: student.id,
                    firstName: getFieldValue(student.data(), 'FirstName'),
                    lastName: getFieldValue(student.data(), 'Lastname'),
                    roomNo: getFieldValue(student.data(), 'RoomNo'),
                    fatherName: getFieldValue(student.data(), 'Father Number'),
                    motherName: getFieldValue(student.data(), 'Mother Name'),
                    fatherNumber:
                        getFieldValue(student.data(), 'Father Whatsapp Number'),
                    motherNumber:
                        getFieldValue(student.data(), 'Mother Whatsapp Number'),
                    userImage: getFieldValue(student.data(), 'UserImage'),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

class StudentCard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String roomNo;
  final String fatherName;
  final String motherName;
  final String fatherNumber;
  final String motherNumber;
  final String userImage;
  final String userId;

  StudentCard({
    required this.firstName,
    required this.lastName,
    required this.roomNo,
    required this.fatherName,
    required this.motherName,
    required this.fatherNumber,
    required this.motherNumber,
    required this.userImage,
    required this.userId,
  });

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  late TextEditingController _duesController;
  bool _showTextField = false;

  @override
  void initState() {
    super.initState();
    _duesController = TextEditingController();
  }

  @override
  void dispose() {
    _duesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.black,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.userImage),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.firstName} ${widget.lastName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Room No: ${widget.roomNo}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _showTextField
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _duesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter Dues Amount',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showTextField = false;
                          });
                          _addDues();
                        },
                        child: Text('Tick'),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTextField = true;
                      });
                    },
                    child: Text('Add Dues'),
                  ),
          ],
        ),
      ),
    );
  }

  void _addDues() {
    if (_duesController.text.isNotEmpty) {
      int amount = int.parse(_duesController.text);
      // Perform Firestore update and add dues functionality here
      FirebaseFirestore.instance.collection('User').doc(widget.userId).update({
        'dues': FieldValue.increment(amount),
      });
      // Clear the text field
      _duesController.clear();
    }
  }
}
