import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../providers/note_provider.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  late NoteCategory _category;
  late NotePriority _priority;
  DateTime? _reminderDateTime;
  RepeatType _repeatType = RepeatType.none;
  bool _enableReminder = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _category = note?.category ?? NoteCategory.personal;
    _priority = note?.priority ?? NotePriority.medium;
    _reminderDateTime = note?.reminderDateTime;
    _repeatType = note?.repeatType ?? RepeatType.none;
    _enableReminder = note?.hasReminder ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? now),
    );
    if (time == null || !mounted) return;

    setState(() {
      _reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<NoteProvider>();
    final reminder = _enableReminder ? _reminderDateTime : null;

    if (_isEditing) {
      final note = widget.note!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _category,
        priority: _priority,
        reminderDateTime: reminder,
        repeatType: _enableReminder ? _repeatType : RepeatType.none,
        clearReminder: !_enableReminder,
      );
      await provider.updateNote(note);
    } else {
      await provider.createNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _category,
        priority: _priority,
        reminderDateTime: reminder,
        repeatType: _enableReminder ? _repeatType : RepeatType.none,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Note title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Write your note here...',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<NoteCategory>(
              segments: NoteCategory.values
                  .map((c) => ButtonSegment(value: c, label: Text(c.label)))
                  .toList(),
              selected: {_category},
              onSelectionChanged: (set) {
                setState(() => _category = set.first);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<NotePriority>(
              segments: NotePriority.values
                  .map((p) => ButtonSegment(value: p, label: Text(p.label)))
                  .toList(),
              selected: {_priority},
              onSelectionChanged: (set) {
                setState(() => _priority = set.first);
              },
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Set Reminder'),
              subtitle: const Text('Get notified at a specific date & time'),
              value: _enableReminder,
              onChanged: (value) {
                setState(() {
                  _enableReminder = value;
                  if (value && _reminderDateTime == null) {
                    _reminderDateTime =
                        DateTime.now().add(const Duration(hours: 1));
                  }
                });
              },
            ),
            if (_enableReminder) ...[
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _reminderDateTime != null
                      ? dateFormat.format(_reminderDateTime!)
                      : 'Pick date & time',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Repeat',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<RepeatType>(
                segments: RepeatType.values
                    .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                    .toList(),
                selected: {_repeatType},
                onSelectionChanged: (set) {
                  setState(() => _repeatType = set.first);
                },
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isEditing ? 'Update Note' : 'Create Note'),
            ),
          ],
        ),
      ),
    );
  }
}
