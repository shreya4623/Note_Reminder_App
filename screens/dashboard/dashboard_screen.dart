import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/stat_card.dart';
import '../notes/note_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notes = context.watch<NoteProvider>();
    final dateFormat = DateFormat('MMM d, h:mm a');

    return RefreshIndicator(
      onRefresh: () async {
        if (auth.user != null) {
          await notes.loadNotes(auth.user!.id);
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    auth.user?.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              delegate: SliverChildListDelegate([
                StatCard(
                  title: 'Total Notes',
                  count: notes.totalNotesCount,
                  icon: Icons.note_alt_outlined,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Pending Reminders',
                  count: notes.pendingRemindersCount,
                  icon: Icons.alarm,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Completed Tasks',
                  count: notes.completedTasksCount,
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                StatCard(
                  title: 'Upcoming',
                  count: notes.upcomingReminders.length,
                  icon: Icons.upcoming_outlined,
                  color: Colors.purple,
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Reminders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NoteFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Note'),
                  ),
                ],
              ),
            ),
          ),
          if (notes.upcomingReminders.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming reminders',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = notes.upcomingReminders[index];
                  return _UpcomingReminderTile(
                    note: note,
                    dateFormat: dateFormat,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NoteFormScreen(note: note),
                        ),
                      );
                    },
                    onComplete: () => notes.toggleComplete(note),
                  );
                },
                childCount: notes.upcomingReminders.length.clamp(0, 5),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _UpcomingReminderTile extends StatelessWidget {
  const _UpcomingReminderTile({
    required this.note,
    required this.dateFormat,
    required this.onTap,
    required this.onComplete,
  });

  final Note note;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(
            Icons.alarm,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(dateFormat.format(note.reminderDateTime!)),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: onComplete,
          tooltip: 'Mark complete',
        ),
      ),
    );
  }
}
