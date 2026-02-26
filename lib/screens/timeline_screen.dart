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
      final allNoteTags = await DatabaseHelper.instance.getAllNotesTags();

      if (!mounted) return;
      setState(() {
        _notes = notes;
        _noteTags = allNoteTags;
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
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create your first note',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotes,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Dismissible(
                        key: Key(note.id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          await DatabaseHelper.instance.deleteNote(note.id!);
                          _loadNotes();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Note deleted')),
                            );
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: NoteCard(
                          key: ValueKey(note.id),
                          note: note,
                          onFavoriteToggle: () => _toggleFavorite(note),
                          tags: note.id != null ? _noteTags[note.id!] ?? [] : [],
                        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Already on timeline screen
              },
            ),
            const SizedBox(width: 48), // Space for FAB
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
      ),
    );
  }
}
