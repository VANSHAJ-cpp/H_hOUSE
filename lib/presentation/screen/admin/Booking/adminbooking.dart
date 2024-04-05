import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Booking Table',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Mazzard',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _fetchAllBookings(), // Modify this method to fetch all bookings
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Map<String, dynamic>> bookings = snapshot.data!;
            if (bookings.isEmpty) {
              return const Center(child: Text('No bookings found.'));
            }
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
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
                                  fontFamily: 'Mazzard',
                                ),
                              ),
                              Text(
                                'Room No: ${booking['roomNo']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Mazzard',
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
                                fontFamily: 'Mazzard',
                              ),
                            ),
                            Text(
                              '${DateFormat.jm().format(booking['PickUptime'])}',
                              style: const TextStyle(fontFamily: 'Mazzard'),
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
                                fontFamily: 'Mazzard',
                              ),
                            ),
                            Text(
                              '${DateFormat.jm().format(booking['DropTime'])}',
                              style: const TextStyle(fontFamily: 'Mazzard'),
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
                                fontFamily: 'Mazzard',
                              ),
                            ),
                            Text(
                              '${booking['location']}',
                              style: const TextStyle(fontFamily: 'Mazzard'),
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
                                fontFamily: 'Mazzard',
                              ),
                            ),
                            Text(
                              '${booking['reason']}',
                              style: const TextStyle(fontFamily: 'Mazzard'),
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
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllBookings() async {
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
          final firstName = userQuery['FirstName'] as String;
          final lastName = userQuery['Lastname'] as String;
          final roomNo = userQuery['RoomNo'] as String;

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

      return allBookings;
    } catch (error) {
      print('Error fetching data: $error');
      return []; // Return empty list in case of error
    }
  }
}
