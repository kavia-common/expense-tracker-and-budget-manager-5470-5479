# Mobile Expense Tracker

## Project Overview
Mobile Expense Tracker is a Flutter application that helps users manage and track monthly expenses. It showcases a modern “Ocean Professional” theme and a clean architecture with modular layers. In this iteration, the app uses an in-memory mock data layer to simulate accounts, transactions, budgets, goals, and alerts. Users can view a dashboard summary, simple reports, manage budgets and goals, see alerts, and access placeholders for Accounts and Bank Linking.

## Ocean Professional Theme (colors, typography, surfaces, gradients)
The app defines a cohesive visual style under the “Ocean Professional” theme with blue and amber accents, subtle shadows, rounded corners, and minimalist surfaces.

- Colors
  - Primary: AppColors.primary = #2563EB (Blue 600)
  - Secondary/Success: AppColors.secondary = #F59E0B (Amber 500)
  - Error: AppColors.error = #EF4444 (Red 500)
  - Background: #F9FAFB
  - Surface/Tile: #FFFFFF
  - Text Primary: #111827
  - Text Secondary: #6B7280
  - Gradients: AppColors.headerGradient provides a light blue-to-gray wash for section headers

- Typography
  - AppTypography.textTheme(context) applies theme-aware weights and colors across title, body, and label styles.

- ThemeData
  - Defined in AppTheme.theme(context), sets Material 3, color scheme from seed, app bars, cards, bottom navigation, drawer, chips, dividers, and scaffold background to match the Ocean Professional aesthetic.

Relevant sources:
- lib/core/styles/app_colors.dart
- lib/core/styles/app_typography.dart
- lib/core/theme/app_theme.dart
- lib/core/widgets/common_widgets.dart (SectionHeader, OceanCard)

## Architecture (core, data, domain, presentation) and folder structure
The codebase follows a layered architecture for clarity and testability.

- core: Cross-cutting concerns
  - navigation/app_router.dart defines route names and onGenerateRoute.
  - theme/app_theme.dart composes ThemeData.
  - styles/app_colors.dart and styles/app_typography.dart centralize theme tokens.
  - widgets/common_widgets.dart includes SectionHeader and OceanCard.

- data: Data models and repositories
  - datasources/local_mock_data_source.dart provides in-memory seed data for accounts, categories, transactions, budgets, goals, and alerts, with simple mutators for budgets/goals.
  - repositories/*_repository.dart expose read/write operations built over the mock data source.
  - models/* define basic immutable models with copyWith helpers where relevant.

- domain: Use cases (business logic)
  - get_dashboard_summary.dart computes income, expenses, net, and expenseByCategory.
  - get_monthly_report.dart aggregates daily net and totals for a given month.
  - get_alerts.dart, set_budget.dart, set_goal.dart provide simple facades over repositories.

- presentation: UI and state
  - app_shell.dart defines the Drawer and BottomNavigation entry shell and routes to feature screens.
  - state/*_provider.dart hold ChangeNotifier-based state for dashboard, reports, budgets, goals, and alerts.
  - screens/* implement the feature UIs (dashboard, reports, budgets, goals, alerts, accounts, onboarding placeholder, settings).
  - widgets/* include UI building blocks such as charts, cards, chips, and banners.

Top-level entry:
- lib/main.dart wires Theme, Providers, and Router and loads .env (optional).

## State Management (Provider) and data flow
State is managed with the Provider package using ChangeNotifier:

- Providers:
  - DashboardProvider: computes and exposes DashboardSummary using TransactionsRepository + GetDashboardSummary.
  - ReportsProvider: builds MonthlyReport using TransactionsRepository + GetMonthlyReport for the selected month.
  - BudgetsProvider: exposes budgets, supports updates via SetBudget.
  - GoalsProvider: exposes goals, supports updates via SetGoal.
  - AlertsProvider: loads alerts via GetAlerts.
  - AppState: holds global flags (e.g., hasOnboarded placeholder).

- Data flow:
  - UI screens watch providers via context.watch<T>().
  - Providers consume repositories which read/write against LocalMockDataSource.
  - Domain use cases encapsulate basic business logic for summaries and reports.

Sources:
- lib/main.dart
- lib/presentation/state/*.dart
- lib/data/repositories/*.dart
- lib/domain/usecases/*.dart

## Navigation (routes, AppShell, drawer + tabs)
Navigation combines a drawer and a bottom navigation bar:

- AppShell: hosts an AppBar, a Drawer with “Accounts” and “Settings”, and a BottomNavigationBar with Home, Reports, Budgets, Goals, Alerts. Tapping on non-dashboard tabs performs named route navigation so the route stack reflects the selection.
- AppRoutes: centralized route names and onGenerateRoute, mapping to screens:
  - '/': Dashboard
  - '/reports': Reports
  - '/budgets': Budgets
  - '/goals': Goals
  - '/alerts': Alerts
  - '/accounts': Accounts
  - '/settings': Settings
  - '/link-account': LinkAccount placeholder

Sources:
- lib/presentation/app_shell.dart
- lib/core/navigation/app_router.dart

## Features
- Dashboard: Overview tiles for income, expenses, net; alert banner; basic pie chart and trend line rendering without external chart libraries.
- Reports: Monthly summary (income/expense totals) and a simple trend line chart of daily net.
- Budgets: List budgets with progress bars, edit budget limit via dialog using BudgetsProvider + SetBudget.
- Goals: List goals with progress bars, edit goal data via dialog using GoalsProvider + SetGoal.
- Alerts: Display alerts as banners in a list.
- Accounts (placeholder screen): Lists mock accounts and balances.
- Settings: Theme label, link to Link Account placeholder, and shows a .env value example (SITE_URL).

Sources:
- lib/presentation/screens/**/* and lib/presentation/widgets/**/*

