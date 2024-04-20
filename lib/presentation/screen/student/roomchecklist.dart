import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomChecklistScreen extends StatefulWidget {
  const RoomChecklistScreen({Key? key}) : super(key: key);

  @override
  _RoomChecklistScreenState createState() => _RoomChecklistScreenState();
}

class _RoomChecklistScreenState extends State<RoomChecklistScreen>
    with SingleTickerProviderStateMixin {
  late String uid;
  late Map<String, bool> checklistItems;
  late FirebaseFirestore firestore;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    initializeUser();
    firestore = FirebaseFirestore.instance;
    checklistItems = {
      'Mattress': false,
      'Pillow': false,
      'Mat': false,
      'Cupboard': false,
      'Almirah': false,
      'Table, chair': false,
      'Bed': false,
      'Mug, bucket': false,
      'AC, geyser': false,
      'Curtain': false,
      'Bedsheet, pillow cover': false,
      'MIRROR': false,
      'cloth hanger': false,
      'Toiletries rack (corner)': false,
      'Cloth rod for drying clothes in bathroom': false,
    };
    _fetchChecklistFromFirestore();
  }

  void initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  void _fetchChecklistFromFirestore() async {
    DocumentSnapshot document =
        await firestore.collection('RoomChecklist').doc(uid).get();
    if (document.exists) {
      setState(() {
        checklistItems = Map<String, bool>.from(document.data() as Map);
      });
    }
  }

  void _updateFirestore() {
    firestore.collection('RoomChecklist').doc(uid).set({
      ...checklistItems,
      'dontShowAgain': _dontShowAgain, // Save "Don't Show Again" preference
    }).then((_) {
      if (_dontShowAgain) {
        // If "Don't Show Again" is clicked, navigate to student dashboard
        Navigator.pushReplacementNamed(context, '/studentDashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    bool allChecked = checklistItems.values.every((value) => value);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Room Checklist',
            style: TextStyle(color: Colors.white, fontFamily: 'Mazzard'),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            setState(() {
              _dontShowAgain = true;
              _updateFirestore(); // Save preference on button click
            });
          },
        ),
      ),
      body: ListView.builder(
        itemCount: checklistItems.length,
        itemBuilder: (context, index) {
          final item = checklistItems.keys.elementAt(index);
          return RoomChecklistItem(
            item: item,
            value: checklistItems[item]!,
            onChanged: (newValue) {
              setState(() {
                checklistItems[item] = newValue;
                _updateFirestore();
              });
            },
            controller: _controller,
            animation: _animation,
          );
        },
      ),
      floatingActionButton: allChecked && !_dontShowAgain
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checklist submitted'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacementNamed(context, '/studentDashboard');
              },
              label: const Text(
                'Submit',
                style: TextStyle(fontFamily: 'Mazzard', color: Colors.white),
              ),
              backgroundColor: Colors.black,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class RoomChecklistItem extends StatefulWidget {
  final String item;
  final bool value;
  final Function(bool) onChanged;
  final AnimationController controller;
  final Animation<double> animation;

  const RoomChecklistItem({
    Key? key,
    required this.item,
    required this.value,
    required this.onChanged,
    required this.controller,
    required this.animation,
  }) : super(key: key);

  @override
  _RoomChecklistItemState createState() => _RoomChecklistItemState();
}

class _RoomChecklistItemState extends State<RoomChecklistItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
        if (!widget.value) {
          widget.controller.forward(from: 0);
        } else {
          widget.controller.reverse(from: 1);
        }
      },
      child: ListTile(
        title: Text(widget.item),
        trailing: AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            return RotationTransition(
              turns: widget.animation,
              child: Icon(
                widget.value ? Icons.check_circle : Icons.cancel,
                color: widget.value ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        leading: Icon(
          getIconForItem(widget.item),
          color: Colors.blue, // Change color as per your design
        ),
      ),
    );
  }

  IconData getIconForItem(String item) {
    switch (item) {
      case 'Mattress':
        return Icons.airline_seat_individual_suite;
      case 'Pillow':
        return Icons.bed;
      case 'Mat':
        return Icons.door_back_door;
      case 'Cupboard':
        return Icons.kitchen;
      case 'Almirah':
        return Icons.storage;
      case 'Table, chair':
        return Icons.table_chart;
      case 'Bed':
        return Icons.weekend;
      case 'Mug, bucket':
        return Icons.bathtub;
      case 'AC, geyser':
        return Icons.ac_unit;
      case 'Curtain':
        return Icons.window;
      case 'Bedsheet, pillow cover':
        return Icons.local_laundry_service;
      case 'MIRROR':
        return Icons.brightness_7;
      case 'cloth hanger':
        return Icons.vertical_align_top;
      case 'Toiletries rack (corner)':
        return Icons.storage;
      case 'Cloth rod for drying clothes in bathroom':
        return Icons.vertical_align_bottom;
      default:
        return Icons.check_circle;
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: RoomChecklistScreen(),
  ));
}
