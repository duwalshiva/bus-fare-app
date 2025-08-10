import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  final CollectionReference passengersCollection =
      FirebaseFirestore.instance.collection('passengers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: passengersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final passengers = snapshot.data!.docs;

          if (passengers.isEmpty) {
            return Center(child: Text('No passengers found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: passengers.length,
            itemBuilder: (context, index) {
              final passenger = passengers[index].data() as Map<String, dynamic>;
              final docId = passengers[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassengerHistoryScreen(
                        name: passenger['name'],
                        username: docId,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passenger['name'],
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Username: $docId'),
                                  Text('Card ID: ${passenger['cardId']}'),
                                  Text(
                                    'Balance: Rs ${(passenger['balance'] as num).toDouble().toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.green[800]),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showTopUpDialog(context, docId, passenger),
                              icon: Icon(Icons.attach_money, color: Colors.green),
                              label: Text('Top Up', style: TextStyle(color: Colors.green)),
                            ),
                            TextButton.icon(
                              onPressed: () => _deletePassenger(context, docId),
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, String docId, Map<String, dynamic> passenger) {
    final _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Top Up Balance'),
        content: TextField(
          controller: _amountController,
          decoration: InputDecoration(labelText: 'Amount to Add'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Add'),
            onPressed: () async {
              final amount = double.tryParse(_amountController.text.trim());
              if (amount == null || amount <= 0) return;

              final ref = FirebaseFirestore.instance.collection('passengers').doc(docId);
              final doc = await ref.get();
              if (!doc.exists) return;

              final data = doc.data()!;
              double balance = (data['balance'] as num).toDouble();
              List<dynamic> history = data['history'] ?? [];

              final now = DateTime.now().toLocal().toString().split('.').first;
              history.add('[TOPUP] Rs $amount added at $now');

              await ref.update({
                'balance': balance + amount,
                'history': history,
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deletePassenger(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this passenger?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('passengers').doc(docId).delete();
    }
  }
}

class PassengerHistoryScreen extends StatelessWidget {
  final String name;
  final String username;

  const PassengerHistoryScreen({
    required this.name,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final DocumentReference passengerDoc = FirebaseFirestore.instance.collection('passengers').doc(username);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text('$name\'s History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: passengerDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final history = (data['history'] ?? []).reversed.toList();

          if (history.isEmpty) {
            return Center(child: Text('No history available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final log = history[index].toString();
              final isTopup = log.toLowerCase().contains('topup');

              return Card(
                color: isTopup ? Colors.green[100] : null,
                child: ListTile(
                  leading: Icon(Icons.history, color: Colors.deepPurple),
                  title: Text(log),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
