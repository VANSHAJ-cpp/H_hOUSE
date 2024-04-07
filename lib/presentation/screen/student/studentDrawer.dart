// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hostelapplication/core/constant/string.dart';
import 'package:hostelapplication/logic/modules/userData_model.dart';
import 'package:hostelapplication/logic/service/auth_services/auth_service.dart';
import 'package:hostelapplication/presentation/screen/admin/leave/Menu_Screen.dart';
import 'package:hostelapplication/presentation/screen/student/Drawer/mycomplaint.dart';
import 'package:hostelapplication/presentation/screen/student/Menu%20Display/Menu.dart';
import 'package:hostelapplication/presentation/screen/student/complains/studentPastComplaint.dart';
import 'package:provider/provider.dart';

import 'Van/van_timings.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    UserData? userData;
    final authService = Provider.of<AuthService>(context);
    User user = authService.getcurrentUser();
    List<UserData> complaintList = [];
    final complaintListRaw = Provider.of<List<UserData>?>(context);
    complaintListRaw?.forEach((element) {
      if (user.uid == element.id) {
        complaintList.add(element);
      } else
        return null;
      ;
    });
    const studentDrawerText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: complaintList.length == 0
            ? Container()
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  // _createHeader(),
                  ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, studentDetailScreenRoute);
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        complaintList.first.userimage),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    complaintList.first.firstName +
                                        ' ' +
                                        complaintList.first.lastName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "View Profile",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 50, child: Divider()),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.book,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Text(
                          'My Complaints',
                          style: studentDrawerText,
                        ),
                      ],
                    ),
                    onTap: () async {
                      String? userUid = FirebaseAuth.instance.currentUser?.uid;
                      if (userUid != null && userUid.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentPastComplaintsScreen(
                              userUid: userUid,
                            ),
                          ),
                        );
                      } else {
                        // Handle error, user not logged in
                      }
                    },
                  ),
                  // const SizedBox(width: 50, child: Divider()),
                  // ListTile(
                  //   title: Row(
                  //     children: [
                  //       Icon(
                  //         CupertinoIcons.person_crop_circle_badge_minus,
                  //         color: Colors.blue.shade900,
                  //       ),
                  //       const SizedBox(
                  //         width: 30,
                  //       ),
                  //       const Text(
                  //         'My Leaves',
                  //         style: studentDrawerText,
                  //       ),
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const MyLeave()));
                  //   },
                  // ),
                  // const SizedBox(width: 50, child: Divider()),
                  // ListTile(
                  //   title: Row(
                  //     children: [
                  //       Icon(
                  //         CupertinoIcons.wrench,
                  //         color: Colors.blue.shade900,
                  //       ),
                  //       const SizedBox(
                  //         width: 30,
                  //       ),
                  //       const Text(
                  //         'My Services',
                  //         style: studentDrawerText,
                  //       ),
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const Myservicesrequest()));
                  //   },
                  // ),
                  // const SizedBox(width: 50, c.hild: Divider()),

                  const Divider(),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.car,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Book Van Timings',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    onTap: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final userUid = user.uid;
                          final bookings = await _fetchBookings();
                          if (bookings.isEmpty) {
                            // No booking history, navigate to VanTimingsScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VanTimingsScreen()),
                            );
                          } else {
                            // Booking history exists, navigate to BookingTableScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingTableScreen(
                                  userUid: userUid,
                                  bookings: bookings,
                                ),
                              ),
                            );
                          }
                        } else {
                          throw Exception('User not signed in');
                        }
                      } catch (error) {
                        print('Error: $error');
                        // Handle error here
                      }
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.food_bank,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Text(
                          'Check Menu',
                          style: studentDrawerText,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FoodMenuScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 50, child: Divider()),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.signOut,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Text(
                          'Log out',
                          style: studentDrawerText,
                        ),
                      ],
                    ),
                    onTap: () {
                      authService.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, logInScreenRoute, (route) => false);
                    },
                  ),
                  const SizedBox(width: 50, child: Divider()),
                ],
              ),
      ),
    );
  }
}
