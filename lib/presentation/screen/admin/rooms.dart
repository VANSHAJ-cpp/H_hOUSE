// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Room Availability',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: RoomAvailabilityScreen(),
//     );
//   }
// }

// class RoomAvailabilityScreen extends StatefulWidget {
//   @override
//   _RoomAvailabilityScreenState createState() => _RoomAvailabilityScreenState();
// }

// class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen> {
//   String selectedProperty = ''; // Default property
//   List<String> properties = []; // List to hold properties from Firestore

//   @override
//   void initState() {
//     super.initState();
//     fetchProperties();
//   }

//   void fetchProperties() async {
//     print('Fetching properties...');
//     // Fetch properties from Firestore
//     QuerySnapshot querySnapshot =
//         await FirebaseFirestore.instance.collection('RoomAvailability').get();
//     setState(() {
//       properties = querySnapshot.docs.map((doc) => doc.id).toList();
//       if (properties.isNotEmpty) {
//         selectedProperty = properties.first;
//       }
//     });
//     print('Properties fetched: $properties');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: DropdownButton(
//           value: selectedProperty,
//           onChanged: (newValue) {
//             setState(() {
//               selectedProperty = newValue.toString();
//             });
//           },
//           items: properties.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // Navigate to add property screen
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddPropertyScreen()),
//               ).then((_) {
//                 // Refresh properties list after adding a new property
//                 fetchProperties();
//               });
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: selectedProperty.isNotEmpty
//           ? FloatingActionButton(
//               onPressed: () {
//                 // Redirect to add floor and rooms screen
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           AddFloorScreen(property: selectedProperty)),
//                 );
//               },
//               child: const Icon(Icons.add),
//             )
//           : null,
//       body: selectedProperty.isNotEmpty
//           ? RoomList(property: selectedProperty)
//           : const Center(
//               child: Text('No properties available. Please add a property.')),
//     );
//   }
// }

// class AddPropertyScreen extends StatefulWidget {
//   @override
//   _AddPropertyScreenState createState() => _AddPropertyScreenState();
// }

// class _AddPropertyScreenState extends State<AddPropertyScreen> {
//   final TextEditingController propertyNameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Property')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Add Property',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             TextField(
//               controller: propertyNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Property Name',
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add property to Firestore
//                 FirebaseFirestore.instance
//                     .collection('RoomAvailability')
//                     .doc(propertyNameController.text)
//                     .set({});
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                     content: Text('Property added successfully')));
//                 Navigator.pop(context);
//               },
//               child: const Text('Add Property'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddFloorScreen extends StatefulWidget {
//   final String property;

//   AddFloorScreen({required this.property});

//   @override
//   _AddFloorScreenState createState() => _AddFloorScreenState();
// }

// class _AddFloorScreenState extends State<AddFloorScreen> {
//   final TextEditingController floorNameController = TextEditingController();
//   final TextEditingController roomNumbersController = TextEditingController();

//   String selectedRoomType = 'Single';
//   String selectedBalconyType = 'With Balcony';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Floor and Rooms')),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Add Floor and Rooms',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             TextField(
//               controller: floorNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Floor Name',
//               ),
//             ),
//             const SizedBox(height: 20),
//             DropdownButton<String>(
//               value: selectedRoomType,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedRoomType = newValue!;
//                 });
//               },
//               items: ['Single', 'Double']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             DropdownButton<String>(
//               value: selectedBalconyType,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedBalconyType = newValue!;
//                 });
//               },
//               items: ['With Balcony', 'Without Balcony']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             TextField(
//               controller: roomNumbersController,
//               decoration: const InputDecoration(
//                 labelText: 'Room Numbers (Comma separated)',
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add floor and rooms to Firestore
//                 FirebaseFirestore.instance
//                     .collection('RoomAvailability')
//                     .doc(widget.property)
//                     .collection(floorNameController.text)
//                     .doc(selectedRoomType + ' ' + selectedBalconyType)
//                     .set({
//                   'roomNumbers': roomNumbersController.text
//                       .split(',')
//                       .map((e) => int.parse(e.trim()))
//                       .toList(),
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                     content: Text('Floors and rooms added successfully')));
//                 Navigator.pop(context);
//               },
//               child: const Text('Add Floors and Rooms'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FloorListItem extends StatelessWidget {
//   final String property;
//   final String floor;
//   final Map<String, dynamic> floorData;

//   FloorListItem(
//       {required this.property, required this.floor, required this.floorData});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Floor: $floor',
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 10),
//         Wrap(
//           children: floorData.keys.map((type) {
//             List<int> roomNumbers =
//                 List<int>.from(floorData[type]['roomNumbers']);
//             return RoomListItem(
//               roomNumbers: roomNumbers,
//               floor: floor,
//               property: property,
//               type: type,
//             );
//           }).toList(),
//         ),
//         const Divider(),
//       ],
//     );
//   }
// }

