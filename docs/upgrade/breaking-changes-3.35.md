# Flutter 3.35 Breaking Changes

This document details all breaking changes introduced in Flutter 3.35 and their impact on this project.

## 1. Component Theme Normalization Updates

**Status:** ✅ No Impact

**Description:** Component themes were normalized for consistency across Material widgets.

**Migration:** Review custom theme configurations to ensure they follow the new normalized patterns.

**Impact on This Project:**
- Checked: `lib/themes/default_theme.dart`
- Result: Already using modern AppBarTheme with proper Material Design 3 properties
- Action Required: None

---

## 2. Deprecate `DropdownButtonFormField` `value` Parameter

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** The `value` parameter in `DropdownButtonFormField` is deprecated in favor of `initialValue` for consistency with other form field widgets.

**Migration:**
```dart
// Old (deprecated)
DropdownButtonFormField(
  value: selectedValue,
  items: items,
)

// New
DropdownButtonFormField(
  initialValue: selectedValue,
  items: items,
)
```

**Impact on This Project:**
- Searched: All Dart files for `DropdownButtonFormField`
- Result: No usage found
- Action Required: None

---

## 3. Deprecate AppBar Color

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** Direct `color` parameter on AppBar is deprecated. Use `AppBarTheme` for color customization instead.

**Migration:**
```dart
// Old (deprecated)
AppBar(
  color: Colors.blue,
  title: Text('Title'),
)

// New
AppBar(
  title: Text('Title'),
)

// In theme configuration
ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue,
  ),
)
```

**Impact on This Project:**
- Checked: `lib/themes/default_theme.dart`
- Result: Already using AppBarTheme properly:
  ```dart
  const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    shadowColor: Colors.black,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  );
  ```
- Action Required: None

---

## 4. Redesigned the `Radio` Widget

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** Radio widget API was redesigned for better Material 3 compliance.

**Impact on This Project:**
- Searched: All Dart files for `Radio(`
- Result: No usage found
- Action Required: None

---

## 5. Removed Semantics Elevation and Thickness

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** `elevation` and `thickness` properties were removed from `Semantics` and `SemanticsProperties`.

**Migration:**
```dart
// Old (no longer supported)
Semantics(
  elevation: 2.0,
  thickness: 1.0,
  child: widget,
)

// New (remove these properties)
Semantics(
  child: widget,
)
```

**Impact on This Project:**
- Searched: All Dart files for `Semantics.*elevation` and `Semantics.*thickness`
- Result: No usage found
- Action Required: None

---

## 6. The `Form` Widget No Longer Supports Being a Sliver

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** `Form` widget can no longer be used directly in sliver contexts (like `CustomScrollView`).

**Migration:**
```dart
// Old (no longer supported)
CustomScrollView(
  slivers: [
    Form(
      child: SliverList(...),
    ),
  ],
)

// New
Form(
  child: CustomScrollView(
    slivers: [
      SliverList(...),
    ],
  ),
)
```

**Impact on This Project:**
- Checked: `lib/widgets/login_form.dart`, `lib/screens/login_screen.dart`
- Result: No Form widgets used in sliver contexts. Forms use regular Column layout.
- Action Required: None

---

## 7. Flutter Now Sets Default `abiFilters` in Android Builds

**Status:** ✅ Expected Behavior

**Affected:** Flutter 3.35+

**Description:** Android builds now include default ABI filters automatically. This reduces APK size by only including necessary native libraries.

**Default ABI Filters:**
- `armeabi-v7a` (32-bit ARM)
- `arm64-v8a` (64-bit ARM)
- `x86_64` (64-bit x86)

**Impact on This Project:**
- Checked: `android/app/build.gradle.kts`
- Result: No explicit ABI filters configured
- Expected Behavior: Flutter will automatically add default filters
- APK Size: Will be optimized automatically
- Action Required: None (this is a positive change)

**Note:** If you need to override default ABI filters, you can do so in `build.gradle.kts`:
```kotlin
defaultConfig {
    ndk {
        abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
    }
}
```

---

## 8. The `Visibility` Widget Focusability Change

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** When `maintainState: true` is set, the `Visibility` widget is no longer focusable by default.

**Migration:**
```dart
// Old behavior (auto-focusable with maintainState)
Visibility(
  visible: isVisible,
  maintainState: true,
  child: widget,
)

// New (need explicit flag for focusability)
Visibility(
  visible: isVisible,
  maintainState: true,
  maintainInteractivity: true, // Add this if focusability needed
  child: widget,
)
```

**Impact on This Project:**
- Searched: All Dart files for `Visibility.*maintainState`
- Result: No usage found
- Action Required: None

---

## 9. Merged Threads on macOS and Windows

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** Platform thread handling was consolidated on macOS and Windows for better performance.

**Impact on This Project:**
- This is an internal engine change
- No code changes required
- Expected benefit: Improved performance on desktop platforms
- Action Required: None

---

## 10. `$FLUTTER_ROOT/version` Replaced by `$FLUTTER_ROOT/bin/cache/flutter.version.json`

**Status:** ✅ No Impact

**Affected:** Flutter 3.35+

**Description:** The Flutter version file location changed for better tooling support.

**Migration:** Update any scripts that reference the version file:
```bash
# Old
cat $FLUTTER_ROOT/version

# New
cat $FLUTTER_ROOT/bin/cache/flutter.version.json
```

**Impact on This Project:**
- Checked: All scripts in `bin/`, `setup/`, CI/CD workflows
- Result: No scripts reference `$FLUTTER_ROOT/version`
- Action Required: None

---

## Summary

**Total Breaking Changes:** 10
**Breaking Changes Affecting This Project:** 0 ✅

All Flutter 3.35 breaking changes have been reviewed. This project uses modern Flutter patterns and is not affected by any of the breaking changes. The codebase is fully compatible with Flutter 3.35+.

### Recommendations

1. ✅ Continue using current code patterns - they're all modern and compatible
2. ✅ Default ABI filters will optimize APK size automatically
3. ✅ Thread merging on desktop will improve performance
4. ✅ No code changes required for Flutter 3.35 compatibility

---

**Documentation Links:**
- [Component theme normalization](https://docs.flutter.dev/release/breaking-changes/component-theme-normalization-updates)
- [DropdownButtonFormField deprecation](https://docs.flutter.dev/release/breaking-changes/deprecate-dropdownbuttonformfield-value)
- [AppBar color deprecation](https://docs.flutter.dev/release/breaking-changes/appbar-theme-color)
- [Radio redesign](https://docs.flutter.dev/release/breaking-changes/radio-api-redesign)
- [Semantics changes](https://docs.flutter.dev/release/breaking-changes/remove-semantics-elevation-and-thickness)
- [Form sliver support](https://docs.flutter.dev/release/breaking-changes/form-semantics)
- [Default ABI filters](https://docs.flutter.dev/release/breaking-changes/default-abi-filters-android)
- [Visibility focusability](https://docs.flutter.dev/release/breaking-changes/visibility-maintainfocusability)
- [macOS/Windows threads](https://docs.flutter.dev/release/breaking-changes/macos-windows-merged-threads)
- [Version file location](https://docs.flutter.dev/release/breaking-changes/flutter-root-version-file)
