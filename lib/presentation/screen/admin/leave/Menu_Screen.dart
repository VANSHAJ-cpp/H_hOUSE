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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
          displayLarge: TextStyle(
              fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.blue),
          displayMedium: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      home: MenuScreenPage(),
    );
  }
}

class MenuScreenPage extends StatefulWidget {
  @override
  _MenuScreenPageState createState() => _MenuScreenPageState();
}

class _MenuScreenPageState extends State<MenuScreenPage>
    with SingleTickerProviderStateMixin {
  late String selectedDay;
  late ScrollController _scrollController;
  late AnimationController _animationController;

  TextEditingController breakfastController = TextEditingController();
  TextEditingController lunchController = TextEditingController();
  TextEditingController snacksController = TextEditingController();
  TextEditingController dinnerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDay = _getCurrentDay();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
        backgroundColor: Colors.black,
        title: const Text(
          'Hostel Food Menu',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return _buildEditModalBottomSheet();
                },
              ).then((value) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                      style: const TextStyle(
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
          return const Center(
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

        _animationController.forward(); // Start animation

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _buildMenuItems(data),
        );
      },
    );
  }

  Widget _buildEditList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableMenu("Breakfast", breakfastController),
        _buildExpandableMenu("Lunch", lunchController),
        _buildExpandableMenu("Snacks", snacksController),
        _buildExpandableMenu("Dinner", dinnerController),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _saveMenu();
            },
            child: const Text('Save Menu'),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableMenu(String title, TextEditingController controller) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Enter items separated by comma',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(Map<String, dynamic> data) {
    List<String> breakfast = List.from(data['breakfast'] ?? []);
    List<String> lunch = List.from(data['lunch'] ?? []);
    List<String> snacks = List.from(data['snacks'] ?? []);
    List<String> dinner = List.from(data['dinner'] ?? []);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu for $selectedDay',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuItem("Breakfast", breakfast),
          const SizedBox(height: 20),
          _buildMenuItem("Lunch", lunch),
          const SizedBox(height: 20),
          _buildMenuItem("Snacks", snacks),
          const SizedBox(height: 20),
          _buildMenuItem("Dinner", dinner),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => FadeTransition(
                    opacity:
                        _animationController.drive(Tween(begin: 0.0, end: 1.0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditModalBottomSheet() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandableMenu("Breakfast", breakfastController),
            _buildExpandableMenu("Lunch", lunchController),
            _buildExpandableMenu("Snacks", snacksController),
            _buildExpandableMenu("Dinner", dinnerController),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _saveMenu();
                Navigator.pop(context); // Close the bottom sheet
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
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
  }
}
