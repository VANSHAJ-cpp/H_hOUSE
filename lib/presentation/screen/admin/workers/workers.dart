import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class Worker {
  final String id;
  final String name;
  final String role;
  final String aadharNumber;
  final String address;
  final String phoneNumber;
  double salary;
  List<DateTime> leaves;
  List<Due> dues;
  List<Transaction> transactions;

  Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.aadharNumber,
    required this.address,
    required this.phoneNumber,
    required this.salary,
    this.leaves = const [],
    this.dues = const [],
    this.transactions = const [],
  });
}

class Due {
  final DateTime date;
  final double amount;

  Due({required this.date, required this.amount});
}

class Transaction {
  final DateTime date;
  final double amount;
  final String type;

  Transaction({required this.date, required this.amount, required this.type});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: WorkerScreen(),
    );
  }
}

class WorkerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workers Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: WorkerListScreen(),
    );
  }
}

class WorkerListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: WorkerList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWorkerForm(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shadowColor: Colors.blueGrey,
                  foregroundColor: Colors.white),
              child: Text(
                'Add Worker',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('workers').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final workers = snapshot.data!.docs;
        return ListView.builder(
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];
            return ListTile(
              title: Text(worker['name']),
              subtitle: Text(worker['role']),
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkerDetailsScreen(workerId: worker.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class AddWorkerForm extends StatefulWidget {
  @override
  _AddWorkerFormState createState() => _AddWorkerFormState();
}

class _AddWorkerFormState extends State<AddWorkerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController aadharNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter role';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: aadharNumberController,
                decoration: InputDecoration(labelText: 'Aadhar Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhar number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: salaryController,
                decoration: InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter salary';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final DocumentReference docRef = await FirebaseFirestore
                        .instance
                        .collection('workers')
                        .add({
                      'name': nameController.text,
                      'role': roleController.text,
                      'aadharNumber': aadharNumberController.text,
                      'address': addressController.text,
                      'phoneNumber': phoneNumberController.text,
                      'salary': double.parse(salaryController.text),
                      'leaves': [],
                      'dues': [],
                      'transactions': [],
                    });

                    nameController.clear();
                    roleController.clear();
                    aadharNumberController.clear();
                    addressController.clear();
                    phoneNumberController.clear();
                    salaryController.clear();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkerDetailsScreen(workerId: docRef.id),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shadowColor: Colors.blueGrey,
                    foregroundColor: Colors.white),
                child: Text(
                  'Add Worker',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkerDetailsScreen extends StatefulWidget {
  final String workerId;

  WorkerDetailsScreen({required this.workerId});

  @override
  _WorkerDetailsScreenState createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  late Worker worker = Worker(
    id: '',
    name: '',
    role: '',
    aadharNumber: '',
    address: '',
    phoneNumber: '',
    salary: 0.0,
  );
  final TextEditingController duesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWorkerDetails();
  }

  void fetchWorkerDetails() async {
    DocumentSnapshot workerSnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId)
        .get();
    worker = Worker(
      id: workerSnapshot.id,
      name: workerSnapshot['name'],
      role: workerSnapshot['role'],
      aadharNumber: workerSnapshot['aadharNumber'],
      address: workerSnapshot['address'],
      phoneNumber: workerSnapshot['phoneNumber'],
      salary: workerSnapshot['salary'].toDouble(),
      leaves:
          List<DateTime>.from(workerSnapshot['leaves'].map((e) => e.toDate())),
      dues: List<Due>.from(workerSnapshot['dues'].map((e) =>
          Due(date: e['date'].toDate(), amount: e['amount'].toDouble()))),
      transactions: List<Transaction>.from(workerSnapshot['transactions'].map(
          (e) => Transaction(
              date: e['date'].toDate(),
              amount: e['amount'].toDouble(),
              type: e['type']))),
    );
    setState(() {});
  }

  void addLeaves(List<DateTime> selectedDates) async {
    for (DateTime date in selectedDates) {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(worker.id)
          .update({
        'leaves': FieldValue.arrayUnion([date]),
      });
    }
    fetchWorkerDetails();
  }

  void addDues() async {
    if (duesController.text.isNotEmpty) {
      double duesAmount = double.parse(duesController.text);
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(worker.id)
          .update({
        'dues': FieldValue.arrayUnion([
          {
            'date': DateTime.now(),
            'amount': duesAmount,
          }
        ]),
      });
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(worker.id)
          .update({
        'transactions': FieldValue.arrayUnion([
          {
            'date': DateTime.now(),
            'amount': duesAmount,
            'type': 'Dues',
          }
        ]),
      });
      fetchWorkerDetails();
      duesController.clear();
    }
  }

  void generateSalary() async {
    // Calculate salary based on leaves
    int extraLeaves = worker.leaves.length - 2;
    double deduction = extraLeaves > 0 ? extraLeaves * (worker.salary / 30) : 0;
    double totalSalary = worker.salary - deduction;

    // Update transactions
    double totalDues = worker.dues.isNotEmpty
        ? worker.dues.map((due) => due.amount).reduce((a, b) => a + b)
        : 0;
    double finalSalary = totalSalary - totalDues;
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(worker.id)
        .update({
      'transactions': FieldValue.arrayUnion([
        {
          'date': DateTime.now(),
          'amount': finalSalary,
          'type': 'Salary',
        }
      ]),
    });
    fetchWorkerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          worker.name,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role: ${worker.role}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text('Aadhar Number: ${worker.aadharNumber}'),
            Text('Address: ${worker.address}'),
            Text('Phone Number: ${worker.phoneNumber}'),
            SizedBox(height: 20.0),
            Text(
              'Salary: ${worker.salary}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final List<DateTime>? selectedDates = await showDialog(
                      context: context,
                      builder: (context) => DateSelectionDialog(),
                    );
                    if (selectedDates != null && selectedDates.isNotEmpty) {
                      addLeaves(selectedDates);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shadowColor: Colors.blueGrey,
                      foregroundColor: Colors.white),
                  child: Text(
                    'Select Leaves',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AddDuesDialog(
                        onAddDues: addDues,
                        controller: duesController,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shadowColor: Colors.blueGrey,
                      foregroundColor: Colors.white),
                  child: Text(
                    'Add Dues',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ExpandableList(
              title: 'Leaves History',
              items: worker.leaves
                      ?.map(
                        (date) =>
                            'Date: ${DateFormat('dd-MM-yyyy').format(date)}',
                      )
                      .toList() ??
                  [],
            ),
            SizedBox(height: 20.0),
            ExpandableList(
              title: 'Dues History',
              items: worker.dues
                      ?.map(
                        (due) =>
                            'Date: ${DateFormat('dd-MM-yyyy').format(due.date)}, Amount: ${due.amount}',
                      )
                      .toList() ??
                  [],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: generateSalary,
              child: Text('Generate Salary'),
            ),
            SizedBox(height: 20.0),
            ExpandableList(
              title: 'Transaction History',
              items: worker.transactions
                      ?.map(
                        (transaction) =>
                            'Date: ${DateFormat('dd-MM-yyyy').format(transaction.date)}, Amount: ${transaction.amount}, Type: ${transaction.type}',
                      )
                      .toList() ??
                  [],
            ),
          ],
        ),
      ),
    );
  }
}

