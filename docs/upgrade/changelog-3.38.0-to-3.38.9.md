# Flutter Changelog: 3.38.0 → 3.38.9

**This PR:** Upgrade from 3.38.0 to 3.38.9 (patch release)
**Upgrade Date:** 2026-02-10
**Dart Version:** 3.10.0 → 3.10.8

> **Note:** This is a patch release upgrade with bug fixes and stability improvements only. No breaking changes in this range.

---

## Version 3.38.9

**Dart Version:** 3.10.8

### Changes
- Update Dart to 3.10.8

---

## Version 3.38.8

### Bug Fixes
- **Chrome/Development:** Fixed startup crash during application shutdown with `DartDevelopmentServiceException`

---

## Version 3.38.7

### Bug Fixes
- **Multi-device Testing:** Fixed execution failure when running with `-d all` flag

---

## Version 3.38.6

### Platform-Specific Changes

#### Android
- **AGP 9.0.0 Migration:** Apps require migration steps when upgrading to Android Gradle Plugin 9.0.0
- **Accessibility:** Fixed crash when platform views are hidden and accessibility features interact with them

#### iOS
- **WebView:** Corrected scrolling behavior on iOS 26
- **Virtual Keyboard:** Improved handling on Android web

### Tooling
- **Widget Preview:** Resolved disk usage issue

---

## Version 3.38.5

**Dart Version:** 3.10.4

### Changes
- Update Dart to 3.10.4

---

## Version 3.38.4

### Platform-Specific Changes

#### Linux
- **Desktop Embedder:** Addressed Skia rendering issues

#### Web
- **Chrome:** Removed sandbox warning from debug launches

### Tooling
- **Widget Preview:** Fixed crash prevention for missing scaffold directories
- **File System Watcher:** Improved stability

---

## Version 3.38.3

### Bug Fixes
- **Engine:** Resolved version mismatch
- **Dart:** Upgraded to 3.10.1

---

## Version 3.38.2

### Tooling Issues Fixed
- **Widget Preview:** Fixed exit crash during file analysis
- **iOS Add-to-App:** Resolved build error: "Improperly formatted define flag"
- **iOS Debugging:** Fixed hanging when debugging on physical iOS 26 devices

---

## Version 3.38.1

**Dart Version:** 3.10 stable

### Changes
- Added support for Dart 3.10 stable

---

## Summary

### Impact on This Project
✅ **LOW RISK** - Patch release with bug fixes and stability improvements only
✅ **No Breaking Changes** - All changes are backwards compatible
✅ **No Code Changes Required** - Configuration update only

### Key Improvements
1. **Stability:** Multiple crash fixes across platforms (iOS debugging, widget preview, multi-device testing)
2. **Tooling:** Improved widget preview and file system watcher
3. **Platform Support:** Better iOS 26 compatibility, Android accessibility fixes
4. **Dart:** Progression from 3.10.0 to 3.10.8 (patch updates)

### Verification
- ✅ All tests pass
- ✅ Analyzer clean
- ✅ Android and iOS builds succeed
- ✅ No deprecated API warnings
