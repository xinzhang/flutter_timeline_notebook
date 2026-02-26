import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'compose_screen.dart';
import 'search_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Note> _notes = [];
  Map<int, List<String>> _noteTags = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final notes = await DatabaseHelper.instance.getAllNotes();
      final noteTags = <int, List<String>>{};

      for (final note in notes) {
        if (note.id != null) {
          final tags = await DatabaseHelper.instance.getTagsForNote(note.id!);
          noteTags[note.id!] = tags.map((tag) => tag.name).toList();
        }
      }

      if (!mounted) return;
      setState(() {
        _notes = notes;
        _noteTags = noteTags;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Error could be shown in a SnackBar if needed
    }
  }

  Future<void> _toggleFavorite(Note note) async {
    try {
      final updated = note.copyWith(isFavorite: !note.isFavorite);
      await DatabaseHelper.instance.updateNote(updated);

      if (!mounted) return;

      // Update local state instead of full reload for better performance
      setState(() {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = updated;
        }
      });
    } catch (e) {
      // Error could be shown in a SnackBar if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(allNotes: _notes, noteTags: _noteTags),
                ),
              );
            },
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
                        key: ValueKey(note.id),
                        note: note,
                        onFavoriteToggle: () => _toggleFavorite(note),
                        tags: note.id != null ? _noteTags[note.id!] ?? [] : [],
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComposeScreen()),
          );
          if (result == true && mounted) {
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
