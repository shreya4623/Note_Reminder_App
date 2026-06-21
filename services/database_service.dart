import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/note_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static const _uuid = Uuid();

  Box<String> get _notesBox => Hive.box<String>(AppConstants.notesBox);

  List<Note> getNotesForUser(String userId) {
    return _notesBox.values
        .map((json) => Note.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .where((note) => note.userId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Note? getNoteById(String id) {
    final json = _notesBox.get(id);
    if (json == null) return null;
    return Note.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<Note> createNote({
    required String userId,
    required String title,
    required String content,
    NoteCategory category = NoteCategory.personal,
    NotePriority priority = NotePriority.medium,
    DateTime? reminderDateTime,
    RepeatType repeatType = RepeatType.none,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      content: content,
      category: category,
      priority: priority,
      reminderDateTime: reminderDateTime,
      repeatType: repeatType,
      createdAt: now,
      updatedAt: now,
    );
    await _saveNote(note);
    return note;
  }

  Future<Note> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    await _saveNote(note);
    return note;
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<void> toggleComplete(Note note) async {
    note.isCompleted = !note.isCompleted;
    note.updatedAt = DateTime.now();
    await _saveNote(note);
  }

  Future<void> _saveNote(Note note) async {
    await _notesBox.put(note.id, jsonEncode(note.toJson()));
  }

  List<Note> searchNotes(String userId, String query) {
    final lowerQuery = query.toLowerCase();
    return getNotesForUser(userId).where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Note> filterByCategory(String userId, NoteCategory? category) {
    final notes = getNotesForUser(userId);
    if (category == null) return notes;
    return notes.where((n) => n.category == category).toList();
  }
}
