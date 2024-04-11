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

class StudentCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String roomNo;
  final String fatherName;
  final String motherName;
  final String fatherNumber;
  final String motherNumber;
  final String userImage;

  StudentCard({
    required this.firstName,
    required this.lastName,
    required this.roomNo,
    required this.fatherName,
    required this.motherName,
    required this.fatherNumber,
    required this.motherNumber,
    required this.userImage,
  });

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
                    backgroundImage: NetworkImage(userImage),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Room No: $roomNo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildContactGroup(
              'Father',
              fatherName ?? 'Not Registered Yet',
              fatherNumber ?? '',
              const Color.fromARGB(255, 0, 0, 0),
            ),
            _buildContactGroup(
              'Mother',
              motherName ?? 'Not Registered Yet',
              motherNumber ?? '',
              const Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactGroup(
      String title, String name, String number, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            title: Text(name),
            subtitle: number.isNotEmpty
                ? Text(number)
                : Text(
                    'Not Registered Yet',
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StudentDetailsScreen(),
  ));
}
