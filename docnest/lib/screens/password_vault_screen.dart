import 'package:flutter/material.dart';

class PasswordVaultScreen extends StatefulWidget {
  const PasswordVaultScreen({Key? key}) : super(key: key);

  @override
  _PasswordVaultScreenState createState() => _PasswordVaultScreenState();
}

class __PasswordVaultScreenState extends State<PasswordVaultScreen> {
  final List<Map<String, String>> _passwords = [
    {'title': 'Google', 'username': 'user@gmail.com', 'password': 'password123'},
    {'title': 'Facebook', 'username': 'user@facebook.com', 'password': 'facebook_pass'},
  ];

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Vault'),
      ),
      body: ListView.builder(
        itemCount: _passwords.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: Text(_passwords[index]['title']!),
              subtitle: Text(_passwords[index]['username']!),
              trailing: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'password_vault_fab',
        onPressed: () => _showAddPasswordDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPasswordDialog(BuildContext context) {
    final titleController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _passwords.add({
                    'title': titleController.text,
                    'username': usernameController.text,
                    'password': passwordController.text,
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}