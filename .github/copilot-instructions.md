# Geo-Attendance Copilot Instructions

## Project Overview
Geo-Attendance is a Flutter-based location attendance management system using Firebase for authentication and data storage. It features role-based access (worker/manager) with geolocation-based attendance tracking.

## Architecture
- **Entry Point**: `lib/main.dart` - Initializes Firebase and displays responsive home page (mobile/desktop layouts)
- **Authentication**: Firebase Auth with email/password, user profiles stored in Firestore `users` collection
- **Role-Based Navigation**: Login redirects to `WorkerPage` or `ManagerPage` based on Firestore `role` field
- **Worker App**: `lib/pages/diff_applcation/application_worker.dart` - Full MaterialApp with sidebar navigation to features like Dashboard, Attendance, Profile
- **Manager App**: `lib/pages/diff_applcation/application_manager.dart` - Currently minimal, placeholder for manager features

## Key Components
- **Login/Register**: `lib/pages/login_page.dart` / `register_page.dart` - Handle Firebase auth and Firestore user creation
- **Responsive Design**: Main home page adapts to screen width (<600px mobile, >=600px desktop)
- **Asset Management**: Images in `assets/`, custom font `MomoTrustDisplay` in `fonts/`
- **Geolocation**: Uses `geolocator` package for location services (attendance tracking)

## Data Model
- **Users Collection** (Firestore): `{id, name, department, role, email, createdAt}`
- **Authentication**: Firebase Auth users linked by UID to Firestore docs
- **Role Logic**: Default 'worker' on signup, 'manager' checked in login for navigation

## Authentication Flow
1. User signs up → Firebase Auth account created + Firestore `users/{uid}` doc saved with role='worker'
2. Login → Firebase signIn → Fetch role from Firestore → Navigate to WorkerPage/ManagerPage

## Navigation Patterns
- Use `Navigator.pushReplacement` for auth-to-app transitions (avoids back navigation)
- Worker app uses index-based sidebar selection with `List<Widget> pages`
- Avoid nested MaterialApps; main.dart handles root app setup

## UI Patterns
- **Gradient Backgrounds**: Blue gradients with decorative circles (see `BlueGradientBackground` in main.dart)
- **Glass Effect Cards**: Semi-transparent containers with borders (register_page.dart)
- **Custom Font**: `MomoTrustDisplay` applied via ThemeData
- **Responsive Layouts**: Row/Column based on `MediaQuery.size.width`

## Build and Run
- **Run**: `flutter run` (supports hot reload)
- **Build APK**: `flutter build apk --release`
- **Test**: `flutter test` (if tests exist)
- **Dependencies**: `flutter pub get` after pubspec.yaml changes

## Dependencies & Integrations
- **Firebase**: Core, Auth, Firestore - configure via `firebase_options.dart` and `google-services.json`
- **Geolocator**: For location permissions and coordinates
- **fl_chart**: Data visualization (charts in worker app)
- **Platform Config**: Separate android/ios/web folders for native setup

## Conventions
- **State Management**: StatefulWidget with setState for simple UI state
- **Error Handling**: Try/catch with SnackBar feedback (login/register)
- **Validation**: Client-side checks before Firebase calls
- **Imports**: Relative paths within lib/, absolute for external packages
- **Naming**: CamelCase for classes, snake_case for files (e.g., `login_page.dart`)

## Common Tasks
- Adding new worker features: Extend `pages` list and `isSelected` in `application_worker.dart`
- User data updates: Query Firestore `users` collection by UID
- Location access: Request permissions via Geolocator before attendance actions</content>
<parameter name="filePath">c:\Users\Try Chansak\Documents\GitHub\Geo-Attendance\.github\copilot-instructions.md