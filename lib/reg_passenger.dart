import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPassengerScreen extends StatefulWidget {
  @override
  _RegisterPassengerScreenState createState() => _RegisterPassengerScreenState();
}

class _RegisterPassengerScreenState extends State<RegisterPassengerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  // Admin credentials
  final _adminUserController = TextEditingController();
  final _adminPassController = TextEditingController();
  bool isAdminAuthenticated = false;

  // Passenger fields
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cardIdController = TextEditingController();
  final _balanceController = TextEditingController();

  String? _error;
  bool _loading = false;

  final String adminUsername = 'admin';
  final String adminPassword = '1234';

  void _authenticateAdmin() {
    final username = _adminUserController.text.trim();
    final password = _adminPassController.text.trim();

    if (username == adminUsername && password == adminPassword) {
      setState(() {
        isAdminAuthenticated = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = 'Invalid admin credentials';
      });
    }
  }

  Future<void> _registerPassenger() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final username = _usernameController.text.trim();
    final data = {
      'name': _nameController.text.trim(),
      'password': _passwordController.text.trim(),
      'cardId': _cardIdController.text.trim(),
      'balance': double.tryParse(_balanceController.text.trim()) ?? 0.0,
      'history': [],
    };

    try {
      final docRef = FirebaseFirestore.instance.collection('passengers').doc(username);
      final existing = await docRef.get();

      if (existing.exists) {
        setState(() {
          _error = 'Username already exists';
          _loading = false;
        });
        return;
      }

      await docRef.set(data);
      Navigator.pop(context); // back to HomeScreen
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text('Register Passenger'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isAdminAuthenticated
            ? _buildPassengerForm()
            : _buildAdminLogin(),
      ),
    );
  }

  Widget _buildAdminLogin() {
  return Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(Icons.admin_panel_settings_rounded, size: 100, color: Colors.deepPurple),
          SizedBox(height: 10),
          Text(
            'Admin Authentication Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _adminFormKey,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
                      ],
                    ),
                    child: TextFormField(
                      controller: _adminUserController,
                      decoration: InputDecoration(
                        hintText: 'Admin Username',
                        prefixIcon: Icon(Icons.person),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter admin username' : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
                      ],
                    ),
                    child: TextFormField(
                      controller: _adminPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Admin Password',
                        prefixIcon: Icon(Icons.lock),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter admin password' : null,
                    ),
                  ),
                  SizedBox(height: 30),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.login, color: Colors.white),
                      label: Text('Authenticate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      onPressed: () {
                        if (_adminFormKey.currentState!.validate()) {
                          _authenticateAdmin();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildPassengerForm() {
  return Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(_error!, style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        _buildInputField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: (value) =>
              value!.isEmpty ? 'Enter passenger name' : null,
        ),
        _buildInputField(
          controller: _usernameController,
          label: 'Username (Unique)',
          icon: Icons.alternate_email,
          validator: (value) =>
              value!.isEmpty ? 'Enter unique username' : null,
        ),
        _buildInputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock,
          obscureText: true,
          validator: (value) => value!.isEmpty ? 'Enter password' : null,
        ),
        _buildInputField(
          controller: _cardIdController,
          label: 'Card ID',
          icon: Icons.credit_card,
          validator: (value) => value!.isEmpty ? 'Enter card ID' : null,
        ),
        _buildInputField(
          controller: _balanceController,
          label: 'Starting Balance',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Enter initial balance' : null,
        ),
        const SizedBox(height: 30),
        _loading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon( icon: Icon(Icons.how_to_reg, color: Colors.white),
                       label: Text('Register',style: TextStyle(color: Colors.white), // 👈 Make sure this is white
                                 ),
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      _registerPassenger();
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white, // 👈 This also ensures icon + ripple are white
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
)

              ),
      ],
    ),
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? Function(String?)? validator,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Color(0xFFF4F4FC),
      ),
    ),
  );
}

}
