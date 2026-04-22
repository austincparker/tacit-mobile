---
name: twinsun-flutter-accessibility
description: Ensure all Flutter UI code is accessible and WCAG compliant. USE THIS SKILL PROACTIVELY whenever working in a Flutter project - when creating or updating ANY widget, screen, button, dialog, form, app bar, list item, card, or UI component. Also triggers when user mentions accessibility, a11y, WCAG, screen readers, Semantics, or asks for an audit. This skill should be referenced for ALL Flutter UI work to ensure accessibility from the start.
---

# Flutter Accessibility Audit & Improvement

**Objective:** Ensure ALL Flutter UI code is accessible from the start. This skill should be used proactively whenever creating or modifying any UI element - not just when explicitly asked about accessibility.

**WHEN TO USE THIS SKILL:**
- Creating a new widget, screen, button, dialog, form, or any UI component
- Modifying existing UI code
- Adding images, icons, or interactive elements
- User explicitly asks about accessibility
- Running an accessibility audit

**Reference Documentation:**
*   [Flutter Accessibility](https://docs.flutter.dev/ui/accessibility-and-localization/accessibility)
*   [Flutter Semantics Widget API](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
*   **[WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)** - Latest guidelines

**Core Principles:**
*   **Accessibility first:** Build accessible from the start, not as an afterthought
*   **Verify with tests:** Run `bin/accessibility_check` and `flutter test test/accessibility/`
*   **No questions needed:** When asked to audit, audit everything automatically

---

## Instructions

### For Accessibility Audits (run all steps)

1.  **Baseline:**
    *   Run `dart fix --apply` to apply automated fixes
    *   Run `flutter analyze` to ensure no analysis issues
    *   Run `flutter test` to establish the current passing state
    *   If baseline fails, **stop** and resolve issues before proceeding

2.  **Run Full Audit (do not ask user what to audit):**
    *   Run `bin/accessibility_check` for static anti-pattern detection
    *   Run `flutter test test/accessibility/` for all accessibility tests
    *   If either fails, identify and fix the issues
    *   **Component type mapping** (for adding new tests):
        - **Screens** → `screens_accessibility_test.dart`
        - **Widgets** → `widgets_accessibility_test.dart`
        - **Dialogs** → `dialogs_accessibility_test.dart`
        - **Forms** → `forms_accessibility_test.dart`
        - **AppBars** → `app_bars_accessibility_test.dart`
        - **Buttons** → `buttons_accessibility_test.dart`
        - **Other** → `[type]_accessibility_test.dart`

### For Creating/Modifying UI (apply inline)

When creating or modifying UI, ensure:

*   **IconButton** → Always add `tooltip`
*   **Image.asset/Image.network** → Add `semanticLabel` or `excludeFromSemantics: true`
*   **CachedNetworkImage** → Wrap in `Semantics` with label
*   **GestureDetector/InkWell** → Wrap in `Semantics` with `button: true` and `label`
*   **TextField/TextFormField** → Always use `labelText` in decoration
*   **Buttons** → Wrap custom buttons in `Semantics` with `button: true`
*   **Headers** → Wrap in `Semantics` with `header: true`
*   **Loading indicators** → Add `Semantics` with `label: 'Loading'`
*   **Error messages** → Add `Semantics` with `liveRegion: true`
*   **Touch targets** → Minimum 48x48 dp (Android) / 44x44 pt (iOS)
*   **Color contrast** → 4.5:1 for normal text, 3:1 for large text

3.  **Implement Fixes:**

    Apply the accessibility patterns above. Common fixes:
    
    ```dart
    // Wrap custom interactive elements
    Semantics(
      label: 'Description for screen readers',
      button: true,
      child: YourWidget(),
    )
    
    // IconButton - always add tooltip
    IconButton(
      icon: Icon(Icons.delete),
      tooltip: 'Delete item',
      onPressed: _handleDelete,
    )
    
    // Image with semantic label
    Image.asset('logo.png', semanticLabel: 'Company logo')
    
    // Decorative image
    Image.asset('background.png', excludeFromSemantics: true)
    
    // TextField - always use labelText
    TextField(
      decoration: InputDecoration(labelText: 'Email'),
    )
    ```

4.  **Add/Update Tests:**

    Add accessibility tests to the appropriate file in `test/accessibility/`.
    All test files must have `@Tags(['accessibility'])` at the top.
    Use `[Level-A]` or `[Level-AA]` prefixes in test names for WCAG level filtering.

    ```dart
    @Tags(['accessibility'])
    library;

    // Add to existing test file for component type
    group('YourWidget', () {
      // Level A: labeled tap targets (WCAG 1.1.1)
      testWidgets('[Level-A] meets labeled tap target guideline', (tester) async {
        await AccessibilityTestHelpers.testMeetsLevelAGuidelines(tester, const YourWidget());
      });

      // Level AA: contrast + tap target sizes (WCAG 1.4.3, 2.5.8)
      testWidgets('[Level-AA] meets contrast and tap target size guidelines', (tester) async {
        await AccessibilityTestHelpers.testMeetsLevelAAGuidelines(tester, const YourWidget());
      });

      // Semantic property checks are Level A
      testWidgets('[Level-A] has proper semantic properties', (tester) async {
        // ... verify labels, roles, headers ...
      });
    });
    ```

    Use helpers from `accessibility_test_helpers.dart`.

5.  **Verify:**
    
    ```bash
    flutter analyze
    bin/accessibility_check
    flutter test test/accessibility/
    ```

6.  **Update CI Anti-Pattern Checker (if needed):**

    If you found a new anti-pattern that can be caught statically, add it to `bin/accessibility_check`:
    
    ```bash
    # Read existing checks first
    cat bin/accessibility_check
    
    # Add new check using existing helper functions
    check_widget_property "NewWidget" "requiredProp" "message" "error|warning"
    ```

7.  **Report:**
    *   Summarize accessibility improvements made:
        *   Number of semantic labels added
        *   Touch targets fixed
        *   Elements excluded/merged
        *   Number of automated accessibility tests created/updated
        *   WCAG compliance level achieved (A, AA, AAA)
    *   List any issues deferred for future iteration (maintain finite scope).
    *   **Do not commit or push.**
    *   Provide a suggested Git commit message (e.g., "Add semantic labels and automated tests for [ScreenName]").

