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
├── main.dart
├── app.dart                          # BlocProvider + MaterialApp.router
├── core/
│   ├── constants/
│   ├── router/                       # GoRouter + auth redirects
│   ├── theme/
│   └── widgets/
└── features/
    ├── auth/
    │   ├── domain/                   # UserEntity + AuthRepository contract
    │   ├── data/                     # StubAuthRepository (Duke → Firebase)
    │   └── presentation/
    │       ├── cubit/                # AuthCubit + AuthState
    │       └── pages/                # Login, OTP, Sign up
    ├── home/                         # Dashboard (Jabes)
    ├── schedule/                     # Naillah — domain/ + data/ ready
    ├── doctors/                      # Kethia — domain/ + data/ ready
    ├── profile/                      # Naillah — domain/ + data/ ready
    └── shell/
```

## Getting started

```bash
flutter pub get
flutter run
```

## Navigation flow

1. **Login** → Continue → **OTP**
2. **Verify & Login** → `AuthCubit.completeDemoLogin()` → redirect to **Home**
3. Tabs: Home · Schedule · Doctors · Profile
4. **Profile → Sign out** → redirect back to Login

Auth redirects are handled in `AppRouter` — pages do not call `context.go('/home')` after login.

## State management (BLoC / Cubit)

We use **Cubit** (from `flutter_bloc`) so UI stays free of business logic.

| Layer | Responsibility | Example |
|-------|----------------|---------|
| `presentation/` | Cubits + pages/widgets | `AuthCubit` |
| `domain/` | Entities + repository interfaces | `AuthRepository` |
| `data/` | Implementations (Firebase later) | `StubAuthRepository` |

**Pattern for teammates:**

1. Define entity + repository interface in `domain/`
2. Implement repository in `data/`
3. Create Cubit in `presentation/cubit/`
4. Provide Cubit via `BlocProvider` (or read existing ones with `context.read`)
5. Rebuild UI with `BlocBuilder` / listen with `BlocListener`

**Duke:** replace `StubAuthRepository` in `app.dart` with a Firebase implementation of `AuthRepository`. Keep `AuthCubit` methods; add email/password + Google methods as needed.

## Dependencies

- `go_router` — navigation + auth redirects
- `flutter_bloc` + `equatable` — state management
- `google_fonts` — Inter typography

## Tests

```bash
flutter test
flutter analyze
```
