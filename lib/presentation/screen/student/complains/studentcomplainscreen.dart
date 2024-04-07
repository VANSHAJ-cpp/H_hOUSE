import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostelapplication/presentation/screen/student/complains/studentAddComplain.dart';
import 'package:hostelapplication/presentation/screen/student/complains/studentPastComplaint.dart';
import 'package:hostelapplication/presentation/screen/student/studentDrawer.dart';

class StudentComplainScreen extends StatefulWidget {
  const StudentComplainScreen({Key? key}) : super(key: key);

  @override
  State<StudentComplainScreen> createState() => _StudentComplainScreenState();
}

class _StudentComplainScreenState extends State<StudentComplainScreen>
    with SingleTickerProviderStateMixin {
  final List<String> images = [
    'assets/images/water-bottle.png',
    'assets/images/electrical-energy.png',
    'assets/images/chef.png',
    'assets/images/insects.png',
    'assets/images/other.png'
  ];
  final List<String> imagesText = [
    'Water',
    'Electricity',
    'Worker',
    'Bugs & Insects',
    'Other'
  ];
  final List<String> descriptions = [
    'Report water-related issues such as leakages, shortage, etc.',
    'Report electrical issues such as power outage, flickering lights, etc.',
    'Report issues related to hostel staff or cafeteria.',
    'Report pest control issues such as bugs, insects, etc.',
    'Report any other issues not listed above.'
  ];

  @override
  void dispose() {
    // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Complain',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mazzard',
              fontSize: 22),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
        backgroundColor: Colors.black,
        child: const Icon(Icons.comment),
      ),

      // drawer: const StudentDrawer(),
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAddComplaintScreen(
                    imagesText[index],
                    'student123',
                  ),
                ),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.black, width: 0.1),
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Image.asset(
                        images[index],
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          imagesText[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          descriptions[index],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
