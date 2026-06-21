import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../widgets/note_card.dart';
import 'note_form_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<NoteProvider>().deleteNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              notes.setSearchQuery(value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        notes.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _FilterChip(
                label: 'All',
                selected: notes.filterCategory == null,
                onSelected: () => notes.setFilterCategory(null),
              ),
              ...NoteCategory.values.map(
                (cat) => _FilterChip(
                  label: cat.label,
                  selected: notes.filterCategory == cat,
                  onSelected: () => notes.setFilterCategory(cat),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: notes.notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        notes.searchQuery.isNotEmpty ||
                                notes.filterCategory != null
                            ? 'No notes match your filters'
                            : 'No notes yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: notes.notes.length,
                  itemBuilder: (context, index) {
                    final note = notes.notes[index];
                    return NoteCard(
                      note: note,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteFormScreen(note: note),
                          ),
                        );
                      },
                      onToggleComplete: () => notes.toggleComplete(note),
                      onDelete: () => _confirmDelete(note),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
