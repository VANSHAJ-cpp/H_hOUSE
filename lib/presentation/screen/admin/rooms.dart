// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Availability',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RoomAvailabilityScreen(),
    );
  }
}

class RoomAvailabilityScreen extends StatefulWidget {
  @override
  _RoomAvailabilityScreenState createState() => _RoomAvailabilityScreenState();
}

class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen> {
  String selectedProperty = ''; // Default property
  List<String> properties = []; // List to hold properties from Firestore

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  void fetchProperties() async {
    print('Fetching properties...');
    // Fetch properties from Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('RoomAvailability').get();
    setState(() {
      properties = querySnapshot.docs.map((doc) => doc.id).toList();
      if (properties.isNotEmpty) {
        selectedProperty = properties.first;
      }
    });
    print('Properties fetched: $properties');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton(
          value: selectedProperty,
          onChanged: (newValue) {
            setState(() {
              selectedProperty = newValue.toString();
            });
          },
          items: properties.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add property screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPropertyScreen()),
              ).then((_) {
                // Refresh properties list after adding a new property
                fetchProperties();
              });
            },
          ),
        ],
      ),
      floatingActionButton: selectedProperty.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // Redirect to add floor and rooms screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddFloorScreen(property: selectedProperty)),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: selectedProperty.isNotEmpty
          ? RoomList(property: selectedProperty)
          : const Center(
              child: Text('No properties available. Please add a property.')),
    );
  }
}

class AddPropertyScreen extends StatefulWidget {
  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final TextEditingController propertyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Property',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: propertyNameController,
              decoration: const InputDecoration(
                labelText: 'Property Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add property to Firestore
                FirebaseFirestore.instance
                    .collection('RoomAvailability')
                    .doc(propertyNameController.text)
                    .set({});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Property added successfully')));
                Navigator.pop(context);
              },
              child: const Text('Add Property'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFloorScreen extends StatefulWidget {
  final String property;

  AddFloorScreen({required this.property});

  @override
  _AddFloorScreenState createState() => _AddFloorScreenState();
}

class _AddFloorScreenState extends State<AddFloorScreen> {
  final TextEditingController floorNameController = TextEditingController();
  final TextEditingController roomNumbersController = TextEditingController();

  String selectedRoomType = 'Single';
  String selectedBalconyType = 'With Balcony';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Floor and Rooms')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Floor and Rooms',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: floorNameController,
              decoration: const InputDecoration(
                labelText: 'Floor Name',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedRoomType,
              onChanged: (newValue) {
                setState(() {
                  selectedRoomType = newValue!;
                });
              },
              items: ['Single', 'Double']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedBalconyType,
              onChanged: (newValue) {
                setState(() {
                  selectedBalconyType = newValue!;
                });
              },
              items: ['With Balcony', 'Without Balcony']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: roomNumbersController,
              decoration: const InputDecoration(
                labelText: 'Room Numbers (Comma separated)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add floor and rooms to Firestore
                FirebaseFirestore.instance
                    .collection('RoomAvailability')
                    .doc(widget.property)
                    .collection(floorNameController.text)
                    .doc(selectedRoomType + ' ' + selectedBalconyType)
                    .set({
                  'roomNumbers': roomNumbersController.text
                      .split(',')
                      .map((e) => int.parse(e.trim()))
                      .toList(),
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Floors and rooms added successfully')));
                Navigator.pop(context);
              },
              child: const Text('Add Floors and Rooms'),
            ),
          ],
        ),
      ),
    );
  }
}

class FloorListItem extends StatelessWidget {
  final String property;
  final String floor;
  final Map<String, dynamic> floorData;

  FloorListItem(
      {required this.property, required this.floor, required this.floorData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Floor: $floor',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          children: floorData.keys.map((type) {
            List<int> roomNumbers =
                List<int>.from(floorData[type]['roomNumbers']);
            return RoomListItem(
              roomNumbers: roomNumbers,
              floor: floor,
              property: property,
              type: type,
            );
          }).toList(),
        ),
        const Divider(),
      ],
    );
  }
}

class RoomList extends StatelessWidget {
  final String property;

  RoomList({required this.property});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('RoomAvailability')
          .doc(property)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(
            child: Text('No room data available for this property.'),
          );
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        return ListView(
          children: data.entries.map<Widget>((entry) {
            return FloorListItem(
              property: property,
              floor: entry.key,
              floorData: entry.value,
            );
          }).toList(),
        );
      },
    );
  }
}

Widget _buildFloorRooms(BuildContext context, Map<String, dynamic> floorData) {
  print('RoomList: Building floor rooms widget...');
  return Column(
    children: floorData.entries.map<Widget>((entry) {
      print('RoomList: Accessing room type: ${entry.key}');
      return ExpansionTile(
        title: Text(entry.key), // Room type
        children: _buildRoomNumbers(context, entry.value),
      );
    }).toList(),
  );
}

List<Widget> _buildRoomNumbers(BuildContext context, dynamic roomData) {
  if (roomData is Map<String, dynamic>) {
    return roomData.entries.map<Widget>((entry) {
      List<int> roomNumbers = List<int>.from(entry.value['roomNumbers']);
      return ListTile(
        title: Text(entry.key), // Room type
        subtitle: Wrap(
          children: roomNumbers.map<Widget>((roomNumber) {
            return Text(roomNumber.toString());
          }).toList(),
        ),
        onTap: () {
          // Handle room tap if needed
        },
      );
    }).toList();
  } else {
    print('RoomList: Room data is not in expected format: $roomData');
    return []; // Return empty list if roomData is not in expected format
  }
}

class RoomListItem extends StatelessWidget {
  final List<int> roomNumbers; // Adjusted here
  final String property;
  final String floor;
  final String type;

  RoomListItem({
    required this.roomNumbers, // Adjusted here
    required this.property,
    required this.floor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: roomNumbers.map((roomNumber) {
        return GestureDetector(
          onTap: () {
            // On room click, show room type
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Room $roomNumber'),
                  content: Text('Type: $type'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5),
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Center(
              child: Text(
                roomNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
