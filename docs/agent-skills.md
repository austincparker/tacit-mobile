# Agent Skills

This Tacit mobile includes Agent Skills for AI-assisted development. Skills follow the [Agent Skills open standard](https://agentskills.io/specification) and are stored in `.claude/skills/`.

## Available Skills

### twinsun-flutter-upgrade

Automates Flutter version upgrades using FVM. Handles version switching, dependency resolution, breaking changes analysis, testing, version reference updates across the project, and documentation.

**Activates when you:**
- Ask to upgrade Flutter to a specific version
- Run a version migration

### twinsun-flutter-accessibility

Ensures Flutter UI code meets WCAG 2.2 Level AA compliance. Activates proactively when working with UI components to catch accessibility issues early.

**Activates when you:**
- Create or modify any Flutter UI element (widget, screen, button, dialog, form, app bar, card, list item)
- Ask about accessibility, a11y, WCAG, Semantics, or screen readers
- Request an accessibility audit

## How Skills Work

Skills use automatic activation. When an AI tool detects a task that matches a skill's description, it loads the full `SKILL.md` instructions and follows them. No manual invocation is required, though you can reference a skill by name to force activation.

## Storage

Skills live in `.claude/skills/` and are version-controlled with the project. All team members using Claude Code get them automatically.

## Updating Skills

When skills are updated in the Tacit mobile, pull the latest changes:

```bash
cd /path/to/tacit-mobile
git pull
```

Projects created from this template inherit the skills at creation time. To update skills in an existing project, copy from the latest template:

```bash
cp -r /path/to/tacit-mobile/.claude/skills/twinsun-* /path/to/your-project/.claude/skills/
```

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Claude Code Skills Documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/skills)
- [Skills README](../.claude/skills/README.md) -- in-repo skill listing
