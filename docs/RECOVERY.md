# Disaster Recovery & Zero-to-Hero

## "Retomar do Zero" (Zero-to-Hero)
If you lose the development environment or need to onboard a new developer:

1.  **Install Tools**: Install VS Code + Flutter Extension.
2.  **Get Code**:
    ```bash
    git clone <repo>
    ```
3.  **Restore Deps**:
    ```bash
    flutter pub get
    ```
4.  **Restore Secrets**:
    -   You MUST recover `firebase_options.dart` and `google-services.json` from your secure backup password manager. These are NOT in git.
    -   Place them in the correct folders (see README).
5.  **Run**:
    ```bash
    flutter run
    ```

## Backup Strategy
### Database
-   **Mobile (SQLite)**: The DB file is located at `getDatabasesPath()`. On Android, this is usually `/data/data/com.example.meditime/databases/meditime.db`. To backup, you can implement an "Export DB" feature to share this file.
-   **Web (SharedPreferences)**: Data is stored in the browser's LocalStorage. Clearing browser cache **WILL DELETE DATA**.
    -   *Mitigation*: Implement a cloud sync (Firestore) feature in the future to prevent data loss on cache clear.

## Common Issues
-   **"Missing Plugin"**: Run `flutter clean` then `flutter pub get`.
-   **"CocoaPods not installed"** (Mac): Run `sudo gem install cocoapods`.
-   **"Port in use"** (Web): Run with specific port: `flutter run -d web-server --web-port=8085`.
