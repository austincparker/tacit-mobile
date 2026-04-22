---
name: twinsun-flutter-upgrade
description: Automate upgrading Flutter projects to a new version using FVM. Handles version switching, dependency resolution, breaking changes analysis, testing, version reference updates, and documentation. Use when user asks to "upgrade flutter to X.X.X" or similar upgrade requests.
---

# Flutter Version Upgrade with FVM

**Objective:** Systematically upgrade a Flutter project to a new version using FVM, ensuring all version references are updated, breaking changes are addressed, tests pass, and documentation is complete.

**Reference Documentation:**
- Flutter Changelog: https://github.com/flutter/flutter/blob/stable/CHANGELOG.md
- Breaking Changes: https://docs.flutter.dev/release/breaking-changes
- FVM Documentation: https://fvm.app/documentation/getting-started

**Core Principles:**
- **Known good state:** Verify baseline (tests pass, analyzer clean) before upgrading
- **Actionable verification:** Use deterministic commands for self-correction
- **Finite scoping:** One version upgrade at a time
- **Report & review loop:** End with summary and suggested commit, never auto-commit

---

## 1. Baseline: Verify Known Good State

Establish clean baseline before proceeding:

```bash
# Check current version
fvm flutter --version
cat .fvmrc

# Verify clean git state
git status  # Should be clean

# Apply automated fixes
dart fix --apply

# Run analyzer
fvm flutter analyze  # Must pass - STOP if fails

# Run tests
fvm flutter test  # Must pass - STOP if fails
```

**If baseline fails at any step, STOP and fix issues before proceeding.**

---

## 2. Identify Target Version

1. **Confirm target version with user** (e.g., "3.38.9" → "3.40.0")
2. **Determine upgrade type:** Major, minor, or patch
3. **Create docs directory:** `mkdir -p docs/upgrade`

---

## 3. Research Breaking Changes

Use `WebFetch` to research changes:

```bash
# Fetch Flutter changelog for version range
# Focus on breaking changes between current and target version
```

**Create documentation files:**
- `docs/upgrade/changelog-[current]-to-[target].md` - Version-specific changelog
- `docs/upgrade/breaking-changes-[major-version].md` - If crossing major/minor versions
- `docs/upgrade/migration-summary.md` - Completed upgrade summary

**Analyze codebase impact:**
- Use `Grep` to search for deprecated API patterns
- Document which breaking changes affect this project
- Note: Many upgrades have zero breaking changes affecting the project

---

## 4. Execute FVM Upgrade

Run commands in sequence:

```bash
# Install and activate target version
fvm install [TARGET_VERSION]
fvm use [TARGET_VERSION] --force

# Clean and update
fvm flutter clean
fvm flutter pub get

# Precache platform tools
fvm flutter precache --ios
fvm flutter precache --android

# Update iOS dependencies
cd ios && pod repo update && pod install && cd ..
```

---

## 5. Update ALL Version References

**CRITICAL:** Update version in ALL files, not just `.fvmrc`

1. **Search for old version references:**
   ```bash
   # Use Grep to find all references to old version
   # Example: Search for "3.38.0" if upgrading from 3.38.0
   ```

2. **Update these files:**
   - ✅ `.fvmrc` (auto-updated by `fvm use`)
   - ✅ `CLAUDE.md` - Requirements section
   - ✅ `README.md` - Features section
   - ✅ `.vscode/settings.json` - `dart.flutterSdkPath`
   - ✅ `pubspec.yaml` - `environment.flutter` constraint
   - ✅ Any other project-specific files with version references

3. **Verify Dart SDK consistency:**
   - Check `pubspec.yaml` for Dart SDK constraint
   - Update `CLAUDE.md` to match `pubspec.yaml`
   - Example: `Dart SDK: >=3.0.2 <4.0.0 (constraint from pubspec.yaml)`
   - Note Flutter's included Dart version: `Flutter: 3.38.9 (includes Dart 3.10.8)`

4. **Search again to confirm:**
   ```bash
   # Use Grep to verify no old version references remain
   # Ignore upgrade docs (they intentionally reference old versions)
   ```

---

## 6. Address Breaking Changes

```bash
# Run automated migration
dart fix --dry-run  # Review suggestions
dart fix --apply    # Apply fixes

# Run analyzer
fvm flutter analyze  # Must pass
```

**If breaking changes found:**
- Use `Grep` to find affected code patterns
- Update code to use new APIs
- Document changes in migration summary

**Most upgrades:** Patch/minor releases often have zero breaking changes.

---

## 7. Rebuild and Verify

```bash
# Rebuild code generation
fvm flutter pub run build_runner clean
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Verify analyzer
fvm flutter analyze  # Must be clean

# Run all tests
fvm flutter test  # All must pass
fvm flutter test test/accessibility/  # Accessibility tests

# Test platform builds
fvm flutter build apk --flavor staging
fvm flutter build ios --flavor staging --no-codesign  # macOS only
```

**Success criteria:** Analyzer clean, all tests pass, builds succeed

---

## 8. Create Migration Documentation

Create `docs/upgrade/migration-summary.md` with:

