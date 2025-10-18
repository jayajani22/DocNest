
import 'package:flutter/material.dart';
import 'package:docnest/screens/documents_screen.dart';
import 'package:docnest/screens/notes_screen.dart';
import 'package:docnest/screens/password_vault_screen.dart';
import 'package:docnest/screens/profile_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DocumentsScreen(),
    NotesScreen(),
    PasswordVaultScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.description),
                onPressed: () => _onItemTapped(0),
                color: _selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.note),
                onPressed: () => _onItemTapped(1),
                color: _selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
              ),
              const SizedBox(width: 40), // The space for the FAB
              IconButton(
                icon: const Icon(Icons.lock),
                onPressed: () => _onItemTapped(2),
                color: _selectedIndex == 2 ? Colors.deepPurple : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => _onItemTapped(3),
                color: _selectedIndex == 3 ? Colors.deepPurple : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
