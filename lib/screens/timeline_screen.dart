import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await DatabaseHelper.instance.getAllNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Note note) async {
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    await DatabaseHelper.instance.updateNote(updated);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('No notes yet. Tap + to create one!'))
              : RefreshIndicator(
                  onRefresh: _loadNotes,
                  child: ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return NoteCard(
                        note: note,
                        onFavoriteToggle: () => _toggleFavorite(note),
                      );
                    },
                  ),
                ),
    );
  }
}
