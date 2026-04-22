# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Tacit mobile template designed for rapid development of Flutter applications. It includes:
- Firebase integration (Analytics, Crashlytics, Messaging)
- Authentication system with token-based auth
- BLoC pattern for state management
- Custom API client with error handling
- Reusable widgets and themes
- Fastlane deployment setup for iOS and Android
- Flutter 3.41.6 with modern Android Kotlin DSL build configuration
- **Flavor support** for production and staging environments
- **Accessibility testing** with WCAG 2.2 Level AA compliance
- **Agent Skills** for AI-assisted development (see `.claude/skills/`)

## Requirements

- **Flutter**: 3.41.6 (managed via FVM, includes Dart 3.11.4)
- **Dart SDK**: >=3.10.0 <4.0.0 (constraint from pubspec.yaml)
- **Android**: Gradle 8.11+, Java 17+, Android API 21+
- **iOS**: Xcode 15+, iOS 15+

## Agent Skills

This project includes [Agent Skills](https://agentskills.io/specification) in `.claude/skills/` for AI-assisted development:

- `twinsun-flutter-upgrade` - Automate Flutter version upgrades with FVM
- `twinsun-flutter-accessibility` - Ensure WCAG 2.2 Level AA compliance

See `.claude/skills/README.md` for details.

## ⚠️ Security & Permissions

This project uses Claude Code with scoped permissions defined in `.claude/settings.local.json` (not tracked in git). The permissions allow:

- **FVM operations** - Version management (`fvm use`, `fvm install`)
- **Dependency management** - Package operations (`fvm flutter pub get`)
- **Build operations** - Clean and analyze (`fvm flutter clean`, `fvm flutter analyze`)
- **Automated migrations** - Code fixes (`dart fix --apply`)

**Agent Skills Security Principles:**
- **No auto-commit** - All changes require human review before committing
- **Report & review loop** - Skills present findings for approval, never push directly
- **Known good state** - Operations verify baseline (tests pass, analyzer clean) before making changes
- **Scoped permissions** - Only approved commands can run without prompting

**Setup:**
Create `.claude/settings.local.json` based on `.claude/settings.local.json.example` to configure your permissions. This file is excluded from git to allow personal customization.

## Common Commands

### Development Setup
```bash
# Install FVM (Flutter Version Manager)
dart pub global activate fvm

# Install Flutter version for this project
fvm install

# Run the app (use fvm for consistent Flutter version)
fvm flutter run

# Run with specific flavor
fvm flutter run --flavor staging
fvm flutter run --flavor production

# Generate mocks for testing
fvm flutter pub run build_runner build

# Run tests
fvm flutter test

# Clean build
fvm flutter clean && fvm flutter pub get
```

### Project Setup (for new projects)
```bash
# Complete setup with both app renaming and Firebase setup
./setup.dart

# This will:
# - Rename project from tacit_mobile to your app name
# - Set up Firebase project with 4 apps (production & staging for iOS & Android)
# - Download configuration files to correct locations
# - Enable required Firebase services
# - Update firebase_options.dart with actual API keys

# You can also run with command line arguments:
./setup.dart --app-name MyApp --project-id my-firebase-project --create-new

# With custom bundle IDs (recommended):
./setup.dart --app-name MyApp --android-package com.mycompany.myapp --ios-bundle com.mycompany.myapp

# Or skip certain steps:
./setup.dart --app-name MyApp --skip-firebase
./setup.dart --skip-rename --project-id existing-project --use-existing

# Full example with all options:
./setup.dart --app-name MyApp \
  --project-id my-firebase-project \
  --android-package com.mycompany.myapp \
  --ios-bundle com.mycompany.myapp \
  --use-existing

# Prerequisites for Firebase setup:
# - Firebase CLI installed: npm install -g firebase-tools
# - Logged in to Firebase: firebase login
```

### Individual Setup Steps
```bash
# Run only app renaming
dart setup/rename_project.dart YourAppName

# Run only Firebase setup
dart setup/setup_firebase.dart --project-id my-project --create-new
```

### Code Quality
```bash
# Run linter (uses analysis_options.yaml)
fvm flutter analyze

# Format code
fvm flutter format .
```

## Architecture

### Directory Structure
- `lib/api/` - API clients and HTTP configuration
- `lib/bloc/` - Business logic components using BLoC pattern
- `lib/mixins/` - Reusable mixins for navigation and snackbars
- `lib/model/` - Data models and API response structures
- `lib/repository/` - Data access layer
- `lib/screens/` - UI screens with BaseScreen for common functionality
- `lib/themes/` - App theming and styling
- `lib/widgets/` - Reusable UI components

### Key Components

#### BLoC Pattern
- `ConfigBloc` - Manages app configuration and authentication state
- `CriticBloc` - Handles error reporting (Inventiv Critic integration)
- `LoggingBloc` - Centralized logging system
- `LoginBloc` - Authentication flow management
- `NotificationBloc` - Push notification handling

#### Base Classes
- `BaseScreen` - Base class for all screens with common functionality (navigation, snackbars, loading states)
- `Api` - Base API client with authentication headers

#### Configuration Management
Uses `ConfigBloc` with RxDart streams for reactive configuration management. Key configuration constants:
- `kAuthToken` - Authentication token
- `kAuthEmail` - User email
- `kAuthId` - User ID

### State Management
Uses BLoC pattern with RxDart for reactive streams. All BLoCs follow singleton pattern with factory constructors.

## Flavors

The app supports two flavors:
- **staging** - Uses `lib/main.dart` with staging configuration
- **production** - Uses `lib/main-production.dart` with production configuration

### Flavor Configuration
Flavors are configured using `flavorizr.yaml` with:
- Different app names and bundle IDs for each flavor
- Separate Firebase configurations
- Different signing certificates

### VSCode Debug Configuration
The `.vscode/launch.json` includes flavor-specific debug configurations:
- Flutter (Staging) - Debug with staging flavor
- Flutter (Production) - Debug with production flavor
- Flutter (Default) - Original debug configuration

## Deployment

### Android
- Uses Fastlane for deployment with flavor support
- Requires keystore setup (see docs/android.md)
- GitHub Actions workflow in `.github/workflows/android.yml`
- Uses Kotlin DSL build files (build.gradle.kts) for better type safety
- Requires Gradle 8.11+ and Java 17+

### iOS  
- Uses Fastlane with match for code signing
- Requires certificates in GitHub repository
- GitHub Actions workflow in `.github/workflows/ios.yml`
- Includes signing lanes: `update_signing` and `update_development_signing`

### CI/CD
- Test workflow runs on all PRs
- Staging/Production deployments triggered by GitHub Actions
- Build number auto-increment system
- **Production workflows** for manual deployment:
  - `production_android_firebase.yml` - Firebase App Distribution
  - `production_android.yml` - Google Play Store
  - `production_ios.yml` - TestFlight

### Deployment Commands
```bash
# Deploy to staging
bin/deploy android staging
bin/deploy ios staging

# Deploy to production
bin/deploy android production  
bin/deploy ios production

# Deploy to Firebase App Distribution
bin/deploy android_firebase staging
bin/deploy android_firebase production
```

## Testing

### Test Structure
- `test/bloc/` - BLoC unit tests with mocks
- `test/model/` - Data model tests
- `test/widgets/` - Widget tests
- `test/accessibility/` - Accessibility tests (WCAG compliance)

### Accessibility Testing
The project includes automated accessibility tests that verify WCAG 2.2 compliance, organized by level:

**WCAG Level Mapping:**
- **Level A** (blocking in CI): `labeledTapTargetGuideline` (WCAG 1.1.1) + custom semantic checks
- **Level AA** (informational in CI): `textContrastGuideline` (WCAG 1.4.3) + tap target size guidelines (WCAG 2.5.8)

**Test tagging convention:**
- All accessibility test files use `@Tags(['accessibility'])` (declared in `dart_test.yaml`)
- Test names prefixed with `[Level-A]` or `[Level-AA]` to indicate WCAG level

```bash
# Run all accessibility tests
fvm flutter test test/accessibility/

# Run only Level A tests (blocking in CI)
fvm flutter test --tags accessibility --name "\[Level-A\]" test/accessibility/

# Run only Level AA tests (informational in CI)
fvm flutter test --tags accessibility --name "\[Level-AA\]" test/accessibility/

# Run non-accessibility tests only
fvm flutter test --exclude-tags accessibility
```

**What's tested:**
- **Level A**: Labeled tap targets (all interactive elements have labels), semantic properties (labels, roles, states)
- **Level AA**: Touch target sizes (iOS: 44x44, Android: 48x48), text contrast (WCAG minimum ratios)

**Test organization by component type:**
- Screens → `screens_accessibility_test.dart`
- Widgets → `widgets_accessibility_test.dart`
- Buttons → `buttons_accessibility_test.dart`
- Dialogs → `dialogs_accessibility_test.dart`
- AppBars → `app_bars_accessibility_test.dart`

Shared helpers are in `accessibility_test_helpers.dart`.

**CI Pipeline:**
- `_accessibility.yml` runs Level A (blocking) and Level AA (informational) tests in a single job (`wcag_compliance`)
- `_accessibility.yml` runs static anti-pattern detection as a **blocking** step within the `wcag_compliance` job
- The main `test` job also runs all tests including accessibility

### Mock Generation
Uses `mockito` package. Generate mocks with:
```bash
fvm flutter pub run build_runner build
```

## Code Style

### Linting Rules
Follows `flutter_lints` with additional custom rules in `analysis_options.yaml`:
- Always use package imports
- Require trailing commas
- Prefer single quotes
- Type annotate public APIs
- Use final for locals where possible

### Important Notes
- All API configurations point to localhost:3000 by default
- Firebase configuration files (google-services.json, GoogleService-Info.plist) need to be updated for your project
- Critic key in `lib/bloc/critic_bloc.dart` needs to be updated for your app
- The app uses token-based authentication with custom headers
- Always use `fvm flutter` commands to ensure consistent Flutter version across development team
- Android build files use Kotlin DSL (.gradle.kts) for better IDE support and type safety