// class RoomList extends StatelessWidget {
//   final String property;

//   RoomList({required this.property});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('RoomAvailability')
//           .doc(property)
//           .snapshots(),
//       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.data() == null) {
//           return Center(
//             child: Text('No room data available for this property.'),
//           );
//         }

//         Map<String, dynamic> data =
//             snapshot.data!.data() as Map<String, dynamic>;
//         return ListView(
//           children: data.entries.map<Widget>((entry) {
//             return FloorListItem(
//               property: property,
//               floor: entry.key,
//               floorData: entry.value,
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

// Widget _buildFloorRooms(BuildContext context, Map<String, dynamic> floorData) {
//   print('RoomList: Building floor rooms widget...');
//   return Column(
//     children: floorData.entries.map<Widget>((entry) {
//       print('RoomList: Accessing room type: ${entry.key}');
//       return ExpansionTile(
//         title: Text(entry.key), // Room type
//         children: _buildRoomNumbers(context, entry.value),
//       );
//     }).toList(),
//   );
// }

// List<Widget> _buildRoomNumbers(BuildContext context, dynamic roomData) {
//   if (roomData is Map<String, dynamic>) {
//     return roomData.entries.map<Widget>((entry) {
//       List<int> roomNumbers = List<int>.from(entry.value['roomNumbers']);
//       return ListTile(
//         title: Text(entry.key), // Room type
//         subtitle: Wrap(
//           children: roomNumbers.map<Widget>((roomNumber) {
//             return Text(roomNumber.toString());
//           }).toList(),
//         ),
//         onTap: () {
//           // Handle room tap if needed
//         },
//       );
//     }).toList();
//   } else {
//     print('RoomList: Room data is not in expected format: $roomData');
//     return []; // Return empty list if roomData is not in expected format
//   }
// }

// class RoomListItem extends StatelessWidget {
//   final List<int> roomNumbers; // Adjusted here
//   final String property;
//   final String floor;
//   final String type;

//   RoomListItem({
//     required this.roomNumbers, // Adjusted here
//     required this.property,
//     required this.floor,
//     required this.type,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: roomNumbers.map((roomNumber) {
//         return GestureDetector(
//           onTap: () {
//             // On room click, show room type
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text('Room $roomNumber'),
//                   content: Text('Type: $type'),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('Close'),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           child: Container(
//             margin: const EdgeInsets.all(5),
//             width: 50,
//             height: 50,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey,
//             ),
//             child: Center(
//               child: Text(
//                 roomNumber.toString(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class Room {
  String number;
  String type;
  bool hasBalcony;
  bool isBooked;

  Room(this.number, this.type,
      {this.hasBalcony = false, this.isBooked = false});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RoomScreen(),
    );
  }
}

class RoomScreen extends StatefulWidget {
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  List<Room> _allRooms = [];
  List<String> _selectedTags = []; // Track selected tags

  @override
  void initState() {
    super.initState();
    _fetchRoomStatus();
  }

  Future<void> _fetchRoomStatus() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');

