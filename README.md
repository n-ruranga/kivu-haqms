# KIVU Hospital Appointment & Queue Management System

Flutter mobile app for booking hospital appointments and tracking queue status in Rwanda's public healthcare system.

## Team

| Member | Module |
|--------|--------|
| Duke | Auth & onboarding |
| Jabes | Architecture, home & navigation |
| Kethia | Appointment booking |
| Naillah | Queue & profile |
| Aderline | QA & documentation |

## Project structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp + theme + router
├── core/
│   ├── constants/            # Colors, strings, route paths
│   ├── router/               # GoRouter configuration
│   ├── theme/                # AppTheme (Inter font, KIVU colors)
│   └── widgets/              # Shared widgets (logo, bottom nav, placeholders)
└── features/
    ├── auth/presentation/pages/       # Duke
    ├── home/presentation/             # Jabes
    ├── schedule/presentation/pages/     # Naillah
    ├── doctors/presentation/pages/      # Kethia
    ├── profile/presentation/pages/      # Naillah
    └── shell/presentation/pages/        # Bottom-nav shell
```

Each feature follows **clean architecture** folders. Add `domain/` and `data/` subfolders inside your feature as you connect Firebase.

## Getting started

```bash
flutter pub get
flutter run
```

## Navigation flow (current)

1. **Login** → placeholder (Duke)
2. **Verify OTP** → placeholder (Duke)
3. **Home** → dashboard with bottom navigation
4. Tabs: Home · Schedule · Doctors · Profile

## State management

[BLoC](https://pub.dev/packages/flutter_bloc) is included. Add Cubits/Blocs inside each feature's `presentation/` folder as you connect Firebase.

## Dependencies

- `go_router` — navigation
- `flutter_bloc` + `equatable` — state management
- `google_fonts` — Inter typography
