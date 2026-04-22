# Agent Skills

This directory contains project-specific Agent Skills that enhance AI-assisted development for this Flutter app. Skills follow the [Agent Skills open standard](https://agentskills.io/specification).

## Available Skills

- **`twinsun-flutter-upgrade`** — Automate Flutter version upgrades with FVM (version switching, dependency resolution, breaking changes analysis, testing, documentation)
- **`twinsun-flutter-accessibility`** — Ensure Flutter UI code meets WCAG 2.2 compliance (activates automatically when creating or modifying UI components)

## How Skills Work

Skills activate automatically based on your requests. When an AI tool detects a task that matches a skill's description, it loads the full instructions and follows them.

**`twinsun-flutter-upgrade`** activates when you:
- Ask to upgrade Flutter to a specific version
- Run a version migration

**`twinsun-flutter-accessibility`** activates when you:
- Create or modify any Flutter UI element (widget, screen, button, dialog, form)
- Ask about accessibility, a11y, WCAG, or screen readers

## Storage

Skills live in `.claude/skills/` and are version-controlled with the project. All team members get them automatically.
