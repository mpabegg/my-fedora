# COSMIC/KDE Recipe Dedup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Deduplicate COSMIC and KDE BlueBuild recipes via a shared module include, remove unused COSMIC defaults, and rename image outputs to `fedora-cosmic` and `fedora-kde`.

**Architecture:** Keep two top-level recipe entrypoints for metadata and base image selection, and centralize the duplicated `modules` list into `recipes/modules/common.yml` loaded by `from-file`. Remove the COSMIC-only defaults overlay and update docs to new image names.

**Tech Stack:** BlueBuild recipe YAML, GitHub Actions workflow, Markdown docs.

---

### Task 1: Create Shared Modules Include

**Files:**
- Create: `recipes/modules/common.yml`
- Modify: `recipes/recipe.yml`
- Modify: `recipes/my-fedora-kde.yml`

**Step 1: Write a failing structure check**

Run: `rg -n "type: brew|type: dnf|type: default-flatpaks|type: systemd" recipes/recipe.yml recipes/my-fedora-kde.yml`
Expected: both files still contain duplicate module blocks (failure condition before refactor).

**Step 2: Implement shared modules include**
- Move the duplicated module list into `recipes/modules/common.yml`.
- Replace each top-level recipe `modules` section with a single `from-file` include to the shared file.

**Step 3: Verify duplication removed**

Run: `rg -n "type: brew|type: dnf|type: default-flatpaks|type: systemd" recipes/recipe.yml recipes/my-fedora-kde.yml`
Expected: top-level recipes no longer contain full duplicated module blocks.

### Task 2: Rename Image Names and Remove COSMIC Defaults

**Files:**
- Modify: `recipes/recipe.yml`
- Modify: `recipes/my-fedora-kde.yml`
- Delete: `files/cosmic-defaults/usr/share/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark`
- Delete: `files/cosmic-defaults/usr/share/cosmic/com.system76.CosmicTk/v1/interface_density`

**Step 1: Write failing name/reference check**

Run: `rg -n "name:\s*my-fedora|name:\s*my-fedora-kde|cosmic-defaults" recipes files`
Expected: existing names and cosmic-defaults references present.

**Step 2: Implement rename and removal**
- Set recipe names to `fedora-cosmic` and `fedora-kde`.
- Remove COSMIC defaults module usage and delete unused files.

**Step 3: Verify rename/removal**

Run: `rg -n "name:\s*my-fedora|name:\s*my-fedora-kde|cosmic-defaults" recipes files`
Expected: no matches.

### Task 3: Update Docs and Validate Recipes

**Files:**
- Modify: `README.md`

**Step 1: Write failing doc reference check**

Run: `rg -n "ghcr.io/mpabegg/my-fedora(-kde)?" README.md`
Expected: old image names found.

**Step 2: Update docs**
- Replace README references with:
  - `ghcr.io/mpabegg/fedora-cosmic`
  - `ghcr.io/mpabegg/fedora-kde`

**Step 3: Verify docs and recipe validity**

Run:
- `rg -n "ghcr.io/mpabegg/my-fedora(-kde)?" README.md`
- `bluebuild validate recipes/recipe.yml`
- `bluebuild validate recipes/my-fedora-kde.yml`

Expected:
- No old names in README.
- Both recipe validations succeed.
