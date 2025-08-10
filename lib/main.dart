// main.dart (Firebase-integrated version for Passenger login & dashboard)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'admin_login.dart';
import 'reg_passenger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BusFareApp());
}

class BusFareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Fare Collection',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

const adminUsername = 'admin';
const adminPassword = '1234';

Future<DocumentSnapshot<Map<String, dynamic>>?> fetchPassenger(String username) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('passengers').doc(username).get();
    if (doc.exists) {
      return doc;
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching passenger: $e');
    return null;
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF), // Soft light background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Bus Icon
              Icon(
                Icons.directions_bus_filled,
                size: 90,
                color: Colors.deepPurple,
              ),

              SizedBox(height: 20),

              // Title
              Text(
                'Bus Fare Collection',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              SizedBox(height: 40),

              // Passenger Button
              _buildHomeButton(
                context,
                icon: Icons.person,
                label: 'Passenger',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PassengerLoginScreen()),
                  );
                },
              ),

              SizedBox(height: 16),

              // Admin Button
              _buildHomeButton(
                context,
                icon: Icons.admin_panel_settings,
                label: 'Admin',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminLoginScreen()),
                  );
                },
              ),

              SizedBox(height: 16),

              // Register Button
              _buildHomeButton(
                context,
                icon: Icons.app_registration,
                label: 'Register New Passenger',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPassengerScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable styled button
  Widget _buildHomeButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: 260,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class PassengerLoginScreen extends StatefulWidget {
  @override
  _PassengerLoginScreenState createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends State<PassengerLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

void _login() async {
  setState(() {
    _error = null;
    _loading = true;
  });

  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  final doc = await fetchPassenger(username);

  if (doc != null) {
    final data = doc.data()!;
    
    // Convert Firestore value to String just in case it's stored as int
    if (data['password'].toString().trim() == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => PassengerDashboard(username: username)),
      );
    } else {
      setState(() {
        _error = 'Invalid credentials';
        _loading = false;
      });
    }
  } else {
    setState(() {
      _error = 'User not found';
      _loading = false;
    });
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF7F4FF),
    appBar: AppBar(
      title: const Text('Passenger Login'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (_error != null)
            Text(_error!, style: TextStyle(color: Colors.red)),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 30),
          _loading
              ? const CircularProgressIndicator()
              : SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: _login,
    icon: Icon(Icons.login, color: Colors.white),
    label: Text('Login'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white, // for text and icon color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
),
        ],
      ),
    ),
  );
}
}

class PassengerDashboard extends StatefulWidget {
  final String username;
  PassengerDashboard({required this.username});

  @override
  _PassengerDashboardState createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  late DocumentReference passengerDoc;
  Map<String, dynamic>? passengerData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    passengerDoc = FirebaseFirestore.instance
        .collection('passengers')
        .doc(widget.username);
    _loadPassengerData();
  }

  Future<void> _loadPassengerData() async {
    final doc = await passengerDoc.get();
    if (doc.exists) {
      setState(() {
passengerData = doc.data() as Map<String, dynamic>?;
        _loading = false;
      });
    }
  }

  Future<void> _tapToPay() async {
    if (passengerData == null) return;

    double balance = (passengerData!['balance'] as num).toDouble();
    List<dynamic> history = passengerData!['history'] ?? [];
    final timestamp = DateTime.now().toLocal().toString().split('.').first;
    if (balance >= 20.0) {
      balance -= 20.0;     
      history.add('Fare Deducted: Rs 20 at $timestamp');
      await passengerDoc.update({
        'balance': balance,
        'history': history,
      });
      setState(() {
        passengerData!['balance'] = balance;
        passengerData!['history'] = history;
      });
    } else {
      history.add('Insufficient Balance at $timestamp');
      await passengerDoc.update({'history': history});
      setState(() {
        passengerData!['history'] = history;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient Balance! Please recharge.')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  if (_loading) {
    return Scaffold(
      appBar: AppBar(title: Text('Loading...')),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  final passenger = passengerData!;
  return Scaffold(
    backgroundColor: Color(0xFFF7F4FF),
    appBar: AppBar(
      title: Text('Welcome, ${passenger['name']}'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (_) => false,
            );
          },
        ),
      ],
    ),
body: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  child: Column(
    children: [
      // Centered Card Info
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.credit_card, size: 40, color: Colors.deepPurple),
              SizedBox(height: 10),
              Text(
                'Card ID: ${passenger['cardId']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              Text(
                'Balance: Rs ${(passenger['balance'] as num).toDouble().toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]),
              ),
            ],
          ),
        ),
      ),

      // Tap to Pay Button (Unchanged)
      Center(
        child: ElevatedButton.icon(
          onPressed: _tapToPay,
          icon: Icon(Icons.credit_card, color: Colors.white),
          label: Text('Tap to Pay (Rs 20)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),

      SizedBox(height: 30),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      SizedBox(height: 10),

      // Styled History List
      Expanded(
        child: ListView.builder(
          itemCount: (passenger['history'] as List<dynamic>).length,
          reverse: true,
          itemBuilder: (context, index) {
            final log = passenger['history'][index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.deepPurple),
                title: Text(log.toString(), style: TextStyle(fontSize: 14)),
              ),
            );
          },
        ),
      ),
    ],
  ),
),

   /* body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card ID and Balance Display
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card ID: ${passenger['cardId']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('Balance: Rs ${(passenger['balance'] as num).toDouble().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Tap to Pay Button
          Center(
            child: ElevatedButton.icon(
              onPressed: _tapToPay,
              icon: Icon(Icons.credit_card, color: Colors.white),
              label: Text('Tap to Pay (Rs 20)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),

          SizedBox(height: 30),
          Text('Transaction History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Expanded(
  child: ListView.builder(
    itemCount: (passenger['history'] as List<dynamic>).length,
    itemBuilder: (context, index) {
      final reversedHistory = (passenger['history'] as List<dynamic>).reversed.toList();
      final log = reversedHistory[index];
      return ListTile(
        leading: Icon(Icons.history, color: Colors.deepPurple),
        title: Text(log.toString()),
      );
    },
  ),
),
      
        ],
      ),
    ),*/
  );
}
}





