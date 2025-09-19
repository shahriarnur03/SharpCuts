<div align="center">

<img src="assets/images/logo.png" alt="SharpCuts Logo" width="140" />

<h2>✂️ SharpCuts – Modern Barber Booking & Admin Panel</h2>

<p>End‑to‑end <b>Flutter</b> + <b>Firebase</b> application for discovering grooming services, booking appointments, and managing shop operations via an integrated admin dashboard.</p>

<p>
<a href="https://flutter.dev" target="_blank"><img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white" /></a>
<a href="https://firebase.google.com" target="_blank"><img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-ffca28?logo=firebase&logoColor=black" /></a>
<img src="https://img.shields.io/badge/State%20Mgmt-GetX-7b2cbf" />
<img src="https://img.shields.io/badge/Platforms-Android%20|%20iOS%20|%20Web-pink" />
<img src="https://img.shields.io/badge/License-Pending-lightgrey" />
</p>

<p><b>Navigation:</b><br/>
<a href="#quick-start">Setup</a> · <a href="#features">Features</a> · <a href="#architecture--tech-stack">Architecture</a> · <a href="#core-screens">Screens</a> · <a href="#data-model">Data</a> · <a href="#roadmap">Roadmap</a> · <a href="#why-this-project-matters">Recruiter Notes</a>
</p>

<hr />
</div>

## 🚀 Overview

SharpCuts is a cross‑platform (iOS / Android / Web-ready) barber shop management and customer booking app built with Flutter 3, leveraging Firebase for authentication, data storage, and real‑time updates. It demonstrates clean state management with GetX, modular routing, and production‑oriented patterns (extensible service layer, typed navigation constants, async initialization, and Firestore data segregation).

## 🌟 Features

### 👤 User (Customer)

-   Email + password authentication (Firebase Auth)
-   Account creation with persisted profile (Firestore `users` collection)
-   Browse available services (placeholder UI – extensible for dynamic services)
-   Book a service (creates document in `Booking` collection)
-   Reactive updates to booking status (planned real-time status tracking)

### 🛠️ Admin

-   Secure login (separate admin auth flow)
-   Dashboard to view all bookings (stream powered via Firestore snapshots)
-   Accept / delete bookings (`Status` mutation and document removal)
-   Add new services (UI implemented; persistence hook TODO)

### 🧱 Platform / Technical

-   Centralized route definitions via `AppRoutes`
-   Dependency injection with `Get.put` for controllers
-   Separation of concerns: Authentication, database methods, presentation
-   Firestore CRUD wrappers in `DatabaseMethods`
-   Declarative theming & custom color constants (see `constants/`)
-   Future-ready push/local notifications (dependency added: `flutter_local_notifications`)

## 🧩 Architecture & Tech Stack

| Layer               | Responsibility                              | Implementation                |
| ------------------- | ------------------------------------------- | ----------------------------- |
| Presentation        | UI Screens (User & Admin), navigation       | Flutter Widgets + GetX routes |
| State / Controllers | Auth session handling, navigation decisions | `AuthController` (GetX)       |
| Service / Data      | Abstract Firestore operations               | `DatabaseMethods`             |
| Backend (BaaS)      | Auth, Database, Hosting potential           | Firebase (Auth, Firestore)    |

Key Packages:

-   `firebase_core`, `firebase_auth`, `cloud_firestore` – backend integration
-   `get` – state management, DI, navigation
-   `intl` – formatting (dates, currency extensibility)
-   `flutter_local_notifications` – groundwork for reminders / confirmations

## 🖥️ Core Screens

| Route             | Screen               | Purpose                              |
| ----------------- | -------------------- | ------------------------------------ |
| `/`               | SplashScreen         | Initializes app & decides next route |
| `/login`          | LoginScreen          | User authentication                  |
| `/signup`         | SignupScreen         | New account registration             |
| `/home`           | HomeScreen           | Landing page (services overview)     |
| `/booking`        | BookingScreen        | Create booking with selected service |
| `/adminLogin`     | AdminLoginScreen     | Admin entry point                    |
| `/adminDashboard` | AdminDashboardScreen | Manage bookings                      |
| `/addService`     | AddServiceScreen     | UI to add new service (persist TODO) |
| `/adminSetup`     | AdminSetupScreen     | Initial admin configuration          |

## 🗂️ Data Model

> The data layer is intentionally lean to spotlight architectural decisions while remaining production-extensible.

Current Firestore Collections (minimalistic, easily extensible):

1. `users`

```
{
	"Name": String,
	"Email": String,
	"Phone": String (optional),
	"CreatedAt": int (epoch ms),
	"LastUpdated": int (epoch ms)
}
```

2. `Booking`

```
{
	"UserId": String,
	"ServiceId": String (future),
	"ServiceName": String,
	"RequestedAt": int (epoch ms),
	"PreferredTime": int (epoch ms) (future),
	"Status": String (e.g. Pending | Accepted | Cancelled)
}
```

📌 **Planned / Future Collections**

