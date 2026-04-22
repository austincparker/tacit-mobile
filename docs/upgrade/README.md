# Flutter Upgrade Documentation

This directory contains comprehensive documentation for Flutter version upgrades performed on this project.

## Purpose

This documentation serves multiple purposes:

1. **Historical Reference**: Track what versions were upgraded and what changed
2. **Team Knowledge**: Help team members understand Flutter version requirements
3. **Future Upgrades**: Provide patterns and lessons learned for future upgrade work
4. **Breaking Changes Analysis**: Document which breaking changes were reviewed and their impact

## Documentation Structure

Each Flutter upgrade should create the following files:

### 1. Migration Summary (`migration-summary.md`)

**Purpose**: Executive summary of the completed upgrade

**Contains**:
- Upgrade date and version change
- Executive summary (success/failure, code changes required)
- Configuration files updated
- Breaking changes impact analysis
- Test results and build verification
- Success criteria checklist

**Example**: For 3.38.0 → 3.38.9 upgrade, this file documents that all tests passed, zero code changes were required, and all version references were updated.

### 2. Version-Specific Changelog (`changelog-X.X.X-to-Y.Y.Y.md`)

**Purpose**: Detailed changelog between two specific versions

**Contains**:
- Release type (major/minor/patch)
- Dart SDK version changes
- New features added in this version range
- Breaking changes (even if they don't affect this project)
- Deprecations to be aware of
- Bug fixes relevant to this project

**Example**: `changelog-3.38.0-to-3.38.9.md` covers changes in the specific patch release range.

### 3. Breaking Changes by Major/Minor Version (`breaking-changes-X.XX.md`)

**Purpose**: Comprehensive reference of breaking changes for a major/minor Flutter version

**Contains**:
- All breaking changes introduced in that Flutter version
- Migration instructions from Flutter team
- Which changes affect this specific project (marked clearly)
- Code patterns to search for when reviewing impact
- Links to official Flutter documentation

**Why These Exist**: When upgrading from version A to version B, you need to review breaking changes for ALL major/minor versions between A and B, even if most don't affect your project.

**Example**: Upgrading from 3.38.0 → 3.38.9 is a patch release with no breaking changes, but we document 3.35 and 3.38 breaking changes because:
- They provide context for this Flutter version's API changes
- Future upgrades may start from this version
- Team members may reference these when debugging
- It's the pattern for future upgrades (document all reviewed breaking changes)

## Upgrade Type Guidance

### Patch Releases (e.g., 3.38.0 → 3.38.9)

**Expected Impact**: Minimal to none
- Typically bug fixes only
- No breaking changes
- No code changes required (usually)
- Focus on version reference updates

**Documentation**:
- Always create migration summary
- Create version-specific changelog
- Reference existing breaking changes docs for context

### Minor Releases (e.g., 3.35.0 → 3.38.0)

**Expected Impact**: Low to moderate
- New features available
- Possible deprecations (not breaking yet)
- Some breaking changes (varies by release)
- May require code changes

**Documentation**:
- Migration summary (required)
- Version-specific changelog (required)
- Breaking changes documentation for the new minor version (required)
- Update or create major version breaking changes doc

### Major Releases (e.g., 2.x.x → 3.0.0)

**Expected Impact**: High
- Significant API changes
- Many breaking changes expected
- Code changes required
- Migration guides from Flutter team

**Documentation**:
- Comprehensive migration summary
- Detailed changelog
- Complete breaking changes documentation
- Migration guide with before/after examples
- Testing plan and results

## Best Practices

### During Upgrade

1. **Research First**: Read Flutter changelog and breaking changes BEFORE starting
2. **Document Everything**: Capture all breaking changes reviewed, even if they don't affect this project
3. **Test Thoroughly**: Run full test suite, analyzer, and platform builds
4. **Update All References**: Search entire project for old version strings (use Grep)

### After Upgrade

1. **Create Complete Documentation**: Don't skip documentation steps
2. **Mark Project Impact**: Clearly indicate which breaking changes affected this project
3. **Note Lessons Learned**: Add insights to help future upgrades
4. **Update CLAUDE.md**: Keep version requirements current

## Example: 3.38.0 → 3.38.9 Upgrade

This upgrade demonstrates the pattern:

```
docs/upgrade/
├── README.md (this file)
├── migration-summary.md (executive summary - upgrade successful, zero code changes)
├── changelog-3.38.0-to-3.38.9.md (specific changes in this patch release)
├── breaking-changes-3.35.md (reference - reviewed for context)
└── breaking-changes-3.38.md (reference - reviewed for context)
```

**Why breaking changes docs exist**: Even though 3.38.0 → 3.38.9 is a patch release with no breaking changes, we document 3.35 and 3.38 breaking changes because:
- We reviewed them during upgrade research
- They provide context for Flutter 3.38's API surface
- Future upgrades starting from 3.38.9 will need this reference
- Establishes pattern: always document breaking changes reviewed

## Future Upgrades

When performing future upgrades:

1. **Follow the twinsun-flutter-upgrade skill** (`.cursor/skills/twinsun-flutter-upgrade/SKILL.md` or `.claude/skills/twinsun-flutter-upgrade/SKILL.md`)
2. **Create all three document types** (migration summary, changelog, breaking changes)
3. **Use this directory as reference** for documentation structure
4. **Update this README** if you discover better patterns

## Key Lessons

From the 3.38.0 → 3.38.9 upgrade:

1. **Update ALL version references**: Not just `.fvmrc`, but also:
   - `CLAUDE.md` (Requirements section)
   - `README.md` (Features section)
   - `.vscode/settings.json` (SDK path)
   - `pubspec.yaml` (Flutter constraint)
   - Any other project-specific files

2. **Use Grep to verify**: Search for old version string before and after updating

3. **Document iteratively**: Create documentation during the upgrade, not after

4. **Test comprehensively**: Analyzer, tests, and platform builds must all pass

5. **Preserve Dart SDK consistency**: Ensure `CLAUDE.md` matches `pubspec.yaml` Dart SDK constraint

## Questions?

Refer to:
- The `twinsun-flutter-upgrade` skill for upgrade procedures
- `migration-summary.md` for example documentation
- Flutter's official upgrade documentation: https://docs.flutter.dev/release/upgrade
- Flutter's breaking changes list: https://docs.flutter.dev/release/breaking-changes
