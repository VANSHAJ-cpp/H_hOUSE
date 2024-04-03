import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Payment Check'),
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
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

  const PaymentItem({Key? key, required this.user}) : super(key: key);

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
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room No: $roomNo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            'Email: $email',
            style: TextStyle(
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
        title: Text('Payment History'),
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No payment history available.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var payment = snapshot.data!.docs[index];
              return ListTile(
                title: Text('Transaction ID: ${payment.id}'),
                subtitle: Text('Date: ${payment['timestamp'].toDate()}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Payment Details'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${payment['name']}'),
                              Text('Student ID: ${payment['studentID']}'),
                              Text(
                                  'Transaction Details: ${payment['transactionDetails']}'),
                              if (payment['imageUrl'] != null)
                                Image.network(payment['imageUrl']),
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
                },
              );
            },
          );
        },
      ),
    );
  }
}
