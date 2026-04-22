# Claude Code Permissions Guide

This guide explains the permissions system for Claude Code Agent Skills and how to configure them for this project.

## Overview

Claude Code uses a scoped permissions model defined in `.claude/settings.local.json` to control which commands Claude can execute without prompting for approval. This provides security while enabling Agent Skills to work efficiently.

**Key Principle:** Only allow commands that are safe, reversible, or read-only. All git operations and destructive commands require explicit user approval.

---

## Setup Instructions

### 1. Create Your Permissions File

```bash
# Copy the example file
cp .claude/settings.local.json.example .claude/settings.local.json
```

The file is already valid JSON and ready to use! No modifications needed unless you want to customize permissions.

### 2. Understand the Structure

```json
{
  "_readme": "See PERMISSIONS.md for setup instructions",
  "permissions": {
    "allow": [
      "Bash(command-pattern:*)"
    ]
  }
}
```

- `_readme`: Optional field for documentation reference (ignored by Claude)
- `permissions.allow`: Array of command patterns that Claude can execute without asking

### 3. Customize (Optional)

Edit `.claude/settings.local.json` to add or remove permissions based on your workflow preferences.

---

## Default Permissions Explained

This project's default permissions allow Flutter development operations that are safe and commonly needed by Agent Skills:

### 1. FVM Version Management
```json
"Bash(fvm use:*)"
```

**Purpose:** Switch between Flutter versions
**Safety:** ✅ Safe - Only modifies `.fvmrc` configuration file
**Used by:** `twinsun-flutter-upgrade` skill
**Example:** `fvm use 3.38.9`

---

### 2. FVM Installation
```json
"Bash(fvm install:*)"
```

**Purpose:** Download Flutter SDK versions
**Safety:** ✅ Safe - Downloads to `.fvm/` directory only
**Used by:** `twinsun-flutter-upgrade` skill
**Example:** `fvm install 3.38.9`

---

### 3. Clean Build Artifacts
```json
"Bash(fvm flutter clean:*)"
```

**Purpose:** Remove build artifacts and caches
**Safety:** ✅ Safe - Only removes disposable build files
**Used by:** `twinsun-flutter-upgrade` skill
**Example:** `fvm flutter clean`

**What it removes:**
- `build/` directory
- `.dart_tool/` cache
- Platform-specific build files
- Does NOT remove source code or configuration

---

### 4. Fetch Dependencies
```json
"Bash(fvm flutter pub get:*)"
```

**Purpose:** Download packages and resolve dependencies
**Safety:** ✅ Safe - Reads `pubspec.yaml` and downloads packages to `.pub-cache/`
**Used by:** `twinsun-flutter-upgrade` skill
**Example:** `fvm flutter pub get`

**What it does:**
- Resolves dependency versions
- Downloads packages from pub.dev
- Updates `pubspec.lock`
- Does NOT modify source code

---

### 5. Automated Code Migrations
```json
"Bash(dart fix:*)"
```

**Purpose:** Apply automated code fixes for deprecated APIs
**Safety:** ⚠️ **CAUTION** - Modifies source code
**Used by:** `twinsun-flutter-upgrade` skill
**Examples:**
- `dart fix --dry-run` (preview only, always safe)
- `dart fix --apply` (applies changes, requires review)

**Why allowed:**
- Agent Skills use "report & review" pattern - changes are reviewed before commit
- Skills verify baseline state (tests passing) before applying fixes
- Changes are deterministic and follow Flutter's official migration rules
- You can always revert with git if needed

**Best Practice:** Consider splitting into two permissions for more control:
```json
"Bash(dart fix --dry-run:*)",  // Always safe (preview only)
"Bash(dart fix --apply:*)"     // Requires careful review
```

---

### 6. Static Analysis
```json
"Bash(fvm flutter analyze:*)"
```

**Purpose:** Run Dart analyzer on codebase
**Safety:** ✅ Safe - Read-only static analysis
**Used by:** All Agent Skills for verification
**Example:** `fvm flutter analyze`

