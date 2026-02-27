# Release v0.5.0 Creation Instructions

## Current Situation

Version 0.5.0 has been prepared in the repository:
- ✅ `package.json` version: 0.5.0
- ✅ `.claude-plugin/plugin.json` version: 0.5.0  
- ✅ `.release-please-manifest.json`: 0.5.0
- ✅ `CHANGELOG.md`: Contains 0.5.0 entry with features
- ❌ **GitHub Release v0.5.0**: Not yet created

The version files were updated via PR #8 (manual PR) which didn't trigger automatic release creation by release-please.

## Option 1: Use Manual Release Workflow (Recommended)

A new workflow has been added: `.github/workflows/manual-release.yml`

### Steps:
1. Merge this PR to main
2. Go to Actions tab: https://github.com/kingkong0905/my-claude-code/actions/workflows/manual-release.yml
3. Click "Run workflow"
4. Enter version: `0.5.0`
5. Target: `main` (or commit SHA `69167bc1311329a0a75312b04b22a070465b1092`)
6. Click "Run workflow"

This will:
- Create git tag `v0.5.0`
- Create GitHub release with changelog from CHANGELOG.md

## Option 2: Use GitHub CLI

If you have gh CLI set up:

```bash
# Create tag
git tag -a v0.5.0 69167bc1311329a0a75312b04b22a070465b1092 -m "Release version 0.5.0"
git push origin v0.5.0

# Create release with changelog
gh release create v0.5.0 \
  --title "v0.5.0" \
  --notes "## [0.5.0](https://github.com/kingkong0905/my-claude-code/compare/v0.4.0...v0.5.0) (2026-02-27)


### Features

* **query-status:** add mcporter dependency and update query status formatting ([edbe493](https://github.com/kingkong0905/my-claude-code/commit/edbe49379880761e749e5dfff96f5670375671a2))
* **docs:** enhance README description and add engineering proposal command ([1e13c3c](https://github.com/kingkong0905/my-claude-code/commit/1e13c3cd166b23acce568d90c7b906352a494c7d))
* **proposal-research:** update SKILL.md documentation ([f49d5b1](https://github.com/kingkong0905/my-claude-code/commit/f49d5b1f4e9ef2edeeee0c29b501c5d1661c9060))"
```

## Option 3: Manual Release via GitHub UI

1. Go to: https://github.com/kingkong0905/my-claude-code/releases/new
2. Choose tag: Create new tag `v0.5.0` targeting `main` branch
3. Set release title: `v0.5.0`
4. Copy release notes from CHANGELOG.md for version 0.5.0:

```markdown
## [0.5.0](https://github.com/kingkong0905/my-claude-code/compare/v0.4.0...v0.5.0) (2026-02-27)


### Features

* **query-status:** add mcporter dependency and update query status formatting ([edbe493](https://github.com/kingkong0905/my-claude-code/commit/edbe49379880761e749e5dfff96f5670375671a2))
* **docs:** enhance README description and add engineering proposal command ([1e13c3c](https://github.com/kingkong0905/my-claude-code/commit/1e13c3cd166b23acce568d90c7b906352a494c7d))
* **proposal-research:** update SKILL.md documentation ([f49d5b1](https://github.com/kingkong0905/my-claude-code/commit/f49d5b1f4e9ef2edeeee0c29b501c5d1661c9060))
```

5. Click "Publish release"

## After Release Creation

Once the v0.5.0 release is created:
- The existing PR #7 for v0.6.0 can remain as-is
- Future releases will follow the normal release-please workflow

## Changes Made in This PR

1. Added `.github/workflows/manual-release.yml` - A workflow to manually create releases via workflow_dispatch
2. Updated `.github/workflows/release-please.yml` - Added workflow_dispatch trigger for manual runs
3. Created this document - Instructions for creating the v0.5.0 release
