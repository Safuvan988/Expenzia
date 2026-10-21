# Expenzia – Expense Management App

A Flutter expense management mobile app built for the Lilac Infotech Flutter machine test. It follows the provided Figma design and stores all data locally using SQLite.

## Features Completed

- Splash screen and onboarding screen
- Home screen with total balance, income, expenses, daily average, weekly total, and recent transactions
- Add a new transaction (expense or income)
- Edit an existing transaction
- Delete a transaction with a confirmation dialog
- Transaction History screen with edit and delete actions
- Total balance and lists update automatically when data changes
- Empty state when there are no transactions
- Form validation:
  - Title is required
  - Amount must be a valid number greater than 0
  - Category is required
  - Invalid or incomplete records cannot be saved
- SQLite persistence (data survives closing and reopening the app)
- Basic database error handling with user-facing messages
- Bottom navigation with a center floating action button

## Tech Stack

- Flutter (Dart)
- SQLite via `sqflite`
- State management: `provider`

## Dependencies

| Package | Purpose |
|---|---|
| `sqflite` | Local SQLite database |
| `path` | Database file path |
| `provider` | State management |
| `intl` | Date and number formatting |

## Setup Instructions

1. Make sure Flutter is installed (`flutter --version`).
2. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd <project-folder>
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on an emulator or a connected device:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
  main.dart
  core/         theme.dart, constants.dart
  models/       expense.dart
  data/         database_helper.dart, expense_repository.dart
  providers/    expense_provider.dart
  screens/      splash, onboarding, home, history, add_edit_expense
  widgets/      expense_tile.dart, empty_state.dart, ...
```

- **UI** lives in `screens/` and `widgets/`.
- **Models** live in `models/`.
- **Database logic** is isolated in `data/` (`DatabaseHelper` handles CRUD).
- **State** is handled by `ExpenseProvider`, which reloads from SQLite after every change and notifies the UI.

## Database

Table: `expenses`

| Column | Type |
|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT |
| title | TEXT NOT NULL |
| amount | REAL NOT NULL |
| category | TEXT NOT NULL |
| type | TEXT NOT NULL (`expense` / `income`) |
| date | TEXT NOT NULL (ISO 8601) |
| description | TEXT (optional) |

## Known Issues / Incomplete Features

- **Credit** and **Profile** screens are placeholders ("Coming soon") and are not implemented.
- **Daily Average** and **Weekly** values are not defined in the Figma, so they are computed from the expenses of the last 7 days (weekly total, and that total divided by 7).
- The Figma mixes `$` and `₹`; the app uses `₹` consistently.
- The onboarding illustration uses a placeholder icon unless the Figma asset is added as `assets/onboarding.png`.