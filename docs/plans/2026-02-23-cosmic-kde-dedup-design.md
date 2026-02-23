# COSMIC/KDE Recipe Dedup Design (2026-02-23)

## Goal
Remove duplication between COSMIC and KDE image builds while keeping two top-level recipes and renaming outputs to `fedora-cosmic` and `fedora-kde`.

## Scope
- Keep two top-level recipe files:
  - `recipes/recipe.yml` (COSMIC)
  - `recipes/my-fedora-kde.yml` (KDE)
- Extract duplicated module configuration into a shared `from-file` include.
- Remove COSMIC defaults overlay because it matches system defaults.
- Rename image names in recipes and docs.

## Decisions
### Recipe architecture
- Keep two recipe entrypoints for clarity and per-image metadata.
- Introduce one shared modules file, `recipes/modules/common.yml`, and include it from both recipes.

### Desktop-specific customization
- Remove the `cosmic-defaults` files module from COSMIC.
- Keep KDE without any desktop-specific overlay.

### Image naming
- Rename recipe image names:
  - COSMIC: `fedora-cosmic`
  - KDE: `fedora-kde`

### Documentation
- Update README image references and rebase examples to use new image names.

## Validation
- Run:
  - `bluebuild validate recipes/recipe.yml`
  - `bluebuild validate recipes/my-fedora-kde.yml`
- Verify no `cosmic-defaults` references remain.

## Non-Goals
- No package-set redesign.
- No CI recipe matrix restructuring.
- No additional image variants.