## Data Strategy (mock/in-memory now; future expenses_database integration plan)
- Current approach:
  - LocalMockDataSource seeds in-memory demo data; changes are ephemeral and exist for the app session only.
  - Repositories provide a small abstraction layer so the data source can be swapped later.
  - SharedPreferences wrapper (LocalPrefsDataSource) is present but not yet integrated into flows other than the class definition.

- Future integration with expenses_database:
  - Replace LocalMockDataSource with a persistent data layer (e.g., SQLite via sqflite or a shared “expenses_database” module).
  - Create concrete DataSources for transactions, budgets, goals, accounts that read/write to the database.
  - Update repositories to depend on these data sources and provide async APIs.
  - Add data migration/seed steps to initialize categories and default budgets.
  - Introduce mappers between DB rows and model classes.
  - Ensure Providers and Use Cases become asynchronous and handle loading/error states.
  - Consider a background sync process if account linking introduces remote APIs.

Relevant current sources:
- lib/data/datasources/local_mock_data_source.dart
- lib/data/repositories/*.dart

## Environment Variables (.env placeholders)
The app loads .env optionally at startup (see pubspec.yaml and main.dart). The following placeholders are recommended for future integrations:

- API_BASE_URL=
- FEATURE_LINK_ACCOUNTS=true
- DEFAULT_CURRENCY=USD

Note: SettingsScreen currently reads SITE_URL as a demo; you can rename or set both for local testing.

How .env is wired:
- pubspec.yaml declares assets: ".env" so it can be bundled during development.
- lib/main.dart loads dotenv with isOptional: true.

## How to Run (including dotenv loading)
Prerequisites:
- Flutter SDK (matching pubspec constraints; see pubspec.lock for resolved versions).
- Android or iOS toolchains for running on devices/emulators/simulators.

Steps:
1) Navigate to the app directory:
   cd expense-tracker-and-budget-manager-5470-5479/mobile_expense_tracker

2) Optionally create a .env file at the project root (same folder as pubspec.yaml), for example:
   API_BASE_URL=https://api.example.com
   FEATURE_LINK_ACCOUNTS=true
   DEFAULT_CURRENCY=USD
   SITE_URL=https://docs.example.com

3) Get dependencies:
   flutter pub get

4) Run on a device/emulator:
   flutter run

Notes:
- The .env file is included in assets in pubspec.yaml. In production builds, review whether to bundle .env and whether to use native config or remote config.
- If you change environment variables, perform a hot restart to reload values.

## Future Work
- Hook up to persistent expenses_database:
  - Introduce SQLite-backed data sources and migrations.
  - Replace mock data creation with real persisted storage and async flows.
- Richer charts:
  - Add labeled axes, tooltips, and filters. Consider a lightweight charting package or improve custom painters.
- Real account linking:
  - Implement bank connection flow in place of link_account_placeholder_screen.dart.
  - Add secure credential handling, OAuth flows, and background sync for transactions.
- Settings and preferences:
  - Use LocalPrefsDataSource to store onboarding flags, default currency, and feature flags.
- Accessibility and i18n:
  - Ensure sufficient contrast, larger text support, and localized strings.

## Folder Structure (quick reference)
- lib/
  - core/
    - navigation/
    - styles/
    - theme/
    - widgets/
  - data/
    - datasources/
    - models/
    - repositories/
  - domain/
    - usecases/
  - presentation/
    - app_shell.dart
    - screens/
    - state/
    - widgets/
  - main.dart

## Run Tests
A basic widget test exists:
- test/widget_test.dart
Run:
- flutter test

## References (sources for this README)
- lib/main.dart
- lib/core/styles/app_colors.dart
- lib/core/styles/app_typography.dart
- lib/core/theme/app_theme.dart
- lib/core/navigation/app_router.dart
- lib/presentation/app_shell.dart
- lib/presentation/screens/**/*
- lib/presentation/state/**/*
- lib/data/datasources/local_mock_data_source.dart
- lib/data/repositories/**/*
- lib/domain/usecases/**/*
- pubspec.yaml
