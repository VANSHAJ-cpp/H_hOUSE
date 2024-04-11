import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveDenyComplainList extends StatelessWidget {
  final DocumentSnapshot complaintData;

  const ApproveDenyComplainList(this.complaintData, {super.key});

  Future<void> updateComplaintStatus(
      BuildContext context, String status) async {
    try {
      // Update the status of the complaint
      await FirebaseFirestore.instance
          .collection('StudentComplaint')
          .doc(complaintData.id)
          .update({'status': status});

      // Depending on the status, move the complaint to the appropriate collection
      if (status == 'Approved') {
        // Move to approvedComplaints collection
        await FirebaseFirestore.instance
            .collection('approvedComplaints')
            .doc(complaintData.id)
            .set(complaintData.data()
                as Map<String, dynamic>); // Explicit casting
      } else if (status == 'Denied') {
        // Move to declinedComplaints collection
        await FirebaseFirestore.instance
            .collection('declinedComplaints')
            .doc(complaintData.id)
            .set(complaintData.data()
                as Map<String, dynamic>); // Explicit casting
      }

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint status updated to $status'),
        ),
      );

      // Pop current screen
      Navigator.pop(context);
    } catch (error) {
      print('Error updating complaint status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const tablepadding = EdgeInsets.all(15);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text(
          'Approve/Deny Complaint',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 2, color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                    },
                    border: TableBorder.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Complaint ID',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  complaintData['complaintId'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  complaintData['userName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  'Room No.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  complaintData['roomNo'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  '${complaintData['timestamp'].toDate().day}/${complaintData['timestamp'].toDate().month}/${complaintData['timestamp'].toDate().year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  'Complaint Type',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  complaintData['complaintType'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: tablepadding,
                            child: Column(
                              children: [
                                Text(
                                  complaintData['status'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Complaint: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(157, 158, 158, 158),
                          ),
                        ),
                        child: Text(
                          complaintData['complaintDescription'],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                if (complaintData['imageUrl'] != null) ...[
                  const SizedBox(height: 20),
                  Image.network(complaintData['imageUrl']),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Deny action
                          updateComplaintStatus(context, 'Denied');
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          margin: const EdgeInsets.all(1),
                          height: 50,
                          child: const Center(
                            child: Text(
                              'Deny',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Approve action
                          updateComplaintStatus(context, 'Approved');
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          margin: const EdgeInsets.all(1),
                          height: 50,
                          child: const Center(
                            child: Text(
                              'Approve',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
