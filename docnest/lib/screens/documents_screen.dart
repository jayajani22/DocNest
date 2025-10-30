import 'package:docnest/api/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  DocumentsScreenState createState() => DocumentsScreenState();
}

class DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<dynamic>> _documentsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _documentsFuture = apiService.fetchDocuments();
    });
  }

  void _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        Uint8List fileBytes = result.files.single.bytes!;
        String fileName = result.files.single.name;

        await apiService.uploadDocument(fileName, fileName, fileBytes);

        await _loadDocuments(); // Refresh documents after upload
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected or file is empty.')),
      );
    }
  }

  Future<void> _deleteDocument(int id) async {
    try {
      await apiService.deleteDocument(id);
      await _loadDocuments(); // Refresh documents after delete
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadDocument,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _documentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final documents = snapshot.data!;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(document['name'] ?? 'No name'),
                          subtitle: Text(document['uploaded_at'] ?? ''),
                          onTap: () => apiService.openDocument(document['file']),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'open',
                                child: Text('Open'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'open') {
                                apiService.openDocument(document['file']);
                              } else if (value == 'delete') {
                                _deleteDocument(document['id']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'documents_fab',
        onPressed: _uploadDocument,
        child: const Icon(Icons.add),
      ),
    );
  }
}