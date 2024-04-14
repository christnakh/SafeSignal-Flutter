import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'admin_page.dart';
import 'employee_page.dart';
import 'user_pages.dart';
import 'session.dart'; // Import your session file

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => Session(), // Provide the Session object
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _loginType = 'user'; // Default login type is user
  bool _isLoading = false;

  Future<void> _login(Session session) async {
    setState(() {
      _isLoading = true;
    });

    final String email = emailController.text;
    final String password = passwordController.text;

    String loginRoute = "/login"; // Default login route

    if (_loginType == 'admin') {
      loginRoute = "/loginadmin";
    } else if (_loginType == 'provider') {
      loginRoute = "/provider/login";
    }

    final url = Uri.parse("http://192.168.1.103:3000$loginRoute");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Success: ${data["message"]}');

        session.setUserId(data['userId'].toString());

        if (_loginType == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        } else if (_loginType == 'provider') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmployeePage()),
          );
        } else {
          // Inside the _login function where you navigate to UserPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(userId: data['userId'].toString()),
            ),
          );
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print('Error: ${errorData["error"]}');
        // Handle error
  
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData["error"])),
        );
      }
    } catch (e) {
      print('Exception: $e');
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<Session>(
            builder: (context, session, _) => DropdownButtonFormField<String>(
              value: _loginType,
              onChanged: (String? value) {
                setState(() {
                  _loginType = value!;
                });
              },
              items: <String>['user', 'admin', 'provider']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
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
            onPressed:
                _isLoading ? null : () => _login(context.read<Session>()),
            child: _isLoading ? CircularProgressIndicator() : Text('Login'),
          ),
        ],
      ),
    );
  }
}
