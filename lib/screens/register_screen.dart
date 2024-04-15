import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_proj/models/user_model.dart';
import 'package:senior_proj/screens/login_screen.dart';
import 'package:senior_proj/services/user_service.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const routeNamed = 'register';
  static const route = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _isLoading = false;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!mounted || _isLoading) return;
    setState(() {
      _isLoading = true;
    });

    await UserService.register(
      user: User(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        email: emailController.text,
        password: passwordController.text,
      ),
      onSuccess: () {
        context.replaceNamed(LoginScreen.routeNamed);
      },
      onError: (String message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to register: $message'),
        ));
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _onRegister,
            child: const Text('Register'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    context.replaceNamed(LoginScreen.routeNamed);
                  },
            child: const Text('Login'),
          )
        ],
      ),
    );
  }
}
