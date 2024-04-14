import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart'; // Import your login page file
import 'session.dart'; // Import your session file

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _register();
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    final String firstName = firstNameController.text;
    final String lastName = lastNameController.text;
    final String phone = phoneController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    final url =
        Uri.parse('http://127.0.0.1:3000/users'); // Change to your API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // Registration successful
      print('Registration successful');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()), // Navigate to login page
      );
    } else {
      // Registration failed
      final Map<String, dynamic> error = jsonDecode(response.body);
      print('Registration failed: ${error["error"]}');
      // You can show an error message to the user here
    }
  }
}
