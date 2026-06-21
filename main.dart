import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/note_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.usersBox);
  await Hive.openBox<String>(AppConstants.notesBox);
  await Hive.openBox<String>(AppConstants.resetTokensBox);

  await NotificationService.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  final dbService = DatabaseService();

  runApp(
    NoteReminderApp(
      prefs: prefs,
      authService: authService,
      dbService: dbService,
    ),
  );
}

class NoteReminderApp extends StatelessWidget {
  const NoteReminderApp({
    super.key,
    required this.prefs,
    required this.authService,
    required this.dbService,
  });

  final SharedPreferences prefs;
  final AuthService authService;
  final DatabaseService dbService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteProvider(dbService, NotificationService.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, theme, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
