# COSMIC Personal Image Design (2026-02-22)

## Goal
Build a personal Fedora COSMIC Atomic image from `quay.io/fedora-ostree-desktops/cosmic-atomic:latest` with curated batteries-included defaults, while keeping complexity low and each change testable in small steps.

## Constraints
- Personal-use image.
- No secure-boot/signing setup in v1.
- No NVIDIA support in v1.
- Track `latest` Fedora stream.
- Use a single `recipes/recipe.yml` for now.
- Implement in small, testable checkpoints.

## Reference Matrix
### base-images
- Use as primary source for:
  - COSMIC base pattern from upstream Fedora cosmic-atomic.
  - Multimedia replacement strategy.
  - Practical desktop/QOL package baseline.
  - Repo cleanup and update timer patterns.
- Do not port: secure-boot/signing blocks.

### bluefin
- Use as source for:
  - DE-agnostic batteries-included package ideas.
  - Service/repo hygiene patterns.
  - Flatpak remote policy patterns.
- Do not port: GNOME-specific logic and Bluefin branding integration.

### images (Origami)
- Use as source for:
  - Optional COSMIC defaults (small curated subset only).
- Defer:
  - Large external repo footprint.
  - Network-fetched scripts during build.
  - Custom kernel by default.

### bazzite
- Use as source for:
  - Future custom-kernel workflow quality (if enabled later).
  - Strong repo disable/finalization hygiene patterns.
- Do not port in v1:
  - Gaming stack and deck/handheld services.
  - Bazzite-specific branding and patched stack.

## v1 Composition
- Base: `quay.io/fedora-ostree-desktops/cosmic-atomic:latest`
- One recipe file: `recipes/recipe.yml`
- Core module order:
  1. `files` (local overlays/scripts/policy)
  2. `systemd` (timer masks/enables)
  3. `dnf` multimedia replacement block
  4. `dnf` curated packages block
  5. `default-flatpaks` policy
  6. `files` optional COSMIC defaults subset

## Testing Strategy
Every micro-step must be validated locally before continuing:
- Primary check: `bluebuild validate recipes/recipe.yml`
- Periodic generation sanity check: `bluebuild generate recipes/recipe.yml`
- Optional local build checkpoints (when requested): `bluebuild build recipes/recipe.yml`

## Deferred Items
- Optional custom-kernel track (inspired by Bazzite/Origami) after v1 baseline is stable.
- NVIDIA variant.
- Expanded COSMIC theming and larger app set.
