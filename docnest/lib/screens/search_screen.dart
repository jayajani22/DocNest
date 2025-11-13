import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  // Dummy data for demonstration
  final List<Map<String, String>> _allData = [
    {'title': 'Document 1', 'type': 'document'},
    {'title': 'Note 1', 'type': 'note'},
    {'title': 'Password for site A', 'type': 'password'},
    {'title': 'Document 2', 'type': 'document'},
    {'title': 'Note 2', 'type': 'note'},
  ];
  List<Map<String, String>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = _allData;
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
        _filterData();
      });
    });
  }

  void _filterData() {
    if (_searchTerm.isEmpty) {
      _filteredData = _allData;
    } else {
      _filteredData = _allData
          .where((item) =>
              item['title']!.toLowerCase().contains(_searchTerm.toLowerCase()))
          .toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search for documents, notes, passwords...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final item = _filteredData[index];
                IconData icon;
                switch (item['type']) {
                  case 'document':
                    icon = Icons.article;
                    break;
                  case 'note':
                    icon = Icons.note;
                    break;
                  case 'password':
                    icon = Icons.lock;
                    break;
                  default:
                    icon = Icons.help;
                }
                return ListTile(
                  leading: Icon(icon),
                  title: Text(item['title']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
