
import 'package:docnest/api/api_service.dart';
import 'package:flutter/material.dart';

class PasswordVaultScreen extends StatefulWidget {
  const PasswordVaultScreen({Key? key}) : super(key: key);

  @override
  PasswordVaultScreenState createState() => PasswordVaultScreenState();
}

class PasswordVaultScreenState extends State<PasswordVaultScreen> {
  late Future<List<dynamic>> _passwordsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    setState(() {
      _passwordsFuture = apiService.fetchPasswords().then((data) => data ?? []);
    });
  }

  Future<void> _refreshPasswords() async {
    setState(() {
      _passwordsFuture = apiService.fetchPasswords().then((data) => data ?? []);
    });
  }

  void _addPassword() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final siteController = TextEditingController();
        final usernameController = TextEditingController();
        final passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: siteController,
                decoration: const InputDecoration(labelText: 'Site'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'site_name': siteController.text,
                  'username': usernameController.text,
                  'password': passwordController.text,
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        await apiService.addPassword(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password added successfully')),
        );
        await _loadPasswords(); // refresh list safely
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _deletePassword(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await apiService.deletePassword(id);
      await _loadPasswords(); // Refresh passwords after deleting
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditDialog(Map<String, dynamic> password) {
    final siteNameController = TextEditingController(text: password['site_name']);
    final usernameController = TextEditingController(text: password['username']);
    final passwordController = TextEditingController(text: password['password']);
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Password'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: siteNameController,
                  decoration: const InputDecoration(labelText: 'Site Name'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () => setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  "site_name": siteNameController.text,
                  "username": usernameController.text,
                  "password": passwordController.text,
                };
                try {
                  await apiService.updatePassword(password['id'], updatedData);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully!')),
                  );
                  _refreshPasswords(); // reload updated data
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating password: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Vault'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _passwordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final passwords = snapshot.data!;
                  if (passwords.isEmpty) {
                    return const Center(child: Text('No passwords found.'));
                  }
                  return ListView.builder(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final password = passwords[index];
                      return PasswordCard(
                        password: password,
                        onDelete: () => _deletePassword(password['id']!),
                        onEdit: () => _showEditDialog(password),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No passwords found.'));
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'passwords_fab',
        onPressed: _addPassword,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PasswordCard extends StatefulWidget {
  final Map<String, dynamic> password;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PasswordCard({Key? key, required this.password, required this.onDelete, required this.onEdit}) : super(key: key);

  @override
  _PasswordCardState createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final siteName = widget.password['site_name'] ?? 'No Site Name';
    final username = widget.password['username'] ?? 'No Username';
    final password = widget.password['password'] ?? '';

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(siteName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text('Username: $username'),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Password: ${_isPasswordVisible ? password : '********'}',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
