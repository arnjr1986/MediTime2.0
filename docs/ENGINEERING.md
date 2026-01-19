# Engineering & Best Practices

## Clean Architecture Implementation
We structure the code to ensure separation of concerns:

-   **Domain/Data**: `lib/data/models` contains the pure data structures. `lib/data/local_db.dart` handles raw data caching.
-   **Application/Providers**: `lib/providers` contains `MedicationNotifier`. This is the "Use Case" layer. It doesn't know about UI widgets, only data manipulation and state.
-   **Presentation**: `lib/screens` contains Flutter Widgets. These observe Providers and render UI. They do **not** contain business logic (e.g., they don't calculate dates or make DB calls directly).

## Testing Strategy
### 1. Unit Tests
-   **Target**: Models and Utility functions.
-   **Goal**: Verify `toMap()`/`fromMap()` logic, Date calculations.
-   **Run**: `flutter test`

### 2. Widget Tests
-   **Target**: Individual Screens and Components.
-   **Goal**: Verify UI renders correctly given a specific State.
-   **Example**: `test/widget_test.dart` checks if the counter/list renders.

### 3. Integration/E2E Tests
-   **Tool**: Flutter Driver or Integration Test package.
-   **Goal**: Full flow verification (Login -> Add Med -> Verify List).

## CI/CD Pipeline (GitHub Actions Template)
Create `.github/workflows/main.yml`:

```yaml
name: MediTime CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
      
      - name: Install Dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Run Tests
        run: flutter test
      
      - name: Build Web
        run: flutter build web
```

## Code Style
-   **Linter**: `flutter_lints` is enabled.
-   **Formatting**: Standard `dart format`.
-   **Naming**: CamelCase for classes, camelCase for variables/methods.