class DateSelectionDialog extends StatefulWidget {
  @override
  _DateSelectionDialogState createState() => _DateSelectionDialogState();
}

class _DateSelectionDialogState extends State<DateSelectionDialog> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Material(
      // Add Material widget here
      child: AlertDialog(
        title: Text('Select Leaves'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 365)),
                lastDate: DateTime.now().add(Duration(days: 365)),
                onDateChanged: (DateTime date) {
                  setState(() {
                    if (selectedDates.contains(date)) {
                      selectedDates.remove(date);
                    } else {
                      selectedDates.add(date);
                    }
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedDates);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shadowColor: Colors.blueGrey,
                    foregroundColor: Colors.white),
                child: Text(
                  'Add Leaves',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddDuesDialog extends StatelessWidget {
  final TextEditingController controller;
  final Function() onAddDues;

  AddDuesDialog({required this.controller, required this.onAddDues});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AlertDialog(
        title: Text('Add Dues'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Dues Amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onAddDues();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shadowColor: Colors.blueGrey,
                foregroundColor: Colors.white),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

class ExpandableList extends StatefulWidget {
  final String title;
  final List<String>? items;

  ExpandableList({required this.title, this.items});

  @override
  _ExpandableListState createState() => _ExpandableListState();
}

class _ExpandableListState extends State<ExpandableList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded && widget.items != null
              ? widget.items!.length * 80.0
              : 0,
          child: isExpanded && widget.items != null
              ? AnimationLimiter(
                  child: ListView.builder(
                    itemCount: widget.items!.length,
                    itemBuilder: (context, index) {
                      final item = widget.items![index];
                      final isIncome = item.startsWith('+');
                      final isExpense = item.startsWith('-');
                      final color = isIncome
                          ? Colors.green
                          : (isExpense ? Colors.red : Colors.black);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: SizedBox(
                              height: 80.0, // Explicit height for ListTile
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.3),
                                  child: Icon(
                                    isIncome
                                        ? Icons.add
                                        : (isExpense
                                            ? Icons.remove
                                            : Icons.compare_arrows),
                                    color: color,
                                  ),
                                ),
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: color,
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: 50, // Adjust the width as needed
                                  child: Text(
                                    '\$${item.substring(1)}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox.shrink(),
        ),
        Divider(), // Added Divider to separate ExpandableList widgets visually
      ],
    );
  }
}
