import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminBookingScreen extends StatefulWidget {
  const AdminBookingScreen({Key? key}) : super(key: key);

  @override
  _AdminBookingScreenState createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  List<Map<String, dynamic>> _bookings = [];
  String _sortBy = 'Date'; // Default sorting criteria

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Booking Table',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortingBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _selectDateAndExportPDF();
            },
          ), // Add this IconButton for exporting PDF
        ],
      ),
      body: _buildBookingList(),
    );
  }

  Widget _buildBookingList() {
    if (_bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      // Sort the bookings based on selected criteria
      _bookings.sort((a, b) {
        if (_sortBy == 'Date') {
          return a['date'].compareTo(b['date']);
        } else if (_sortBy == 'Pickup Time') {
          return a['PickUptime'].compareTo(b['PickUptime']);
        } else if (_sortBy == 'Drop Time') {
          return a['DropTime'].compareTo(b['DropTime']);
        } else if (_sortBy == 'Location') {
          return a['location'].compareTo(b['location']);
        } else {
          return a['reason'].compareTo(b['reason']);
        }
      });
      return ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ' ${booking['firstName']} ${booking['lastName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                        ),
                        Text(
                          'Room No: ${booking['roomNo']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(booking['date']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pickup Time:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                        ),
                      ),
                      Text(
                        '${DateFormat.jm().format(booking['PickUptime'])}',
                        style: const TextStyle(fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Drop Time:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                        ),
                      ),
                      Text(
                        '${DateFormat.jm().format(booking['DropTime'])}',
                        style: const TextStyle(fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                        ),
                      ),
                      Text(
                        '${booking['location']}',
                        style: const TextStyle(fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reason:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                        ),
                      ),
                      Text(
                        '${booking['reason']}',
                        style: const TextStyle(fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text('Filter option 1'),
                  onTap: () {
                    // Implement filtering logic based on option 1
                    // For simplicity, let's just print a message for now
                    print('Filtering by option 1');
                    Navigator.pop(context); // Use Navigator to close the dialog
                  },
                ),
                ListTile(
                  title: const Text('Filter option 2'),
                  onTap: () {
                    // Implement filtering logic based on option 2
                    // For simplicity, let's just print a message for now
                    print('Filtering by option 2');
                    Navigator.pop(context); // Use Navigator to close the dialog
                  },
                ),
                // Add more filter options as needed
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              GFListTile(
                titleText: 'Date',
                onTap: () {
                  setState(() {
                    _sortBy = 'Date';
                  });
                  Navigator.pop(context);
                },
              ),
              GFListTile(
                titleText: 'Pickup Time',
                onTap: () {
                  setState(() {
                    _sortBy = 'Pickup Time';
                  });
                  Navigator.pop(context);
                },
              ),
              GFListTile(
                titleText: 'Drop Time',
                onTap: () {
                  setState(() {
                    _sortBy = 'Drop Time';
                  });
                  Navigator.pop(context);
                },
              ),
              GFListTile(
                titleText: 'Location',
                onTap: () {
                  setState(() {
                    _sortBy = 'Location';
                  });
                  Navigator.pop(context);
                },
              ),
              GFListTile(
                titleText: 'Reason',
                onTap: () {
                  setState(() {
                    _sortBy = 'Reason';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDateAndExportPDF() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      // Filter bookings based on selected date
      List<Map<String, dynamic>> selectedBookings = _bookings.where((booking) {
        return booking['date'].day == pickedDate.day &&
            booking['date'].month == pickedDate.month &&
            booking['date'].year == pickedDate.year;
      }).toList();
      if (selectedBookings.isNotEmpty) {
        // Export PDF for selected bookings
        exportPDF(selectedBookings, pickedDate);
      } else {
        // Show a message if no bookings found for selected date
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: const Text(
                'No Bookings Found',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: const Text(
                'There are no bookings for the selected date.',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> exportPDF(
      List<Map<String, dynamic>> bookings, DateTime selectedDate) async {
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
                child: pw.Text('Van Schedule - H HOUSE',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                margin: const pw.EdgeInsets.only(right: 20),
                child:
                    pw.Text('${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                        )),
              ),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Sno',
                  'Name',
                  'Room No',
                  'Pickup Time',
                  'Drop Time',
                  'Location',
                  'Reason'
                ],
                data: bookings.map<List<String>>((booking) {
                  return [
                    '${bookings.indexOf(booking) + 1}',
                    '${booking['firstName']} ${booking['lastName']}',
                    '${booking['roomNo']}',
                    '${DateFormat.jm().format(booking['PickUptime'])}',
                    '${DateFormat.jm().format(booking['DropTime'])}',
                    '${booking['location']}',
                    '${booking['reason']}',
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
  void initState() {
    super.initState();
    _fetchAllBookings();
  }

  Future<void> _fetchAllBookings() async {
    try {
      final vanTimingsQuery =
          await FirebaseFirestore.instance.collection('VanTimings').get();

      final List<Map<String, dynamic>> allBookings = [];

      for (var doc in vanTimingsQuery.docs) {
        final pickupTime = doc['pickupTime'];
        final dropTime = doc['dropTime'];

        if (pickupTime is Timestamp && dropTime is Timestamp) {
          final userQuery = await FirebaseFirestore.instance
              .collection('User')
              .doc(doc['uid'])
              .get();

          final firstName = userQuery.exists && userQuery['FirstName'] != null
              ? userQuery['FirstName'] as String
              : '';
          final lastName = userQuery.exists && userQuery['Lastname'] != null
              ? userQuery['Lastname'] as String
              : '';
          final roomNo = userQuery.exists && userQuery['RoomNo'] != null
              ? userQuery['RoomNo'] as String
              : '';

          allBookings.add({
            'date': (pickupTime as Timestamp).toDate(),
            'PickUptime': pickupTime.toDate(),
            'DropTime': dropTime.toDate(),
            'location': doc['location'] as String,
            'reason': doc['reason'] as String,
            'docId': doc.id,
            'firstName': firstName,
            'lastName': lastName,
            'roomNo': roomNo,
          });
        } else {
          print(
              'pickupTime and dropTime are not in Timestamp format. Skipping entry.');
        }
      }

      setState(() {
        _bookings = allBookings;
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }
}
