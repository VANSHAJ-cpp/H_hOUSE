import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() => runApp(MenuScreen());

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Food Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: MenuScreenPage(),
    );
  }
}

class MenuScreenPage extends StatefulWidget {
  @override
  _MenuScreenPageState createState() => _MenuScreenPageState();
}

class _MenuScreenPageState extends State<MenuScreenPage> {
  late String selectedDay;

  TextEditingController breakfastController = TextEditingController();
  TextEditingController lunchController = TextEditingController();
  TextEditingController snacksController = TextEditingController();
  TextEditingController dinnerController = TextEditingController();

  late ScrollController _scrollController = ScrollController();

  // Track whether the dialog is open
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    selectedDay = _getCurrentDay();
    _scrollController = ScrollController(); // Initialize ScrollController
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  String _getCurrentDay() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('EEEE');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hostel Food Menu'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Check if the dialog is already open
              if (!isDialogOpen) {
                showDialog(
                  context: context,
                  builder: (_) {
                    isDialogOpen = true;
                    return _buildEditDialog();
                  },
                ).then((value) {
                  // Set the dialog flag to false when dialog is closed
                  isDialogOpen = false;
                  // Refresh the menu when the dialog is closed
                  setState(() {});
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedDay,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDay = newValue ?? '';
                  });
                },
                items: <String>[
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('MenuItems')
          .doc(selectedDay)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return _buildEditList();
        }

        Map<String, dynamic>? data =
            snapshot.data?.data() as Map<String, dynamic>?;

        if (data == null || data.isEmpty) {
          return _buildEditList();
        }

        return _buildMenuTable(data);
      },
    );
  }

  Widget _buildEditList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableList("Breakfast", breakfastController),
        _buildEditableList("Lunch", lunchController),
        _buildEditableList("Snacks", snacksController),
        _buildEditableList("Dinner", dinnerController),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _saveMenu();
            },
            child: Text('Save Menu'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableList(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        // Wrap with ListView
        shrinkWrap:
            true, // Use shrinkWrap to wrap the ListView tightly around its children
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter items separated by comma',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTable(Map<String, dynamic> data) {
    List<String> breakfast = List.from(data['breakfast'] ?? []);
    List<String> lunch = List.from(data['lunch'] ?? []);
    List<String> snacks = List.from(data['snacks'] ?? []);
    List<String> dinner = List.from(data['dinner'] ?? []);

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Menu for $selectedDay',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildMealCard("Breakfast", breakfast),
            _buildMealCard("Lunch", lunch),
            _buildMealCard("Snacks", snacks),
            _buildMealCard("Dinner", dinner),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String title, List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Text(
                      item,
                      style: TextStyle(fontSize: 16),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDialog() {
    return AlertDialog(
      title: Text('Edit Menu'),
      content: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableList("Breakfast", breakfastController),
              _buildEditableList("Lunch", lunchController),
              _buildEditableList("Snacks", snacksController),
              _buildEditableList("Dinner", dinnerController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Close the dialog
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _saveMenu();
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  void _saveMenu() async {
    await FirebaseFirestore.instance
        .collection('MenuItems')
        .doc(selectedDay)
        .set({
      'breakfast': breakfastController.text.split(','),
      'lunch': lunchController.text.split(','),
      'snacks': snacksController.text.split(','),
      'dinner': dinnerController.text.split(','),
    });

    // Close the dialog
    Navigator.pop(context);
  }
}