-   `services` – Persist admin-created services
-   `shops` / `locations` – Multi-branch scaling
-   `notifications` – Audit trail & messaging

## ⚡ Quick Start

### 1. Prerequisites

-   Flutter SDK 3.8.x (matching `environment` in `pubspec.yaml`)
-   Dart SDK (bundled with Flutter)
-   Firebase project (enable Auth + Firestore)
-   Xcode (iOS) / Android Studio toolchains

### 2. Clone & Install

```bash
git clone https://github.com/shahriarnur03/SharpCuts.git
cd SharpCuts
flutter clean
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project.
2. Enable Email/Password in Authentication.
3. Create iOS & Android apps in Firebase console.
4. Download `google-services.json` → place in `android/app/` (already present if committed).
5. Download `GoogleService-Info.plist` → place in `ios/Runner/` (already present if committed).
6. Run FlutterFire CLI (if regenerating options):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This (re)generates `lib/firebase_options.dart` used during `Firebase.initializeApp`.

### 4. Run the App

```bash
flutter run
```

Optional: specify device

```bash
flutter devices
flutter run -d <device_id>
```

### 5. Create a Test Account

Use the Signup screen or manually add a user via Firebase Console → Authentication.

## 🗃️ Project Structure (Selective)

```
lib/
	main.dart                # App entry & Firebase init
	firebase_options.dart    # Auto-generated Firebase config
	routes/app_routes.dart   # Centralized named routes
	user/
		controllers/auth_controller.dart
		services/database.dart # Firestore abstraction
		screens/...            # User-facing UI
	admin/
		screens/...            # Admin UI (dashboard, setup)
		add_service.dart       # Service creation form (persist TODO)
	constants/               # Colors, styles
assets/images/             # UI imagery & branding
```

## 🔐 Authentication Flow

1. App initializes Firebase.
2. `AuthController` injected (`Get.put`).
3. Auth state changes stream bound (listens for sign-out to redirect).
4. After login/signup → forced navigation to `/home`.
5. Logout → `signOut()` triggers redirect to `/login`.

## 📅 Booking Flow (Current)

User selects service (static list placeholder) → navigates to `/booking` → form submission → `DatabaseMethods.addUserBooking()` adds document to `Booking` → admin dashboard listens via snapshot stream → admin accepts or deletes.

## 🧪 Testing

Contains a starter widget test in `test/widget_test.dart`. Future expansion could include:

-   Controller tests (mock Firebase Auth + Firestore)
-   Golden tests for consistent UI
-   Integration test for full booking flow

## 🛤️ Roadmap

-   [ ] Persist services to `services` collection
-   [ ] Role-based access (user vs admin claims)
-   [ ] Service images & pricing tiers
-   [ ] Push notifications on booking status change
-   [ ] Booking time slot selection + conflict detection
-   [ ] In-app profile editing & avatar upload
-   [ ] Analytics dashboards (bookings per day, revenue projections)
-   [ ] Multi-location support
-   [ ] Dark mode & adaptive theming

## 🔒 Security Considerations

See `firebase_security_rules.md` (add Firestore Rules such as restricting `Booking` writes to authenticated users and service/admin validation). Recommended rules outline:

```
match /users/{userId} {
	allow read: if request.auth != null && request.auth.uid == userId;
	allow write: if request.auth != null && request.auth.uid == userId;
}
match /Booking/{bookingId} {
	allow create: if request.auth != null;
	allow read: if request.auth != null;
	allow update, delete: if isAdmin(request.auth.uid);
}
function isAdmin(uid) {
	return exists(/databases/(default)/documents/admins/uid);
}
```

## 💼 Why This Project Matters

For Recruiters / Reviewers:

-   Demonstrates full-stack mobile architecture using Firebase backend.
-   Shows knowledge of state management (GetX) with clean separation.
-   Implements authentication lifecycle handling and guarded navigation.
-   Uses Firestore abstraction layer for maintainability & testability.
-   Prepares groundwork for real-time operations & notification integration.
-   Clear extensibility path (services collection, roles, analytics).

## 🔧 Extensibility Examples

Add service persistence (conceptual snippet):

```dart
Future addService(Map<String, dynamic> service) async {
	return FirebaseFirestore.instance.collection('services').add({
		...service,
		'CreatedAt': DateTime.now().millisecondsSinceEpoch,
	});
}
```

Then query services with a `StreamBuilder` to populate `HomeScreen` dynamically.

## 🤝 Contribution

PRs welcome (fork → feature branch → PR). For larger changes open an issue first.

## 📄 License

Add a license (MIT recommended) to clarify usage intent.

## 🙌 Acknowledgements

-   Flutter & Firebase teams
-   GetX community

---

<div align="center">

### 📸 Screenshots (Coming Soon)

<i>Add UI previews here (Home, Booking, Admin Dashboard) – helps recruiters quickly assess UX quality.</i>

</div>

---

> Made with Flutter ❤️ – striving for clean, maintainable, and scalable mobile architecture.
