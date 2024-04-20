import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostelapplication/presentation/screen/admin/complaint/approveDenyCompScreen.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PendingComplainListScreen extends StatelessWidget {
  PendingComplainListScreen({Key? key}) : super(key: key);

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
                child: pw.Text('Pending Complaints',
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
                    'Pending',
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
        title: const Text(
          'Pending Complaints',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('StudentComplaint')
                  .where('status', isEqualTo: 'Pending')
                  .get();
              List<Map<String, dynamic>> complaints = querySnapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
              await exportPDF(context, complaints);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('StudentComplaint')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot document = snapshot.data!.docs[index];
                final Map<String, dynamic>? data =
                    document.data() as Map<String, dynamic>?;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApproveDenyComplainList(document),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                    ),
                    child: Container(
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Room - ${data?['roomNo'] ?? ''}',
                                  ),
                                  Text(
                                    '${data?['timestamp'].toDate().day ?? ''}/${data?['timestamp'].toDate().month ?? ''}/${data?['timestamp'].toDate().year ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Text(
                                'Pending',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 214, 108, 22),
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                  const Text(
                    'No Pending Complaints :)',
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
