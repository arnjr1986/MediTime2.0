# Architecture & Design

## System Overview
MediTime follows a **Clean Architecture** inspired approach, separating the application into distinct layers: Presentation, Domain/Providers, Data, and Core Services.

## 1. Layer Diagram

```mermaid
graph TD
    UI[UI Layer (Screens)] -->|Watches| Prov[Providers (Riverpod)]
    Prov -->|Calls| Repo[Data Layer (LocalDB/Repos)]
    Prov -->|Calls| Serv[Core Services (Auth, Notifs)]
    Repo -->|Read/Write| SQLite[(SQLite - Mobile)]
    Repo -->|Read/Write| Prefs[(SharedPrefs - Web)]
    Serv -->|Auth| Firebase[Firebase Auth]
    Serv -->|Schedule| Notif[Awesome Notifications]
```

## 2. Data Flow
### Adding a Medication
1.  **User Input**: User fills `AddMedicationScreen` form.
2.  **State Update**: `MedicationProvider.addMedication(med)` is called.
3.  **Persistence**:
    -   `LocalDB` detects platform.
    -   If **Web**: Reads JSON from SharedPreferences, appends new med, saves back.
    -   If **Mobile**: Inserts row into SQLite `medications` table.
4.  **Notification**: `MedicationProvider` calculates trigger times and calls `NotificationService.scheduleNotification()`.
5.  **UI Refresh**: Provider state updates, causing `MedsListScreen` to rebuild with the new item.

## 3. Dependency Tree
| Package | Purpose |
| :--- | :--- |
| **flutter_riverpod** | State Management (Reactive caching & binding) |
| **sqflite** | Local Database for Android/iOS |
| **shared_preferences** | Key-Value storage (Web Fallback) |
| **firebase_auth** | User Authentication |
| **awesome_notifications** | Local Scheduling of reminders |
| **intl** | Date/Time formatting |
| **table_calendar** | Calendar UI widget |
| **image_picker** | Camera/Gallery access |
| **path** | File path manipulation |

## 4. Key Components
-   **MedicationModel**: Immutable data class holding all med logic.
-   **LocalDB**: Singleton helper abstracting the underlying storage engine.
-   **AuthService**: Wrapper around Firebase Auth instance.
-   **MedicationNotifier**: Central business logic unit (BLoC equivalent).
