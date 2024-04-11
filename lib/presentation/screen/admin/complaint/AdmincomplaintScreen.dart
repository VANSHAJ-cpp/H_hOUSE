import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Center(
          child: const Text(
            'Student Complaints',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
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
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    child: ListTile(
                      leading: const Icon(
                        Icons.pending,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      title: const Text(
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
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: const Text(
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
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    child: ListTile(
                      leading: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: const Text(
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
