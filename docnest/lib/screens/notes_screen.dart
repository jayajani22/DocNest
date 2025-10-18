import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notes = [
      {'title': 'Meeting Notes', 'content': 'Discussed the new project timeline.'},
      {'title': 'Shopping List', 'content': 'Milk, Bread, Eggs.'},
      {'title': 'Ideas', 'content': 'A new app for tracking habits.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(notes[index]['title']!),
              subtitle: Text(notes[index]['content']!),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}