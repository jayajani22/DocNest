import 'package:flutter/material.dart';
import '../api/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int docs = 0;
  int notes = 0;
  int passwords = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await apiService.fetchUserSummary();
      setState(() {
        docs = summary['documents'] ?? 0;
        notes = summary['notes'] ?? 0;
        passwords = summary['passwords'] ?? 0;
      });
    } catch (e) {
      debugPrint('Error fetching summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple,
              child: Text('A', style: TextStyle(fontSize: 32, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            const Text('Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('admin @docnest.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Documents', docs),
                _buildStat('Notes', notes),
                _buildStat('Passwords', passwords),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}