import 'package:flutter/foundation.dart';

import '../models/note_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class NoteProvider extends ChangeNotifier {
  NoteProvider(this._db, this._notifications);

  final DatabaseService _db;
  final NotificationService _notifications;

  List<Note> _notes = [];
  String _searchQuery = '';
  NoteCategory? _filterCategory;
  String? _userId;

  List<Note> get notes => _filteredNotes;
  String get searchQuery => _searchQuery;
  NoteCategory? get filterCategory => _filterCategory;

  int get totalNotesCount => _notes.length;

  int get pendingRemindersCount => _notes
      .where((n) => n.hasReminder && !n.isCompleted && n.isPending)
      .length;

  int get completedTasksCount => _notes.where((n) => n.isCompleted).length;

  List<Note> get upcomingReminders => _notes
      .where((n) => n.hasReminder && !n.isCompleted)
      .where((n) => n.reminderDateTime!.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.reminderDateTime!.compareTo(b.reminderDateTime!));

  List<Note> get _filteredNotes {
    var result = _notes;

    if (_filterCategory != null) {
      result = result.where((n) => n.category == _filterCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(query) ||
              n.content.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  Future<void> loadNotes(String userId) async {
    _userId = userId;
    _notes = _db.getNotesForUser(userId);
    await _notifications.rescheduleAll(_notes);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(NoteCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  Future<void> createNote({
    required String title,
    required String content,
    NoteCategory category = NoteCategory.personal,
    NotePriority priority = NotePriority.medium,
    DateTime? reminderDateTime,
    RepeatType repeatType = RepeatType.none,
  }) async {
    if (_userId == null) return;

    final note = await _db.createNote(
      userId: _userId!,
      title: title,
      content: content,
      category: category,
      priority: priority,
      reminderDateTime: reminderDateTime,
      repeatType: repeatType,
    );

    _notes.insert(0, note);
    await _notifications.scheduleReminder(note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final updated = await _db.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notes[index] = updated;
    }
    await _notifications.scheduleReminder(updated);
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    await _notifications.cancelReminder(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> toggleComplete(Note note) async {
    await _db.toggleComplete(note);
    if (note.isCompleted) {
      await _notifications.cancelReminder(note.id);
    } else if (note.hasReminder) {
      await _notifications.scheduleReminder(note);
    }
    notifyListeners();
  }

  void clear() {
    _notes = [];
    _searchQuery = '';
    _filterCategory = null;
    _userId = null;
    notifyListeners();
  }
}
