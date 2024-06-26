// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hostelapplication/core/constant/string.dart';
import 'package:hostelapplication/logic/service/auth_services/auth_service.dart';
import 'package:hostelapplication/presentation/screen/admin/studentdetails.dart';
import 'package:provider/provider.dart';

import 'workers/workers.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue.shade900,
                          child: const Icon(Icons.account_circle_rounded),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        const Text(
                          "Admin",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
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
                    FontAwesomeIcons.question,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    'Help',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, helpscreenRoute);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.group,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    'Student Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StudentDetailsScreen()), // Replace StudentDetailsScreen with your actual screen widget
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.group,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    'Worker Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WorkerScreen()), // Replace StudentDetailsScreen with your actual screen widget
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.signOut,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    'Log out',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  )
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
