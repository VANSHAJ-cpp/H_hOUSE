import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Admin Payment Check',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: PaymentList(),
    );
  }
}

class PaymentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('User').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No user details available.'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var user = snapshot.data!.docs[index];
            return PaymentItem(user: user);
          },
        );
      },
    );
  }
}

class PaymentItem extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> user;

  const PaymentItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String fullName = '${user['FirstName']} ${user['Lastname']}';
    String roomNo = user['RoomNo'];
    String email = user['Email'];
    String profileImageUrl = user['UserImage'];

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl),
      ),
      title: Text(
        fullName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room No: $roomNo',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            'Email: $email',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      onTap: () {
        String userId = user.id;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentHistoryScreen(userId: userId),
          ),
        );
      },
    );
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  final String userId;

  const PaymentHistoryScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Payment History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .doc(userId)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No payment history available.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var payment = snapshot.data!.docs[index];
              String status = payment['status'] ?? 'Pending';
              String selectedOption = payment['option'] ?? 'Hostel';

              Color statusColor;
              if (status == 'Approve') {
                statusColor = Colors.green;
              } else if (status == 'Deny') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.yellow;
              }
              Icon _getIcon(String selectedOption) {
                switch (selectedOption) {
                  case 'Electricity':
                    return const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 18,
                    );
                  case 'Hostel':
                    return const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 18,
                    );
                  case 'Mess':
                    return const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 18,
                    );
                  default:
                    return const Icon(
                      Icons.tag,
                      color: Colors.white,
                      size: 18,
                    );
                }
              }

              return Card(
                shadowColor: statusColor,
                elevation: 4,
                color: Colors.black,
                child: ListTile(
                  title: Text('Transaction ID: ${payment.id}',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${payment['timestamp'].toDate()}',
                          style: const TextStyle(color: Colors.white)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Status: $status',
                              style: TextStyle(color: statusColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[
                                  800], // Set background color to a darker shade
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(
                                      0.5), // Set shadow color and opacity
                                  spreadRadius: 2, // Set spread radius
                                  blurRadius: 3, // Set blur radius
                                  offset: const Offset(0, 2), // Set offset
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _getIcon(selectedOption),
                                const SizedBox(
                                    width:
                                        7), // Add some spacing between icon and text
                                Text(
                                  selectedOption,
                                  style: const TextStyle(
                                    color:
                                        Colors.white, // Set text color to white
                                    fontWeight:
                                        FontWeight.bold, // Make text bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.black,
                          title: const Text(
                            'Payment Details',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Name:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${payment['name']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Student ID:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${payment['studentID']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Transaction Details:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${payment['transactionDetails']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 20),
                                if (payment['imageUrl'] != null)
                                  Image.network(payment['imageUrl']),
                              ],
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _updateStatus(
                                        userId, payment.id, 'Approve');
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      shadowColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      foregroundColor: Colors.white),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Mazzard'),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateStatus(userId, payment.id, 'Deny');
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      shadowColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      foregroundColor: Colors.white),
                                  child: const Text(
                                    'Deny',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Mazzard'),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
      String userId, String transactionId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .update({'status': status});
    } catch (e) {
      print('Error updating status: $e');
    }
  }
}