**What it checks:**
- Code errors and warnings
- Deprecated API usage
- Style violations (per `analysis_options.yaml`)
- Does NOT modify any files

---

## Security Best Practices

### ✅ Safe Commands (Allowed by Default)

- **FVM operations:** `fvm use`, `fvm install`, `fvm list`
- **Flutter commands:** `flutter analyze`, `flutter test`, `flutter doctor`
- **Build operations:** `flutter clean`, `flutter pub get`
- **Read-only commands:** `cat`, `ls`, `git status`, `git diff`

### ⚠️ Caution Commands (Require Review)

- **dart fix --apply:** Modifies source code (allowed but changes are reviewed)
- **Code generation:** `flutter pub run build_runner` (regenerates files)

### ❌ Blocked Commands (Require Explicit Approval)

All git operations require explicit user approval:
- `git add` - Staging changes
- `git commit` - Creating commits
- `git push` - Pushing to remote
- `git reset` - Resetting changes
- `git checkout` - Switching branches

Other blocked operations:
- `rm -rf` - Deleting files (except in troubleshooting with explicit approval)
- `sudo` - System-level commands
- Deployment scripts
- Database operations

---

## Agent Skills Security Principles

All Agent Skills in this project follow these security principles:

### 1. Known Good State
Skills verify the baseline before making changes:
- Tests must pass
- Analyzer must be clean
- Git status should be clean

### 2. No Auto-Commit
Skills NEVER commit or push changes automatically. They:
- Make changes
- Report what was done
- Provide suggested commit message
- Wait for human approval

### 3. Report & Review Loop
Skills end with a summary for human review:
- What changed
- Test results
- Suggested next steps
- **Action required:** You review and decide to commit

### 4. Actionable Verification
Skills use deterministic commands for self-correction:
- `flutter test` - Verify functionality
- `flutter analyze` - Check code quality
- `dart fix --apply` - Apply automated migrations

---

## Customization

### Adding Permissions

To allow additional commands, add patterns to the `allow` array:

```json
{
  "permissions": {
    "allow": [
      "Bash(fvm use:*)",
      // ... existing permissions ...
      "Bash(flutter build:*)",  // Allow build commands
      "Bash(firebase deploy:*)" // Allow Firebase deployment
    ]
  }
}
```

### Removing Permissions

Remove any permission pattern you're not comfortable with. Skills will prompt for approval when needed.

### Wildcard Patterns

- `*` matches any characters
- `Bash(flutter test:*)` matches `flutter test`, `flutter test --coverage`, etc.
- `Bash(fvm flutter *:*)` matches any `fvm flutter` command

---

## Troubleshooting

### "Permission denied" errors

If Claude asks for approval for commands that should be allowed:

1. Check that the command pattern matches the permission in `settings.local.json`
2. Restart Claude Code to reload permissions
3. Verify the file is in `.claude/settings.local.json` (not the .example file)

### Overly permissive

If you're uncomfortable with certain permissions:

1. Remove the permission from `settings.local.json`
2. Claude will prompt for approval when needed
3. You can approve case-by-case

### File not working

Ensure:
- File is named exactly `.claude/settings.local.json`
- File contains valid JSON (no comments with `//`)
- File is in the project root's `.claude/` directory

---

## Additional Resources

- **Claude Code Permissions Docs:** https://docs.anthropic.com/claude/docs/claude-code-permissions
- **Agent Skills Specification:** https://agentskills.io/specification
- **Flutter Security:** https://flutter.dev/security
- **This Project's Agent Skills:** See `.claude/skills/README.md` or `.cursor/skills/README.md`

---

## Questions?

If you have questions about permissions or Agent Skills security:

1. Review this document
2. Check the [Claude Code documentation](https://docs.anthropic.com/claude/docs/claude-code-permissions)
3. Ask in your team's communication channel
4. File an issue if you discover security concerns

**Remember:** When in doubt, don't add a permission. Claude will ask for approval and you can decide case-by-case.
