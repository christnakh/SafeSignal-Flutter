import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceProvider {
  final int id;
  final String name;
  final String email;
  final String role;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  List<ServiceProvider> providers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          return ListTile(
            title: Text(provider.name),
            subtitle: Text(provider.email),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => confirmDelete(context, provider.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add Service Provider'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: roleController,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: addServiceProvider,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> fetchServiceProviders() async {
    final url = Uri.parse('http://192.168.1.103:3000/service_providers');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        providers = data
            .map((json) => ServiceProvider(
                  id: json['id'],
                  name: json['name'],
                  email: json['email'],
                  role: json['role'],
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to fetch service providers');
    }
  }

  Future<void> addServiceProvider() async {
    final url = Uri.parse('http://192.168.1.103:3000/service_providers');
    final response = await http.post(
      url,
      body: {
        'provider_name': nameController.text,
        'email': emailController.text,
        'role': roleController.text,
      },
    );
    if (response.statusCode == 201) {
      await fetchServiceProviders();
      Navigator.of(context).pop();
    } else {
      throw Exception('Failed to add service provider');
    }
  }

  Future<void> deleteServiceProvider(int id) async {
    final url = Uri.parse('http://192.168.1.103:3000/service_providers/$id');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      await fetchServiceProviders();
    } else {
      throw Exception('Failed to delete service provider');
    }
  }

  Future<void> confirmDelete(BuildContext context, int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this service provider?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteServiceProvider(id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }
}
