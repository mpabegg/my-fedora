# KDE Personal Image Design (2026-02-22)

## Goal
Add a KDE-based Fedora Atomic image to this repository while preserving the existing COSMIC image build and behavior.

## Scope
- Keep the existing COSMIC image recipe and output unchanged.
- Add a new KDE image recipe using Fedora Kinoite as base.
- Build both images from the same GitHub Actions workflow.
- Keep package/module parity where desktop-environment agnostic.

## Decisions
### Image strategy
- Maintain two images in one repository:
  - COSMIC: `my-fedora`
  - KDE: `my-fedora-kde`
- Keep separate recipe files to minimize risk and simplify troubleshooting.

### KDE base
- Use `quay.io/fedora-ostree-desktops/kinoite` as the KDE base image.

### Recipe structure
- Add `recipes/my-fedora-kde.yml` as a copy of current recipe baseline with these changes:
  - `name: my-fedora-kde`
  - KDE-focused description
  - `base-image: quay.io/fedora-ostree-desktops/kinoite`
  - Remove COSMIC-only defaults overlay (`files` module using `cosmic-defaults`).
- Keep all other non-DE-specific module blocks aligned with COSMIC recipe.

### CI workflow
- Update `.github/workflows/build.yml` matrix to include:
  - `recipe.yml`
  - `my-fedora-kde.yml`

### Documentation
- Update `README.md` installation section with explicit rebase commands for:
  - COSMIC image `ghcr.io/mpabegg/my-fedora`
  - KDE image `ghcr.io/mpabegg/my-fedora-kde`

## Validation
- Validate both recipes:
  - `bluebuild validate recipes/recipe.yml`
  - `bluebuild validate recipes/my-fedora-kde.yml`

## Non-Goals
- No package-set redesign in this task.
- No shared recipe templating/refactor.
- No branding/theming work for KDE.
