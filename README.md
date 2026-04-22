# Tacit Mobile

A production-ready Flutter template that gives your project Firebase, authentication, CI/CD pipelines, accessibility testing, and deployment automation out of the box -- so you can skip the boilerplate and start building features on day one.

## What You Get

| Category | Included |
|----------|----------|
| **Firebase** | Analytics, Crashlytics, Cloud Messaging (with retry and fresh-token-per-login) |
| **Authentication** | Token-based auth with secure storage, nullable subscriptions, Firebase guards |
| **State Management** | BLoC pattern with RxDart streams, singleton lifecycle with async reset/dispose |
| **API Layer** | `ApiMixin`-based HTTP client with auth headers, typed error handling, `Json` type alias |
| **Flavors** | Production and staging environments with separate Firebase configs and bundle IDs |
| **CI/CD** | GitHub Actions for testing, debug builds on PRs, staging/production deploys |
| **Deployment** | Fastlane for iOS (TestFlight) and Android (Play Store, Firebase App Distribution) |
| **Accessibility** | WCAG 2.2 Level A/AA test suite, static anti-pattern detection |
| **AI Tooling** | Agent Skills for Flutter upgrades and accessibility audits |

## Requirements

| Tool | Version |
|------|---------|
| Flutter | 3.41.6 (managed via [FVM](https://fvm.app)) |
| Dart SDK | >=3.10.0 <4.0.0 |
| Android | Gradle 8.11+, Java 17+, API 21+ |
| iOS | Xcode 15+, iOS 15+, Swift Package Manager |

## Quick Start

### Option A: Twin Sun CLI (Recommended)

```bash
# Install the Twin Sun CLI
dart pub global activate --source git git@github.com:twinsunllc/twinsun-cli.git

# Scaffold a new project
twinsun new my-project flutter
```

The CLI clones this template, renames it, configures FVM, and walks you through Firebase setup. After scaffolding, install the [Twin Sun Claude Code plugin](https://github.com/twinsunllc/twin-sun-claude-plugin) and run `/ts:setup` to add AI rules and development tooling.

See the **Developer Toolkit** page in the Twin Sun Confluence space for full documentation.

### Option B: Manual Setup

```bash
# 1. Clone and rename
git clone git@github.com:twinsunllc/tacit-mobile.git my-awesome-app
cd my-awesome-app
git remote set-url origin git@github.com:twinsunllc/my-awesome-app.git
git push -u origin main

# 2. Run the setup script (interactive -- prompts for app name and Firebase config)
./setup.dart

# 3. Install dependencies and run
fvm install
fvm flutter clean && fvm flutter pub get
fvm flutter run --flavor staging
```

The setup script accepts flags for automation:

```bash
./setup.dart --app-name MyApp --project-id my-firebase-project --create-new
./setup.dart --app-name MyApp --android-package com.mycompany.myapp --ios-bundle com.mycompany.myapp
./setup.dart --app-name MyApp --skip-firebase
```

**Prerequisites for Firebase setup:** Firebase CLI (`npm install -g firebase-tools`) and `firebase login`.

### Post-Setup

1. Update the bundle identifier and Kotlin package path if your package name differs from the default.
2. Update the Critic key in `lib/bloc/critic_bloc.dart`.
3. Commit and push.

## Architecture

```
lib/
  api/            # ApiMixin-based HTTP client, auth headers, error handling
  bloc/           # BLoC singletons: Auth, Config, Critic, Logging, Notification
  constants/      # App-wide constants (auth keys, config values)
  mixins/         # Reusable mixins (navigation, snackbars, Logger)
  model/          # Data models, API response structures, Json type alias
  repository/     # Data access layer
  screens/        # UI screens with BaseScreen for common functionality
  themes/         # App theming and styling
  widgets/        # Reusable UI components
  firebase_options.dart  # Firebase config with isConfigured guard
  flavors.dart           # Flavor enum and configuration
  main.dart              # Shared app bootstrap
  main_staging.dart      # Staging flavor entry point
  main_production.dart   # Production flavor entry point
```

**Key patterns:**
- BLoCs use nullable singleton instances with factory constructors and async `reset()`/`dispose()` methods
- `ApiMixin` provides HTTP client, auth headers, and base URL -- compose into any API class
- Shared `Logger` mixin eliminates per-class logger boilerplate
- Firebase access guarded behind `DefaultFirebaseOptions.isConfigured` for unconfigured environments
- Test infrastructure uses mocktail (no codegen), shared mocks, fabricators, and stubs

## Testing

```bash
fvm flutter test                                          # All tests
fvm flutter test test/accessibility/                      # Accessibility suite
fvm flutter test --tags accessibility --name "\[Level-A\]"   # Level A only (CI-blocking)
fvm flutter test --tags accessibility --name "\[Level-AA\]"  # Level AA only (informational)
fvm flutter test --exclude-tags accessibility              # Skip accessibility tests
```

**Test directories:** `test/bloc/`, `test/model/`, `test/widgets/`, `test/accessibility/`

**Accessibility tests** are organized by component type (screens, widgets, buttons, dialogs, app bars) and tagged by WCAG level. Level A tests block CI; Level AA tests report results without failing the build.

## CI/CD

GitHub Actions workflows handle the full pipeline:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `test.yml` | All PRs | Run tests, static analysis, security, accessibility |
| `build.yml` | All PRs | Debug builds for Android (Linux) and iOS (macOS, no codesign) |
| `_accessibility.yml` | Called by test | WCAG Level A (blocking) + Level AA (informational) + anti-pattern detection |
| `_security.yml` | Called by test | Dependency vulnerability scanning, OSV, Actions audit |
| `_check_deploy.yml` | Called by staging/production | Auto-detect signing secrets, skip unconfigured platforms |
| `staging.yml` | Push to `main` | Deploy staging builds (iOS + Android) |
| `production.yml` | Push to `production` | Deploy production builds (iOS + Android) |
| `production_*.yml` | Manual | Individual platform deploys (iOS, Android, Firebase) |

Deploy workflows auto-detect signing secrets (`MATCH_PASSWORD` for iOS, `ANDROID_KEYSTORE` for Android) and skip gracefully when not configured. Run `setup.dart` for copy-paste `gh secret set` commands.

## Deployment

```bash
# Deploy via CLI
bin/deploy android staging
bin/deploy ios staging
bin/deploy android production
bin/deploy ios production
bin/deploy android_firebase production
```

**Code signing setup:**
- **Android:** Add keystore to GitHub Secrets. See [docs/android.md](docs/android.md).
- **iOS:** Create the app in App Store Connect, update Fastlane config files (`ios/fastlane/`), and generate certs with `bundle exec fastlane match`.

The setup script prints `gh secret set` commands for configuring CI/CD secrets after Firebase setup completes.

## Flavors

| Flavor | Entry Point | Use Case |
|--------|-------------|----------|
| `staging` | `lib/main_staging.dart` | Development, QA, internal testing |
| `production` | `lib/main_production.dart` | App Store / Play Store releases |

Each flavor has its own app name, bundle ID, and Firebase configuration. Run with `fvm flutter run --flavor staging` or `fvm flutter run --flavor production`. VS Code launch configurations are included in `.vscode/launch.json`.

## Agent Skills

Two AI-assisted development skills are included in `.claude/skills/`:

- **`twinsun-flutter-upgrade`** -- Automate Flutter version upgrades with FVM (version switching, dependency resolution, breaking changes, testing, documentation)
- **`twinsun-flutter-accessibility`** -- Ensure WCAG 2.2 compliance when creating or modifying Flutter UI components

Skills activate automatically when relevant. See [docs/agent-skills.md](docs/agent-skills.md) for details.

## Documentation

| Document | Description |
|----------|-------------|
| [Android Deployment](docs/android.md) | Keystore setup, signing, Play Store configuration |
| [Agent Skills](docs/agent-skills.md) | AI-assisted development skills |
| [Upgrade History](docs/upgrade/) | Flutter version upgrade notes |
| [Changelog](CHANGELOG.md) | Release history |
| [CLAUDE.md](CLAUDE.md) | AI assistant project guidance |
