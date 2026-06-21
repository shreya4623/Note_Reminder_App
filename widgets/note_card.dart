import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  Color _priorityColor(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return Colors.red;
      case NotePriority.medium:
        return Colors.orange;
      case NotePriority.low:
        return Colors.green;
    }
  }

  Color _categoryColor(NoteCategory category) {
    switch (category) {
      case NoteCategory.personal:
        return Colors.blue;
      case NoteCategory.study:
        return Colors.purple;
      case NoteCategory.work:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onToggleComplete,
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      note.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: note.isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: note.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        decoration: note.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(
                    label: note.category.label,
                    color: _categoryColor(note.category),
                  ),
                  _Chip(
                    label: note.priority.label,
                    color: _priorityColor(note.priority),
                    icon: Icons.flag,
                  ),
                  if (note.hasReminder)
                    _Chip(
                      label: dateFormat.format(note.reminderDateTime!),
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.alarm,
                    ),
                  if (note.repeatType != RepeatType.none)
                    _Chip(
                      label: note.repeatType.label,
                      color: Colors.indigo,
                      icon: Icons.repeat,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
