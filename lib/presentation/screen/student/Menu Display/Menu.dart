import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen({Key? key}) : super(key: key);

  @override
  _FoodMenuScreenState createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  late String selectedDay; // Declare selectedDay as a late variable

  List<String> breakfast = [];
  List<String> lunch = [];
  List<String> dinner = [];
  List<String> snacks = [];

  @override
  void initState() {
    super.initState();
    selectedDay =
        _getCurrentDay(); // Initialize selectedDay with the current day
    _fetchMenu(selectedDay); // Fetch menu items for the current day
  }

  String _getCurrentDay() {
    // Get the current date
    DateTime now = DateTime.now();

    // Use DateFormat from intl package to format the date to get the day of the week
    String formattedDate = DateFormat('EEEE').format(now);

    // Return the formatted day of the week
    return formattedDate;
  }

  void _fetchMenu(String day) {
    FirebaseFirestore.instance
        .collection('MenuItems')
        .doc(day)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          breakfast = List<String>.from(documentSnapshot['breakfast']);
          lunch = List<String>.from(documentSnapshot['lunch']);
          dinner = List<String>.from(documentSnapshot['dinner']);
          snacks = List<String>.from(documentSnapshot['snacks']);
        });
      } else {
        print('Document does not exist on the database');
        // Handle the case where the document does not exist
      }
    }).catchError((error) {
      print('Error fetching document: $error');
      // Handle errors that occur during the fetch operation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text(
          "Our Menu",
          style: TextStyle(
            fontFamily: 'Mazzard',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: selectedDay,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              alignment: Alignment.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Mazzard',
              ),
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              dropdownColor: Colors.black, // Set the background color here
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue!;
                  _fetchMenu(selectedDay); // Fetch menu for the selected day
                });
              },
              items: <String>[
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Mazzard',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${_getCurrentDay()}'s Menu",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Check out the tempting food menu of H House",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: List.generate(6, (index) {
                return Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/food/${index + 1}.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildExpandableList("Breakfast", breakfast),
            _buildExpandableList("Lunch", lunch),
            _buildExpandableList("Dinner", dinner),
            _buildExpandableList("Snacks", snacks),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableList(String meal, List<String> items) {
    return ExpansionTile(
      title: Text(
        meal,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 75, 74, 74)
                                .withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minHeight: 50),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Mazzard',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
