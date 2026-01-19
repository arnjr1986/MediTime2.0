# Engineering & Code Health

## Codebase Status
- **Analyze**: `flutter analyze` passing with **0 issues**.
- **Deprecations**: All deprecated members (`withOpacity`, `value`) replaced with modern equivalents (`withValues`, `initialValue`).
- **Linting**: Strict async gap checks (`mounted`) implemented in Login.

## Validations
### Stock Control
- `dosesNeeded` is calculated dynamically based on Date Range.
- `dosesAvailable` relies on integer division of total/dose.
- Alert logic handles infinite duration (Continuous Use) by showing available doses only.

### Accessibility
- **Inputs**: `TextFormField` uses larger padding for touch targets.
- **Colors**: Contrast ratios checked against white backgrounds.

## Technical Stack
- **Framework**: Flutter 3.27+
- **Database**: `sqflite` (Relational) with Migration support (v4 added colors).
- **State**: Riverpod (Reactive)
- **Time**: `intl` package for formatting.
