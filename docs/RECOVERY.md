# Disaster Recovery & Setup

## Zero-to-Hero Setup
1.  **Clone Repository**: `git clone <repo-url>`
2.  **Restore Docs**: Unzip `MediTime-DOCS-2026-01-19-v2.zip`.
3.  **Dependencies**: `flutter pub get`.
4.  **Database**: The SQLite DB is created automatically on first run (`MediTime.db`).

## Credentials (Golden Path)
Use these credentials to verify full functionality (Stock, Calendar, History) in any environment (Web/Mobile):
- **User**: `teste@gmail.com`
- **Password**: `123456`

## Common Issues
- **Port Busy**: If `8088` is busy, try `8089` or kill the process.
- **Web Images**: Use `flutter run -d chrome --web-renderer html` if images fail to render.
- **Firebase Auth**: If Guest Login fails (400), use the Email/Password above.
