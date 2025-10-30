import 'package:docnest/api/api_service.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  late Future<List<dynamic>> _notesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _notesFuture = apiService.fetchNotes();
    });
  }

  void _addNote() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final contentController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
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
                  'title': titleController.text,
                  'content': contentController.text,
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await apiService.addNote(result['title']!, result['content']!);
        await _loadNotes(); // Refresh notes after adding
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
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
  }

  void _deleteNote(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await apiService.deleteNote(id);
      await _loadNotes(); // Refresh notes after deleting
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted successfully')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final notes = snapshot.data!;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(note: note, onDelete: () => _deleteNote(note['id']), onSave: _loadNotes);
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteCard extends StatefulWidget {
  final Map<String, dynamic> note;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const NoteCard({Key? key, required this.note, required this.onDelete, required this.onSave}) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title']);
    _contentController = TextEditingController(text: widget.note['content']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() async {
    try {
      await apiService.updateNote(widget.note['id'], _titleController.text, _contentController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
      widget.onSave();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditing
                ? TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  )
                : Text(widget.note['title']!, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            _isEditing
                ? TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: null,
                  )
                : Text(widget.note['content']!),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _updateNote,
                  ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
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