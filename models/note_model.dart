enum NoteCategory { personal, study, work }

enum NotePriority { high, medium, low }

enum RepeatType { none, daily, weekly }

class Note {
  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category = NoteCategory.personal,
    this.priority = NotePriority.medium,
    this.reminderDateTime,
    this.repeatType = RepeatType.none,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  String title;
  String content;
  NoteCategory category;
  NotePriority priority;
  DateTime? reminderDateTime;
  RepeatType repeatType;
  bool isCompleted;
  final DateTime createdAt;
  DateTime updatedAt;

  bool get hasReminder => reminderDateTime != null;

  bool get isPending =>
      hasReminder && !isCompleted && reminderDateTime!.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'category': category.index,
        'priority': priority.index,
        'reminderDateTime': reminderDateTime?.toIso8601String(),
        'repeatType': repeatType.index,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: NoteCategory.values[json['category'] as int? ?? 0],
        priority: NotePriority.values[json['priority'] as int? ?? 1],
        reminderDateTime: json['reminderDateTime'] != null
            ? DateTime.parse(json['reminderDateTime'] as String)
            : null,
        repeatType: RepeatType.values[json['repeatType'] as int? ?? 0],
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    NotePriority? priority,
    DateTime? reminderDateTime,
    RepeatType? repeatType,
    bool? isCompleted,
    DateTime? updatedAt,
    bool clearReminder = false,
  }) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      reminderDateTime:
          clearReminder ? null : (reminderDateTime ?? this.reminderDateTime),
      repeatType: repeatType ?? this.repeatType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension NoteCategoryX on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.personal:
        return 'Personal';
      case NoteCategory.study:
        return 'Study';
      case NoteCategory.work:
        return 'Work';
    }
  }
}

extension NotePriorityX on NotePriority {
  String get label {
    switch (this) {
      case NotePriority.high:
        return 'High';
      case NotePriority.medium:
        return 'Medium';
      case NotePriority.low:
        return 'Low';
    }
  }
}

extension RepeatTypeX on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.none:
        return 'None';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
    }
  }
}
