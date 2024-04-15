import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:senior_proj/extensions/nullable_extension.dart';
import 'package:senior_proj/models/user_model.dart';
import 'package:senior_proj/providers/session.dart';
import 'package:senior_proj/screens/admin_screen.dart';
import 'package:senior_proj/screens/employee_screen.dart';
import 'package:senior_proj/screens/register_screen.dart';
import 'package:senior_proj/screens/user_screen.dart';
import 'package:senior_proj/services/user_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeNamed = 'login';
  static const route = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => Session(), // Provide the Session object
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  LoginType _loginType = LoginType.user;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin(Session session) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email and password are required'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });

      return;
    }

    await UserService.login(
      email: emailController.text,
      password: passwordController.text,
      type: _loginType,
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
      onSuccess: (user) {
        final userId = user.id.str;
        session.setUserId(userId);

        if (!mounted) return;
        switch (_loginType) {
          case LoginType.admin:
            context.goNamed(AdminScreen.routeNamed);
            break;
          case LoginType.provider:
            context.goNamed(
              EmployeeScreen.routeNamed,
              pathParameters: {'id': userId},
            );
            break;
          case LoginType.user:
            context.goNamed(
              UserScreen.routeNamed,
              pathParameters: {'id': userId},
            );
        }
      },
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer<Session>(
          builder: (context, session, _) {
            return DropdownButtonFormField<LoginType>(
              value: _loginType,
              onChanged: (LoginType? value) {
                if (value case final type?) {
                  _loginType = type;
                }
              },
              items: <LoginType>[
                LoginType.user,
                LoginType.admin,
                LoginType.provider
              ].map<DropdownMenuItem<LoginType>>((LoginType value) {
                return DropdownMenuItem<LoginType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(growable: false),
            );
          },
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
          onPressed: _isLoading
              ? null
              : () {
                  _onLogin(context.read<Session>());
                },
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const Text('Login'),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            if (_isLoading) return;
            context.goNamed(RegisterScreen.routeNamed);
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
