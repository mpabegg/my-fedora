# COSMIC Personal Image Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace template defaults with a personal COSMIC Atomic single-recipe image that is validated after every small change.

**Architecture:** Keep one `recipes/recipe.yml`, apply changes in tiny commits, and run `bluebuild validate` after each edit so behavior is verified incrementally. Start with metadata/base changes, then service policy, then package blocks, then flatpak policy, then optional COSMIC defaults.

**Tech Stack:** BlueBuild recipe v1 schema, Fedora COSMIC Atomic, BlueBuild CLI (`bluebuild validate`, `bluebuild generate`, optional `bluebuild build`).

---

### Task 1: Baseline Validation Snapshot

**Files:**
- Modify: `recipes/recipe.yml`

**Step 1: Run baseline validation before edits**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS on template recipe.

**Step 2: Save baseline output for comparison**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild generate recipes/recipe.yml >/tmp/my-fedora.before.containerfile`
Expected: Containerfile generated without errors.

**Step 3: Commit checkpoint**

Run:
```bash
git add -A
git commit -m "chore: capture baseline validation checkpoint"
```
Expected: Commit created.

### Task 2: Switch Base to COSMIC Atomic

**Files:**
- Modify: `recipes/recipe.yml`

**Step 1: Change base metadata only**
- Set `base-image` to `quay.io/fedora-ostree-desktops/cosmic-atomic`.
- Set `image-version` to `latest`.
- Keep all existing modules unchanged for this step.

**Step 2: Validate**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 3: Generate sanity check**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild generate recipes/recipe.yml >/tmp/my-fedora.step2.containerfile`
Expected: Containerfile generated.

**Step 4: Commit**

Run:
```bash
git add recipes/recipe.yml
git commit -m "feat: rebase recipe on fedora cosmic atomic latest"
```

### Task 3: Remove Template Signing and System Flatpaks

**Files:**
- Modify: `recipes/recipe.yml`

**Step 1: Remove `type: signing` module**

**Step 2: Replace template system flatpak installs with user-scope Flathub repo config**

**Step 3: Validate**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 4: Commit**

Run:
```bash
git add recipes/recipe.yml
git commit -m "refactor: drop signing and template flatpak defaults"
```

### Task 4: Add Systemd Policy Block

**Files:**
- Modify: `recipes/recipe.yml`
- Create (if needed): `files/system/usr/lib/systemd/system/bootc-fetch-apply-updates.service`
- Create (if needed): `files/system/usr/lib/systemd/system/bootc-fetch-apply-updates.timer`

**Step 1: Add `type: systemd` block**
- Mask `rpm-ostreed-automatic.timer`.
- Enable `bootc-fetch-apply-updates.timer` only if the unit exists.

**Step 2: Validate**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 3: Commit**

Run:
```bash
git add recipes/recipe.yml files/system
git commit -m "feat: add systemd update policy for atomic image"
```

### Task 5: Add Multimedia Replacement Block

**Files:**
- Modify: `recipes/recipe.yml`

**Step 1: Add a focused `dnf` multimedia replacement block**
- Import only stable replacements needed for codecs/VAAPI.
- Avoid adding broad extra repos in this step.

**Step 2: Validate**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 3: Optional small build test (user-controlled)**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild build recipes/recipe.yml`
Expected: Build starts successfully; package resolution succeeds for multimedia block.

**Step 4: Commit**

Run:
```bash
git add recipes/recipe.yml
git commit -m "feat: add multimedia replacement stack"
```

### Task 6: Add Curated Core Package Block

**Files:**
- Modify: `recipes/recipe.yml`

**Step 1: Add DE-agnostic packages from base-images/bluefin subset**
- Keep list intentionally small in first pass.

**Step 2: Add removal list for unwanted defaults (e.g., Firefox RPM)**

**Step 3: Validate**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 4: Optional build test**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild build recipes/recipe.yml`
Expected: Build starts and package transaction resolves.

**Step 5: Commit**

Run:
```bash
git add recipes/recipe.yml
git commit -m "feat: add curated core package baseline"
```

### Task 7: Add Minimal COSMIC Defaults Overlay

**Files:**
- Modify: `recipes/recipe.yml`
- Create: `files/cosmic-defaults/...` (minimal curated subset)

**Step 1: Add second `files` module for `cosmic-defaults` overlay**

**Step 2: Introduce only a tiny COSMIC defaults subset**
- Keep this to low-risk defaults first.

**Step 3: Validate**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 4: Generate sanity check**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild generate recipes/recipe.yml >/tmp/my-fedora.step7.containerfile`
Expected: Containerfile generated.

**Step 5: Commit**

Run:
```bash
git add recipes/recipe.yml files/cosmic-defaults
git commit -m "feat: add minimal cosmic defaults overlay"
```

### Task 8: Final Verification Gate

**Files:**
- Modify: `README.md` (optional notes on base and rebase target)

**Step 1: Full validation pass**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild validate recipes/recipe.yml`
Expected: PASS.

**Step 2: Generate final containerfile**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild generate recipes/recipe.yml >/tmp/my-fedora.final.containerfile`
Expected: Containerfile generated.

**Step 3: Optional full build**

Run: `cd /var/home/mat/dev/my-fedora && bluebuild build recipes/recipe.yml`
Expected: Successful local build.

**Step 4: Commit final docs/README updates**

Run:
```bash
git add README.md docs/plans
git commit -m "docs: capture cosmic image design and implementation plan"
```
