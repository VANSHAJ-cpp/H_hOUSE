// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VanTimingsScreen extends StatefulWidget {
  const VanTimingsScreen({Key? key});

  @override
  _VanTimingsScreenState createState() => _VanTimingsScreenState();
}

class _VanTimingsScreenState extends State<VanTimingsScreen> {
  late TimeOfDay _pickupTime;
  late TimeOfDay _dropTime;
  late DateTime _selectedDate;
  String _selectedLocation = '';
  String _selectedReason = '';
  List<String> _locations = [];
  final List<String> _reasons = ['Coaching Class', 'Doubt Class', 'Exam'];

  @override
  void initState() {
    super.initState();
    _pickupTime = TimeOfDay.now();
    _dropTime = TimeOfDay.now();
    _selectedDate = DateTime.now();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Locations').get();

      final Set<String> locationsSet = Set<String>();
      querySnapshot.docs.forEach((doc) {
        final loc1 = doc['Loc1'] as String?;
        if (loc1 != null) {
          final List<String> splitLocations = loc1.split(',');
          locationsSet.addAll(splitLocations);
        }
      });

      final List<String> uniqueLocations = locationsSet.toList();

      setState(() {
        _locations = uniqueLocations;
      });
    } catch (error) {
      print('Error fetching locations: $error');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userUid = user.uid;
        final vanTimingsQuery = await FirebaseFirestore.instance
            .collection('VanTimings')
            .where('uid', isEqualTo: userUid)
            .get();

        final List<Map<String, dynamic>> bookings = [];

        for (var doc in vanTimingsQuery.docs) {
          final pickupTime = doc['pickupTime'];
          final dropTime = doc['dropTime'];

          if (pickupTime is Timestamp && dropTime is Timestamp) {
            bookings.add({
              'date': (pickupTime as Timestamp).toDate(),
              'PickUptime': pickupTime.toDate(),
              'DropTime': dropTime.toDate(),
              'location': doc['location'] as String,
              'reason': doc['reason'] as String,
              'docId': doc.id, // Added document ID to identify the booking
            });
          } else {
            print(
                'pickupTime and dropTime are not in Timestamp format. Skipping entry.');
          }
        }

        return bookings;
      } else {
        throw Exception('User not signed in');
      }
    } catch (error) {
      print('Error fetching bookings: $error');
      throw error;
    }
  }

  Future<void> _submitDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userUid = user.uid;
        final selectedDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _pickupTime.hour,
          _pickupTime.minute,
        );

        final selectedDateTime2 = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _dropTime.hour,
          _dropTime.minute,
        );

        final DateTime minTime = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 6, 30);
        final DateTime maxTime = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 21, 0);

        if (_pickupTime.hour < 6 ||
            _pickupTime.hour >= 21 ||
            _dropTime.hour < 6 ||
            _dropTime.hour >= 21 ||
            selectedDateTime.isBefore(minTime) ||
            selectedDateTime.isAfter(maxTime) ||
            selectedDateTime2.isBefore(minTime) ||
            selectedDateTime2.isAfter(maxTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No slot available, choose between 6:30 AM to 9:00 PM only.',
                style: TextStyle(color: Colors.red, fontFamily: 'Mazzard'),
              ),
            ),
          );
          return; // Prevent further execution
        }

        await FirebaseFirestore.instance.collection('VanTimings').add({
          'uid': userUid,
          'pickupTime': Timestamp.fromDate(selectedDateTime),
          'dropTime': Timestamp.fromDate(selectedDateTime2),
          'location': _selectedLocation,
          'reason': _selectedReason,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details submitted successfully!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FutureBuilder(
              future: _fetchBookings(), // Fetch bookings asynchronously
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return BookingTableScreen(
                    userUid: userUid,
                    bookings: snapshot.data!,
                  );
                }
              },
            ),
          ),
        );
      } else {
        throw Exception('User not signed in');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit details: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Book Van Slots',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Mazzard',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'Choose Van Timings',
              style: TextStyle(
                fontSize: 22.0,
                fontFamily: 'Mazzard',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Select the date, pickup and drop time for the Van Service.',
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Mazzard',
              ),
            ),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Mazzard',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Mazzard',
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pickup Time:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Mazzard',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _selectPickupTime(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_formatTime(_pickupTime)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Mazzard',
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Drop Time:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Mazzard',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _selectDropTime(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_formatTime(_dropTime)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Mazzard',
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Location:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Mazzard',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _showLocationModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _selectedLocation.isNotEmpty
                        ? _selectedLocation
                        : 'Choose Location',
                    style: const TextStyle(fontFamily: 'Mazzard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reason:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Mazzard',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _showReasonModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _selectedReason.isNotEmpty
                        ? _selectedReason
                        : 'Choose Reason',
                    style: const TextStyle(fontFamily: 'Mazzard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontFamily: 'Mazzard', fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLocationModal(BuildContext context) async {
    final selectedLocation = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _locations.length,
          itemBuilder: (context, index) {
            final location = _locations[index];
            return ListTile(
              title: Text(
                location,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Mazzard'),
              ),
              onTap: () {
                Navigator.pop(context, location);
              },
            );
          },
        );
      },
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  Future<void> _showReasonModal(BuildContext context) async {
    final selectedReason = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _reasons.length,
          itemBuilder: (context, index) {
            final reason = _reasons[index];
            return ListTile(
              title: Text(
                reason,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Mazzard'),
              ),
              onTap: () {
                Navigator.pop(context, reason);
              },
            );
          },
        );
      },
    );

    if (selectedReason != null) {
      setState(() {
        _selectedReason = selectedReason;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectPickupTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
    );
    if (pickedTime != null) {
      // Round off minutes to nearest 15 multiple
      final roundedMinutes = (pickedTime.minute / 15).round() * 15;
      setState(() {
        _pickupTime = TimeOfDay(hour: pickedTime.hour, minute: roundedMinutes);
      });
    }
  }

  Future<void> _selectDropTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _dropTime,
    );
    if (pickedTime != null) {
      // Round off minutes to nearest 15 multiple
      final roundedMinutes = (pickedTime.minute / 15).round() * 15;
      setState(() {
        _dropTime = TimeOfDay(hour: pickedTime.hour, minute: roundedMinutes);
      });
    }
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final DateTime dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(dateTime);
  }
}

