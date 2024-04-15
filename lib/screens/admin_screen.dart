import 'package:flutter/material.dart';
import 'package:senior_proj/components/app_loading_indicator.dart';
import 'package:senior_proj/extensions/nullable_extension.dart';
import 'package:senior_proj/models/service_provider_model.dart';
import 'package:senior_proj/services/service_providers_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  static const routeNamed = 'admin';
  static const route = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = true;
  List<ServiceProviderModel> _providers = [];

  @override
  void initState() {
    super.initState();

    _getServiceProviders();
  }

  Future<void> _getServiceProviders() async {
    await ServiceProvidersService.fetchServiceProviders(
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching service providers: $message'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onSuccess: (providers) => _providers = providers,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: ListView.builder(
        itemCount: _providers.length,
        itemBuilder: (context, index) {
          final provider = _providers[index];
          return ListTile(
            title: Text(
                'Name: ${provider.name.orEmpty} Email: ${provider.email.orEmpty}'),
            subtitle: Text(provider.role.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: provider.id == null
                  ? null
                  : () {
                      if (provider.id case final id?) {
                        showDeleteDialog(context, id);
                      }
                    },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<Widget>(
            context: context,
            builder: (_) => AdminDialogForm(
              onAddServiceProvider: (provider) {
                if (!mounted) return;
                setState(() {
                  _providers.add(provider);
                });
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showDeleteDialog(BuildContext context, int id) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this service provider?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ServiceProvidersService.deleteServiceProvider(
                id: id,
                onError: (message) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Error deleting service provider: $message'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                onSuccess: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service provider deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {
                    _providers.removeWhere((element) => element.id == id);
                  });

                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class AdminDialogForm extends StatefulWidget {
  const AdminDialogForm({super.key, this.onAddServiceProvider});

  final void Function(ServiceProviderModel provider)? onAddServiceProvider;

  @override
  State<AdminDialogForm> createState() => _AdminDialogFormState();
}

class _AdminDialogFormState extends State<AdminDialogForm> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  ServiceProviderRoleEnum _role = ServiceProviderRoleEnum.towTruck;

  @override
  void dispose() {
    nameController.dispose();

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onAddServiceProvider() async {
    _isLoading.value = true;

    final provider = ServiceProviderModel(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      role: _role.value,
    );

    await ServiceProvidersService.createServiceProvider(
      provider: provider,
      onError: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding service provider: $message'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onSuccess: () {
        if (!mounted) return;
        widget.onAddServiceProvider?.call(provider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service provider added'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      },
    );

    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
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
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          DropdownButtonFormField<ServiceProviderRoleEnum>(
            value: _role,
            onChanged: (ServiceProviderRoleEnum? value) {
              if (value case final type?) {
                _role = type;
              }
            },
            items: <ServiceProviderRoleEnum>[
              ServiceProviderRoleEnum.fuelDelivery,
              ServiceProviderRoleEnum.towTruck,
              ServiceProviderRoleEnum.mechanic,
              ServiceProviderRoleEnum.moto,
            ].map<DropdownMenuItem<ServiceProviderRoleEnum>>(
                (ServiceProviderRoleEnum value) {
              return DropdownMenuItem<ServiceProviderRoleEnum>(
                value: value,
                child: Text(value.name),
              );
            }).toList(growable: false),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: _isLoading,
          builder: (_, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return child ?? const SizedBox();
          },
          child: ElevatedButton(
            onPressed: onAddServiceProvider,
            child: const Text('Add'),
          ),
        ),
      ],
    );
  }
}
