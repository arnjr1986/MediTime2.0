# MediTime - Medication Management System

**Version**: 1.0.0
**Date**: 2026-01-19
**Tech Stack**: Flutter (Web/Mobile), Firebase Auth, SQLite/SharedPreferences, Riverpod

## 1. Overview
MediTime is a comprehensive medication management application designed to help users track their medication schedules, dosage, and history. It features a clean, Material 3 design optimized for accessibility (especially for elderly users) and robustness (offline capabilities).

## 2. Setup & Installation

### Prerequisites
-   Flutter SDK (> 3.22.0)
-   Dart SDK
-   Google Chrome (for Web debugging)
-   Android Studio / VS Code

### Steps
1.  **Clone/Download**:
    ```bash
    git clone <repository-url>
    cd medi_time
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Firebase Configuration**:
    -   **Web**: Update `lib/firebase_options.dart` with your actual Firebase Web Config keys.
    -   **Android**: Place your `google-services.json` in `android/app/`.
    -   **iOS**: Place your `GoogleService-Info.plist` in `ios/Runner/`.
4.  **Run Application**:
    -   **Web**: `flutter run -d chrome` (or `web-server` for headless).
    -   **Mobile**: `flutter run -d <device-id>`.

## 3. Current Features
-   **Authentication**:
    -   Firebase Email/Password Login.
    -   Guest Login (Anonymous) for quick access/testing.
-   **Medication Management**:
    -   **CRUD**: Create, Read, Update, Delete medications.
    -   **Persistence**:
        -   **Mobile**: SQLite (`sqflite`).
        -   **Web**: SharedPreferences (JSON storage).
    -   **Advanced Form**:
        -   Autocomplete Names (e.g., Paracetamol).
        -   Type Selector (Tablet, Liquid, Spray, etc.).
        -   Dosage & Quantity Tracking.
        -   Medical Details (Doctor, Reason, Notes).
        -   Image Picker (Prescription photo).
        -   Flexible Scheduling (Fixed times or Intervals).
-   **Schedule & Notifications**:
    -   Calendar View of daily medications.
    -   Local Notifications via `awesome_notifications`.
-   **UI/UX**:
    -   Modern Material 3 Design (Teal/Indigo theme).
    -   Responsive Layouts.

## 4. Roadmap (Future Scope)
-   [ ] **History Log**: Track actual taken doses vs scheduled.
-   [ ] **Export**: Generate PDF reports for doctor visits.
-   [ ] **Multi-Profile**: Manage meds for multiple family members.
-   [ ] **Refill Reminders**: Track total quantity and alert when low.
-   [ ] **Cloud Sync**: Sync local DB with Firestore for cross-device usage.

## 5. Deployment
-   **Android**: `flutter build apk --release`
-   **Web**: `flutter build web` (deploy `build/web` to Firebase Hosting).

## 6. Project Structure
-   `lib/core`: Services, Theme, Constants.
-   `lib/data`: Models, Local Database (SQLite/Prefs).
-   `lib/providers`: State Management (Riverpod).
-   `lib/screens`: UI Views (Login, List, Form, Calendar).
