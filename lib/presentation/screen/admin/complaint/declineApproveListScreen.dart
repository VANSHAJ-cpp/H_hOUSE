import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeclineApproveListScreen extends StatefulWidget {
  final int complainStatus;

  DeclineApproveListScreen(this.complainStatus, {Key? key}) : super(key: key);

  @override
  _DeclineApproveListScreenState createState() =>
      _DeclineApproveListScreenState();
}

class _DeclineApproveListScreenState extends State<DeclineApproveListScreen> {
  late Stream<QuerySnapshot> _complaintsStream;

  @override
  void initState() {
    super.initState();
    _complaintsStream = widget.complainStatus == 1
        ? FirebaseFirestore.instance
            .collection('approvedComplaints')
            .snapshots()
        : FirebaseFirestore.instance
            .collection('declinedComplaints')
            .snapshots();
  }

  void updateComplaintStatus(String complaintId, int status) async {
    try {
      await FirebaseFirestore.instance
          .collection('StudentComplaint')
          .doc(complaintId)
          .update({'status': status});

      // Depending on the status, move the complaint to the appropriate collection
      if (status == 1) {
        // Move to approvedComplaints collection
        await FirebaseFirestore.instance
            .collection('approvedComplaints')
            .doc(complaintId)
            .set({'status': status}, SetOptions(merge: true));
      } else if (status == 2) {
        // Move to declinedComplaints collection
        await FirebaseFirestore.instance
            .collection('declinedComplaints')
            .doc(complaintId)
            .set({'status': status}, SetOptions(merge: true));
      }

      print('Complaint status updated to $status');
    } catch (error) {
      print('Error updating complaint status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(
          widget.complainStatus == 1
              ? 'Approved complaints'
              : 'Declined complaints',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _complaintsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot document = snapshot.data!.docs[index];
                  final Map<String, dynamic>? data =
                      document.data() as Map<String, dynamic>?;

                  String statusText = '';
                  Color statusColor = Colors.black;

                  switch (data?['status']) {
                    case 1:
                      statusText = 'Approved';
                      statusColor = Colors.green;
                      break;
                    case 2:
                      statusText = 'Declined';
                      statusColor = Colors.red;
                      break;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data?['userName'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Room - ${data?['roomNo'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${data?['timestamp'].toDate().day ?? ''}/${data?['timestamp'].toDate().month ?? ''}/${data?['timestamp'].toDate().year ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complaint Type: ${data?['complaintType'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Complaint Description:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                data?['complaintDescription'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (data?['imageUrl'] != null &&
                                  data?['imageUrl'].isNotEmpty)
                                ElevatedButton(
                                  onPressed: () async {
                                    String imageUrl = data?['imageUrl'] ?? '';
                                    if (imageUrl.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              height: double.maxFinite,
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      print('Image URL not found');
                                    }
                                  },
                                  child: Text(
                                    'View Image',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.orange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (widget.complainStatus == 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    updateComplaintStatus(document.id, 1);
                                  },
                                  child: Text(
                                    'Approve',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.green,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    updateComplaintStatus(document.id, 2);
                                  },
                                  child: Text(
                                    'Deny',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nodata.jpg',
                    height: 250,
                    width: 250,
                  ),
                  Text(
                    'No Complaints :)',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
