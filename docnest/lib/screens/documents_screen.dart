import 'package:flutter/material.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> documents = [
      {'title': 'Paport.pdf', 'date': '2023-10-27'},
      {'title': 'Resume.docx', 'date': '2023-10-26'},
      {'title': 'Contract.pdf', 'date': '2023-10-25'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.description),
              title: Text(documents[index]['title']!),
              subtitle: Text(documents[index]['date']!),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'documents_fab',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}