    // Set up a snapshot listener
    roomCollection.snapshots().listen((snapshot) {
      final List<Room> rooms = snapshot.docs.map((doc) {
        final data = doc.data();
        return Room(
          doc.id,
          data['type'] != null ? data['type'] : 'Unknown',
          isBooked: data['isBooked'] ?? false,
        );
      }).toList();

      setState(() {
        _allRooms = rooms;
      });
    });
  }

  void _addNewRoom(Room newRoom, String floorNumber) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedType = 'Single';
        bool hasBalcony = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: const Text(
                'Add New Room',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: Colors.black,
                    onChanged: (String? value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    items: ['Single', 'Double'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Room Type',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Has Balcony',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.amber,
                    value: hasBalcony,
                    onChanged: (bool? value) {
                      setState(() {
                        hasBalcony = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, // Move the checkbox to the leading position
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Set circular shape
                      side: const BorderSide(
                          color: Colors.white), // Set border color
                    ),
                    checkColor: Colors.white, // Set check color
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Generate room number based on floor
                    int floorPrefix = 0;
                    if (floorNumber == 'Ground floor') {
                      floorPrefix = 0;
                    } else if (floorNumber == '1st floor') {
                      floorPrefix = 1;
                    } else if (floorNumber == '2nd floor') {
                      floorPrefix = 2;
                    } // Add more conditions for other floors if needed

                    // Increment room number based on existing rooms on the floor
                    int roomNumber = _allRooms
                            .where((room) =>
                                room.number.startsWith('$floorPrefix'))
                            .length +
                        1;

                    // Format room number to have leading zeros
                    String formattedRoomNumber =
                        '$floorPrefix-${roomNumber.toString().padLeft(3, '0')}';

                    // Update the type and balcony status of the new room
                    newRoom.number = formattedRoomNumber;
                    newRoom.type = selectedType;
                    newRoom.hasBalcony = hasBalcony;

                    // Add the new room to Firestore
                    FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(newRoom.number)
                        .set({
                      'type': newRoom.type,
                      'hasBalcony': newRoom.hasBalcony,
                      'isBooked': newRoom.isBooked,
                    }).then((_) {
                      // Update local state after successfully adding to Firestore
                      setState(() {
                        _allRooms.add(newRoom);
                      });

                      // Show a snackbar to indicate success
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('New room added: ${newRoom.number}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }).catchError((error) {
                      // Check if the error is due to cancellation (user pressed Cancel in the dialog)
                      if (error is! String || error != 'cancelled') {
                        // Show a snackbar to indicate error if adding to Firestore fails
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to add room: $error'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'Room Viewer',
            style: TextStyle(color: Colors.white, fontFamily: 'Mazzard'),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  FloorList(
                    floorNumber: 'Ground floor',
                    rooms: _filterRooms(_allRooms, _selectedTags),
                    onAddRoom: _addNewRoom,
                  ),
                  FloorList(
                    floorNumber: '1st floor',
                    rooms: _filterRooms(_allRooms, _selectedTags),
                    onAddRoom: _addNewRoom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: _showFilterDialog,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            children: [
              Icon(Icons.search),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _selectedTags.isEmpty ? 'Filter' : _selectedTags.join(', '),
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Room> _filterRooms(List<Room> rooms, List<String> selectedTags) {
    if (selectedTags.isEmpty) {
      return rooms;
    }

    return rooms.where((room) {
      if (selectedTags.contains('Booked') && !room.isBooked) {
        return false;
      }
      if (selectedTags.contains('Not Booked') && room.isBooked) {
        return false;
      }
      if (selectedTags.contains('Single') && room.type != 'Single') {
        return false;
      }
      if (selectedTags.contains('Double') && room.type != 'Double') {
        return false;
      }
      if (selectedTags.contains('Balcony') && !room.hasBalcony) {
        return false;
      }
      if (selectedTags.contains('Without Balcony') && room.hasBalcony) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Rooms'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterCheckbox('Booked'),
                _buildFilterCheckbox('Not Booked'),
                _buildFilterCheckbox('Single'),
                _buildFilterCheckbox('Double'),
                _buildFilterCheckbox('Balcony'),
                _buildFilterCheckbox('Without Balcony'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String tag) {
    return CheckboxListTile(
      title: Text(tag),
      value: _selectedTags.contains(tag),
      onChanged: (bool? value) {
        setState(() {
          if (value != null && value) {
            _selectedTags.add(tag);
          } else {
            _selectedTags.remove(tag);
          }
        });
      },
      secondary: _selectedTags.contains(tag)
          ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedTags.remove(tag);
                });
              },
            )
          : null,
    );
  }
}

class FloorList extends StatelessWidget {
  final String floorNumber;
  final List<Room> rooms;
  final Function(Room, String) onAddRoom; // Updated callback definition

  FloorList({
    required this.floorNumber,
    required this.rooms,
    required this.onAddRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                floorNumber,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Add a new room with default availability to the floor
                  final newRoom = Room(
                    '${floorNumber[0]}${rooms.length + 1}',
                    'Unknown',
                  );
                  onAddRoom(newRoom, floorNumber); // Pass floorNumber here
                },
              ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          children: [
            ...rooms.map((room) {
              return RoomBubble(room: room);
            }).toList(),
          ],
        ),
      ],
    );
  }
}

class RoomBubble extends StatefulWidget {
  final Room room;

  RoomBubble({required this.room});

  @override
  _RoomBubbleState createState() => _RoomBubbleState();
}

class _RoomBubbleState extends State<RoomBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract last two digits from the room number
    String roomNumber =
        widget.room.number.substring(widget.room.number.length - 2);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _showRoomDetails,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.room.isBooked ? Colors.red : Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              roomNumber, // Display only last two digits
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _showRoomDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Room ${widget.room.number}',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Mazzard',
            ),
          ),
          content: Text(
            'Type: ${widget.room.type}\nBooked: ${widget.room.isBooked ? 'Yes' : 'No'}',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Mazzard',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _toggleBookingStatus();
              },
              child: Text(widget.room.isBooked
                  ? 'Mark as Available'
                  : 'Mark as Booked'),
            ),
          ],
        );
      },
    );
  }

  void _toggleBookingStatus() async {
    final roomRef =
        FirebaseFirestore.instance.collection('rooms').doc(widget.room.number);
    await roomRef.update({'isBooked': !widget.room.isBooked});
    setState(() {
      widget.room.isBooked = !widget.room.isBooked;
    });
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Step 2: Create models
// class Property {
//   final String name;
//   final List<Floor> floors;

//   Property({required this.name, required this.floors});
// }

// class Floor {
//   final String name;
//   final List<RoomType> roomTypes;

//   Floor({required this.name, required this.roomTypes});
// }

// class RoomType {
//   final String name;
//   final List<int> roomNumbers;

//   RoomType({required this.name, required this.roomNumbers});
// }

// // Step 3: Fetch data from Firebase
// Future<List<Property>> fetchProperties() async {
//   print('Fetching properties...');
//   QuerySnapshot propertySnapshot =
//       await FirebaseFirestore.instance.collection('RoomAvailability').get();

//   List<Property> properties = [];

//   propertySnapshot.docs.forEach((propertyDoc) {
//     List<Floor> floors = [];

//     propertyDoc.reference.collection('floors').get().then((floorSnapshot) {
//       floorSnapshot.docs.forEach((floorDoc) {
//         List<RoomType> roomTypes = [];

//         floorDoc.reference.collection('roomTypes').get().then((typeSnapshot) {
//           typeSnapshot.docs.forEach((typeDoc) {
//             roomTypes.add(RoomType(
//               name: typeDoc.id,
//               roomNumbers: List<int>.from(typeDoc['roomNumbers']),
//             ));
//           });
//         });

//         floors.add(Floor(
//           name: floorDoc.id,
//           roomTypes: roomTypes,
//         ));
//       });
//     });

//     properties.add(Property(
//       name: propertyDoc.id,
//       floors: floors,
//     ));
//   });

//   print('Properties fetched: ${properties.length}');
//   return properties;
// }

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Room Numbers',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: RoomNumbersScreen(),
//     );
//   }
// }

// class RoomNumbersScreen extends StatefulWidget {
//   @override
//   _RoomNumbersScreenState createState() => _RoomNumbersScreenState();
// }

// class _RoomNumbersScreenState extends State<RoomNumbersScreen> {
//   late String _selectedProperty = '';
//   late Future<List<Property>> _propertiesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _propertiesFuture = fetchProperties();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: FutureBuilder<List<Property>>(
//           future: _propertiesFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               List<Property> properties = snapshot.data ?? [];
//               if (_selectedProperty.isEmpty && properties.isNotEmpty) {
//                 _selectedProperty = properties.first.name;
//                 print('Selected property: $_selectedProperty');
//               }
//               return DropdownButton<String>(
//                 value: _selectedProperty,
//                 items: properties.map((property) {
//                   return DropdownMenuItem<String>(
//                     value: property.name,
//                     child: Text(property.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedProperty = value!;
//                     print('Selected property changed: $_selectedProperty');
//                   });
//                 },
//               );
//             }
//           },
//         ),
//       ),
//       body: FutureBuilder<List<Property>>(
//         future: _propertiesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           } else {
//             List<Property> properties = snapshot.data ?? [];
//             if (_selectedProperty.isEmpty && properties.isNotEmpty) {
//               _selectedProperty = properties.first.name;
//               print('Selected property: $_selectedProperty');
//             }
//             Property? selectedProperty;
//             for (var property in properties) {
//               if (property.name == _selectedProperty) {
//                 selectedProperty = property;
//                 break;
//               }
//             }
//             if (selectedProperty == null) {
//               print('Selected property not found: $_selectedProperty');
//               return Center(
//                 child: Text('Property not found'),
//               );
//             }
//             return ListView.builder(
//               itemCount: selectedProperty.floors.length,
//               itemBuilder: (context, index) {
//                 Floor floor = selectedProperty!.floors[index];
//                 return ExpansionTile(
//                   title: Text(floor.name),
//                   children: floor.roomTypes.expand((type) {
//                     return type.roomNumbers.map((roomNumber) {
//                       return RoomCircle(
//                         roomNumber: roomNumber,
//                         roomType: type.name,
//                       );
//                     });
//                   }).toList(),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class RoomCircle extends StatelessWidget {
//   final int roomNumber;
//   final String roomType;

//   RoomCircle({required this.roomNumber, required this.roomType});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Room $roomNumber'),
//             content: Text('Type: $roomType'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('Close'),
//               ),
//             ],
//           ),
//         );
//       },
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.black),
//         ),
//         child: Center(
//           child: Text(
//             roomNumber.toString(),
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }
// }
