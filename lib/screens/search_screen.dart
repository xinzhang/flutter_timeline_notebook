import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';

class SearchScreen extends StatefulWidget {
  final List<Note> allNotes;
  final Map<int, List<String>> noteTags;

  const SearchScreen({
    Key? key,
    required this.allNotes,
    this.noteTags = const {},
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Note> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _filteredNotes = widget.allNotes;
  }

  void _filterNotes(String query) {
    setState(() {
      _filteredNotes = widget.allNotes.where((note) {
        final matchesQuery = query.isEmpty ||
            note.content.toLowerCase().contains(query.toLowerCase());
        return matchesQuery;
      }).toList();
    });
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
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          onChanged: _filterNotes,
        ),
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text('No notes found'))
          : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return NoteCard(
                  note: note,
                  tags: note.id != null ? widget.noteTags[note.id!] ?? [] : [],
                );
              },
            ),
    );
  }
}
