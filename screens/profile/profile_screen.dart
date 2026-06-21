import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isEditingName = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final auth = context.read<AuthProvider>();
    final error = await auth.updateProfile(_nameController.text.trim());

    if (!mounted) return;

    if (error == null) {
      setState(() => _isEditingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final error = await auth.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      setState(() => _isChangingPassword = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              (user?.name.isNotEmpty == true ? user!.name[0] : 'U')
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: Icon(_isEditingName ? Icons.close : Icons.edit),
                      onPressed: () {
                        setState(() {
                          if (_isEditingName) {
                            _nameController.text = user?.name ?? '';
                          }
                          _isEditingName = !_isEditingName;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isEditingName) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saveName,
                    child: const Text('Save Name'),
                  ),
                ] else ...[
                  _InfoRow(label: 'Name', value: user?.name ?? ''),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Email', value: user?.email ?? ''),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Member Since',
                    value: user != null
                        ? '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                        : '',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change Password'),
                trailing: Icon(
                  _isChangingPassword
                      ? Icons.expand_less
                      : Icons.expand_more,
                ),
                onTap: () {
                  setState(() => _isChangingPassword = !_isChangingPassword);
                },
              ),
              if (_isChangingPassword)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Current Password',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _changePassword,
                        child: const Text('Update Password'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.storage,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Storage'),
            subtitle: const Text('Local storage (Hive database)'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