```markdown
# Flutter [OLD] → [NEW] Migration Summary

**Upgrade Date:** [DATE]
**Flutter Version:** [OLD] → [NEW] (Patch/Minor/Major Release)
**Dart Version:** [OLD_DART] → [NEW_DART]

## Executive Summary
✅ Successful upgrade with [zero/N] code changes required
✅ [Zero/N] breaking changes affecting this codebase
✅ All tests passing, builds verified, analyzer clean

## Changes Made

### Configuration Files Updated
1. `.fvmrc` - Updated to [NEW]
2. `CLAUDE.md` - Updated version references
3. `README.md` - Updated features list
4. `.vscode/settings.json` - Updated SDK path
5. `pubspec.yaml` - Updated Flutter constraint
6. [Any other files]

### Code Changes
[List any code changes, or "None required"]

### Documentation Created
- `docs/upgrade/changelog-[old]-to-[new].md`
- `docs/upgrade/migration-summary.md`
- [Breaking changes docs if applicable]

## Breaking Changes Analysis
✅ **[N] breaking changes affected this project**

[List reviewed changes and their impact]

## Testing Results
| Test Suite | Result | Notes |
|------------|--------|-------|
| Unit Tests | ✅ Pass | All passing |
| Widget Tests | ✅ Pass | No regressions |
| Accessibility | ✅ Pass | WCAG 2.2 AA maintained |

### Build Verification
| Platform | Flavor | Result |
|----------|--------|--------|
| Android | Staging | ✅ Success |
| iOS | Staging | ✅ Success |

## Success Criteria
All criteria met ✅
- [x] FVM updated to [NEW]
- [x] ALL version references updated
- [x] All tests passing
- [x] Builds successful
- [x] Analyzer clean
- [x] Documentation updated

**Status:** ✅ COMPLETED SUCCESSFULLY
```

---

## 9. Report & Review

**Summarize for user:**

1. **Version Change:** [OLD] → [NEW]

2. **Files Modified:**
   - Configuration: `.fvmrc`, `CLAUDE.md`, `README.md`, `.vscode/settings.json`, `pubspec.yaml`
   - Code: [List files or "None"]
   - Total: [N] files

3. **Breaking Changes:** [N affected / all reviewed]

4. **Test Results:**
   - Tests: ✅ All passing
   - Builds: ✅ Android + iOS successful
   - Analyzer: ✅ Clean

5. **Documentation:** Created in `docs/upgrade/`

**Action:** Ask user to review changes, especially:
- All version reference updates
- Configuration file changes
- Any code changes
- Test and build results

**Do not commit or push.**

**Suggested commit message:**
```
Upgrade Flutter from [OLD] to [NEW]

- Updated FVM configuration (.fvmrc)
- Updated all version references (CLAUDE.md, README.md, .vscode/settings.json, pubspec.yaml)
- [Applied dart fix migrations - if applicable]
- [Addressed breaking changes: list if any]
- Rebuilt code generation
- Updated CocoaPods dependencies (iOS)
- All tests passing, analyzer clean, builds verified
- Created upgrade documentation in docs/upgrade/

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Common Breaking Changes Reference

Search for these patterns when analyzing breaking changes:

### Widget API Changes
- `DropdownButtonFormField`: `value` → `initialValue`
- `AppBar`: Direct `color` → Use `AppBarTheme`
- `SnackBar`: Auto-dismiss behavior
- `Form`: Sliver context support
- `Visibility`: `maintainState` behavior

### Semantics (Accessibility)
- `Semantics`: `elevation`/`thickness` removed
- Screen reader behavior updates
- Touch target size requirements

### Platform-Specific
- **Android:** ABI filters, predictive back, Gradle versions
- **iOS:** UISceneDelegate, wide gamut colors, CocoaPods versions

---

## Troubleshooting

### CocoaPods fails
```bash
fvm flutter precache --ios
cd ios && pod install && cd ..
```

### Build fails
```bash
fvm flutter clean
rm -rf ios/Pods ios/Podfile.lock android/.gradle android/app/build
fvm flutter pub get
cd ios && pod install && cd ..
```

### Tests fail with version mismatch
```bash
fvm flutter pub run build_runner clean
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Analyzer errors
- Review breaking changes docs
- Apply `dart fix --apply`
- Search Flutter migration guide
- Update deprecated API usage manually

---

## Checklist

Before completing, verify:

- [ ] Baseline was clean
- [ ] **ALL version references updated** (use Grep to verify)
- [ ] FVM config updated (`.fvmrc`)
- [ ] CLAUDE.md updated
- [ ] README.md updated
- [ ] .vscode/settings.json updated
- [ ] pubspec.yaml updated
- [ ] Dart SDK docs consistent with pubspec.yaml
- [ ] Dependencies resolved
- [ ] Analyzer passes
- [ ] All tests pass
- [ ] Builds successful (Android + iOS)
- [ ] CocoaPods updated
- [ ] Code generation rebuilt
- [ ] Documentation created in docs/upgrade/
- [ ] Breaking changes researched
- [ ] Migration summary complete
- [ ] Commit message prepared
- [ ] Did NOT auto-commit

---

## Success Criteria

✅ FVM reports correct version: `fvm flutter --version`
✅ ALL version references updated (verified with Grep)
✅ Analyzer clean: `fvm flutter analyze`
✅ Tests pass: `fvm flutter test`
✅ Builds succeed for both platforms
✅ No new deprecation warnings
✅ Documentation complete
✅ User reviewed and approved

---

## Key Lessons

**Critical steps often missed:**
1. Updating ALL version references (not just .fvmrc)
2. Searching entire codebase for old version strings
3. Updating .vscode/settings.json SDK path
4. Ensuring Dart SDK docs match pubspec.yaml
5. Creating iterative documentation for team

**This skill handles ONE upgrade at a time (finite scoping)**
