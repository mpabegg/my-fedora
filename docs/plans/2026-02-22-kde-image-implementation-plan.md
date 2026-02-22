# KDE Image Addition Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a new KDE-based image (`my-fedora-kde`) while preserving the existing COSMIC image and building both in CI.

**Architecture:** Keep the current COSMIC recipe as-is and add a second standalone KDE recipe using Fedora Kinoite base. Update CI matrix to build both recipes and update README with dual-image install instructions. Validate both recipes after edits.

**Tech Stack:** BlueBuild recipes (YAML), GitHub Actions workflow YAML, Markdown documentation.

---

### Task 1: Add KDE recipe file

**Files:**
- Create: `recipes/my-fedora-kde.yml`
- Modify: `recipes/recipe.yml` (no changes expected; reference baseline only)
- Test: `recipes/my-fedora-kde.yml` via `bluebuild validate`

**Step 1: Create KDE recipe from COSMIC baseline**

```yaml
---
# yaml-language-server: $schema=https://schema.blue-build.org/recipe-v1.json
name: my-fedora-kde
description: My personal KDE-based Fedora Atomic image.
base-image: quay.io/fedora-ostree-desktops/kinoite
image-version: 43
```

Then copy the existing shared module blocks from `recipes/recipe.yml`.

**Step 2: Remove COSMIC-only defaults module**

Ensure this block is absent from `recipes/my-fedora-kde.yml`:

```yaml
- type: files
  files:
    - source: cosmic-defaults
      destination: /
```

**Step 3: Validate KDE recipe**

Run: `bluebuild validate recipes/my-fedora-kde.yml`
Expected: validation succeeds without schema/module errors.

**Step 4: Commit recipe addition**

```bash
git add recipes/my-fedora-kde.yml
git commit -m "feat: add KDE image recipe"
```

### Task 2: Build both recipes in GitHub Actions

**Files:**
- Modify: `.github/workflows/build.yml`
- Test: workflow YAML inspection for matrix entries

**Step 1: Add KDE recipe to matrix**

Update matrix list to include both:

```yaml
matrix:
  recipe:
    - recipe.yml
    - my-fedora-kde.yml
```

**Step 2: Verify workflow references matrix recipe path**

Confirm existing `with.recipe` remains:

```yaml
recipe: ${{ matrix.recipe }}
```

**Step 3: Commit workflow update**

```bash
git add .github/workflows/build.yml
git commit -m "ci: build cosmic and kde recipes"
```

### Task 3: Update README for dual-image installation

**Files:**
- Modify: `README.md`
- Test: manual read-through for correct image refs

**Step 1: Add explicit image options in installation docs**

Document both image names and add rebase commands for:
- `ghcr.io/mpabegg/my-fedora:latest` (COSMIC)
- `ghcr.io/mpabegg/my-fedora-kde:latest` (KDE)

**Step 2: Keep signed-image guidance for both images**

Ensure both unsigned and signed rebase examples are provided for the KDE image in the same style as COSMIC.

**Step 3: Commit README changes**

```bash
git add README.md
git commit -m "docs: add KDE image install instructions"
```

### Task 4: Final verification and squash-ready checkpoint

**Files:**
- Verify: `recipes/recipe.yml`
- Verify: `recipes/my-fedora-kde.yml`
- Verify: `.github/workflows/build.yml`
- Verify: `README.md`

**Step 1: Validate both recipes**

Run: `bluebuild validate recipes/recipe.yml`
Expected: succeeds.

Run: `bluebuild validate recipes/my-fedora-kde.yml`
Expected: succeeds.

**Step 2: Inspect diff for scope control**

Run: `git diff -- recipes/my-fedora-kde.yml .github/workflows/build.yml README.md`
Expected: only KDE recipe addition, CI matrix update, and README dual-image docs.

**Step 3: Create integration commit (if not using per-task commits)**

```bash
git add recipes/my-fedora-kde.yml .github/workflows/build.yml README.md
git commit -m "feat: add KDE image build alongside COSMIC"
```
