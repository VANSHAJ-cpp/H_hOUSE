import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hostelapplication/presentation/screen/admin/AdminDrawer.dart';
import 'package:hostelapplication/presentation/screen/admin/complaint/approveDenyCompScreen.dart';
import 'package:hostelapplication/presentation/screen/admin/complaint/declineApproveListScreen.dart';
import 'package:hostelapplication/presentation/screen/admin/complaint/pendingComplaintListScreen.dart';

class AdminComplaintScreen extends StatefulWidget {
  const AdminComplaintScreen({Key? key}) : super(key: key);

  @override
  State<AdminComplaintScreen> createState() => _AdminComplaintScreenState();
}

class _AdminComplaintScreenState extends State<AdminComplaintScreen> {
  List<String> images = [
    'assets/images/water-bottle.png',
    'assets/images/electrical-energy.png',
    'assets/images/chef.png',
    'assets/images/insects.png',
    'assets/images/other.png'
  ];
  List<String> imagesText = [
    'Water',
    'Electricity',
    'Worker',
    'Bugs & Insects',
    'Other'
  ];

  void _navigateToPendingComplaintListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PendingComplainListScreen(),
      ),
    );
  }

  Future<void> exportPDF(
      BuildContext context, List<Map<String, dynamic>> complaints) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text('All Complaints',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Student Name',
                  'Room No',
                  'Type',
                  'Description',
                  'Date',
                  'Status',
                ],
                data: complaints.map<List<String>>((complaint) {
                  return [
                    '${complaint['userName']}',
                    '${complaint['roomNo']}',
                    '${complaint['complaintTitle']}',
                    '${complaint['complaintDescription']}',
                    '${DateFormat('yyyy-MM-dd').format(complaint['timestamp'].toDate())}',
                    '${complaint['status']}',
                  ];
                }).toList(),
                border: pw.TableBorder.all(
                    width: 1, color: const PdfColor.fromInt(0xff000000)),
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: const PdfColor.fromInt(0xffffffff)),
                cellAlignment: pw.Alignment.center,
                cellStyle: const pw.TextStyle(
                    fontSize: 10, color: PdfColor.fromInt(0xff000000)),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColor.fromInt(0xff000000)),
                rowDecoration:
                    const pw.BoxDecoration(color: PdfColor.fromInt(0xffffffff)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Center(
          child: Text(
            'Student Complaints',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('StudentComplaint')
                  .get();
              List<Map<String, dynamic>> complaints = querySnapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
              await exportPDF(context, complaints);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/onboard/1.jpg',
            fit: BoxFit.cover,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PendingComplainListScreen(),
                        ),
                      );
                      setState(
                          () {}); // Update the UI after returning from PendingComplainListScreen
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.pending,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      title: Text(
                        'Pending Complaints',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeclineApproveListScreen(1),
                        ),
                      );
                      setState(
                          () {}); // Update the UI after returning from DeclineApproveListScreen
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        'Approved Complaints',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeclineApproveListScreen(2),
                        ),
                      );
                      setState(
                          () {}); // Update the UI after returning from DeclineApproveListScreen
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Declined Complaints',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