class BookingTableScreen extends StatelessWidget {
  final String userUid;
  final List<Map<String, dynamic>> bookings;

  const BookingTableScreen({
    super.key,
    required this.userUid,
    required this.bookings,
  });
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pop until HomeScreen is reached
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
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
          future: _fetchData(),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final data = snapshot.data;
              if (data == null ||
                  data.isEmpty ||
                  data['bookings'] == null ||
                  data['bookings'].isEmpty) {
                return const Center(child: Text('No bookings found.'));
              }
              final List<Map<String, dynamic>> bookings = data['bookings'];
              final String firstName = data['firstName'];
              final String lastName = data['lastName'];
              final String roomNo = data['roomNo'];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Mazzard'),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: Text(
                          'Name: $firstName $lastName',
                          style: const TextStyle(fontFamily: 'Mazzard'),
                        ),
                        subtitle: Text(
                          'Room No: $roomNo',
                          style: const TextStyle(fontFamily: 'Mazzard'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const ClampingScrollPhysics(), // Added to prevent scrolling conflicts
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Dismissible(
                            key: Key(booking.hashCode.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _deleteBooking(index);
                            },
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
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
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          DateFormat('yyyy-MM-dd')
                                              .format(booking['date']),
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
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                            style: const TextStyle(
                                                fontFamily: 'Mazzard'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          style: const TextStyle(
                                              fontFamily: 'Mazzard'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          style: const TextStyle(
                                              fontFamily: 'Mazzard'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          style: const TextStyle(
                                              fontFamily: 'Mazzard'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VanTimingsScreen()),
            );
          },
          backgroundColor: Colors.black,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('User')
          .doc(userUid)
          .get();
      final userFirstName = userQuery['FirstName'] as String;
      final userLastName = userQuery['Lastname'] as String;
      final userRoomNo = userQuery['RoomNo'] as String;

      final vanTimingsQuery = await FirebaseFirestore.instance
          .collection('VanTimings')
          .where('uid', isEqualTo: userUid)
          .get();

      final List<Map<String, dynamic>> bookings = [];

      for (var doc in vanTimingsQuery.docs) {
        print('Document data: ${doc.data()}'); // Debug print
        final pickupTime = doc['pickupTime'];
        final dropTime = doc['dropTime'];

        if (pickupTime is Timestamp && dropTime is Timestamp) {
          bookings.add({
            'date': (pickupTime as Timestamp).toDate(),
            'PickUptime': pickupTime.toDate(),
            'DropTime': dropTime.toDate(),
            'location': doc['location'] as String,
            'reason': doc['reason'] as String,
            'docId': doc.id, // Added document ID to identify the booking
          });
        } else {
          print(
              'pickupTime and dropTime are not in Timestamp format. Skipping entry.');
        }
      }

      return {
        'bookings': bookings,
        'firstName': userFirstName,
        'lastName': userLastName,
        'roomNo': userRoomNo,
      };
    } catch (error) {
      print('Error fetching data: $error');
      return {}; // Return empty map in case of error
    }
  }

  Future<void> _deleteBooking(int index) async {
    final booking = bookings[index];
    final docId = booking['docId'];
    try {
      await FirebaseFirestore.instance
          .collection('VanTimings')
          .doc(docId)
          .delete();
    } catch (error) {
      print('Error deleting booking: $error');
    }
  }
}
