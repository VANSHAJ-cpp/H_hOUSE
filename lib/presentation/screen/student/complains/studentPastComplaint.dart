import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPastComplaintsScreen extends StatefulWidget {
  final String userUid;

  const StudentPastComplaintsScreen({Key? key, required this.userUid})
      : super(key: key);

  @override
  _StudentPastComplaintsScreenState createState() =>
      _StudentPastComplaintsScreenState();
}

class _StudentPastComplaintsScreenState
    extends State<StudentPastComplaintsScreen> {
  late Stream<QuerySnapshot> _complaintsStream;

  @override
  void initState() {
    super.initState();
    _complaintsStream = FirebaseFirestore.instance
        .collection('StudentComplaint')
        .where('userUid', isEqualTo: widget.userUid)
        .snapshots();
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending;
      case 'Approved':
        return Icons.check_circle_outline;
      case 'Denied':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color.fromARGB(255, 171, 157, 3); // Yellow
      case 'Approved':
        return const Color.fromARGB(255, 7, 181, 16); // Light green
      case 'Denied':
        return const Color.fromARGB(255, 215, 4, 4); // Light red
      default:
        return const Color(0xFFFFFFFF); // Pure white
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Pending';
      case 'Approved':
        return 'Approved';
      case 'Denied':
        return 'Denied';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Past Complaints',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Mazzard',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _complaintsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                color: const Color.fromARGB(255, 255, 255, 255),
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: getStatusColor(data['status']),
                    width: 4,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    data['complaintTitle'],
                    style: const TextStyle(
                      fontFamily: 'Mazzard',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['complaintDescription'],
                              style: const TextStyle(
                                fontFamily: 'Mazzard',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            if (data['imageUrl'] != null)
                              const SizedBox(height: 8),
                            if (data['imageUrl'] != null)
                              ElevatedButton(
                                onPressed: () async {
                                  String imageUrl = data['imageUrl'] ?? '';
                                  if (imageUrl.isNotEmpty) {
                                    // Open image in a dialog or modal
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: 300,
                                                  height: 300,
                                                ),
                                                const SizedBox(height: 16),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Close',
                                                    style: TextStyle(
                                                      fontFamily: 'Mazzard',
                                                      fontSize: 18,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    // Show a message if no image is available
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No image available for this complaint.',
                                          style: TextStyle(
                                            fontFamily: 'Mazzard',
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      getStatusColor(data['status']),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'View Image',
                                  style: TextStyle(
                                    fontFamily: 'Mazzard',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            getStatusIcon(data['status']),
                            color: getStatusColor(data['status']),
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getStatusText(data['status']),
                            style: TextStyle(
                              fontFamily: 'Mazzard',
                              fontSize: 14,
                              color: getStatusColor(data['status']),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('User')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first;
        } else {
          throw Exception('User document not found.');
        }
      }),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Text('User not found.');
        }
        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String userUid = snapshot.data!.id;

        return StudentPastComplaintsScreen(userUid: userUid);
      },
    ),
  ));
}
