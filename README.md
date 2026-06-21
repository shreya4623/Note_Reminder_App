# Note Reminder App

A full-featured Flutter note and reminder application with secure authentication, local storage, and push notifications.

## Features

### Authentication
- User registration and login
- Forgot password with secure reset tokens
- SHA-256 password hashing with salt
- Session persistence

### Dashboard
- Welcome screen with user name
- Total notes, pending reminders, and completed tasks counts
- Upcoming reminders overview

### Notes Management
- Create, edit, delete, and view notes
- Search notes by title or content
- Category tags: Personal, Study, Work
- Priority levels: High, Medium, Low
- Filter notes by category

### Reminders
- Set date and time reminders
- Local notification alerts
- Repeat reminders (Daily / Weekly)
- Mark reminders as completed

### Additional
- Dark / Light mode toggle
- Profile management (edit name, change password)
- Local Hive database storage
- Responsive Material 3 UI

## Getting Started

### Prerequisites
- Flutter SDK 3.9+
- Android Studio / VS Code with Flutter extension

### Run the App

```bash
cd note_reminder_app
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Note, User)
├── providers/                # State management (Provider)
├── services/                 # Auth, Database, Notifications
├── screens/                  # UI screens
│   ├── auth/                 # Login, Register, Forgot Password
│   ├── dashboard/            # Dashboard with stats
│   ├── home/                 # Main navigation shell
│   ├── notes/                # Notes list & form
│   └── profile/              # Profile & settings
├── widgets/                  # Reusable UI components
└── utils/                    # Theme & constants
```

## Tech Stack

| Feature | Package |
|---------|---------|
| State Management | provider |
| Local Database | hive, hive_flutter |
| Notifications | flutter_local_notifications |
| Password Security | crypto (SHA-256) |
| Session | shared_preferences |

## Storage

This app uses **Hive** for local offline storage. All user data and notes are stored on-device. No internet connection required.

To migrate to Firebase later, replace `DatabaseService` and `AuthService` with Firebase equivalents.

## License

MIT
