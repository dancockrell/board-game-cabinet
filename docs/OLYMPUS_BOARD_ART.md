# Olympus 2D board-art contract

Updated 2026-09-08. This supersedes the former miniature/diorama contract. The user explicitly requested removal of 3D artwork: **2D only**.

The visual target is rich, crisp pixel art at a stable elevated tactical perspective. Characters must have consistent anatomy, equipment hands, palette, outline weight, and pixel density across facing and action frames. Buildings and scenery belong to the same illustrated world. No sculpted figures, GLB assets, procedural miniature fallback, modeled masonry, or PBR scenery may be introduced.

Orthographic sprite placement may use engine spatial coordinates to preserve authoritative picking and ordering. This implementation detail does not change the 2D-only artwork rule. Effects should read as drawn particles, sprite animation, or flat image animation rather than solid primitive objects.

## Sprite and animation requirements

- Use named Resources with explicit frame regions, timings, stable foot pivots, and facing/action identity.
- Prefer authored silhouettes and poses; do not fake walking by rotating or bobbing a stationary model.
- Keep all source sheets unchanged. Use true transparency or controlled chroma backing; do not generate on a light background and destructively mask pale character details.
- Preserve weapon and shield ownership, head count, garment shape, and consistent character scale.
- Animation follows authoritative events and pauses with gameplay. Repeated snapshots must not repeat attacks or deaths.
- Build varied poses and smooth recovery transitions as practical; frame count alone is not quality.

## Admission

Import must be clean. Validate snapshot agreement, picking, legal placement, pause, rematch and event reuse. Inspect normal-size opening and crowded match captures, then native sequential motion. Staged closeups are diagnostic, not match evidence. Preserve generation source, exact hashes, crops, timing and limitations with each admitted asset.

Use the built-in image generator authorized by the user. No paid external model or image APIs. Do not restore an archived 3D asset to solve a missing sprite.

## Retired work

Old 3D builders, model materials, model review tools, and chess/war-table presentation were copied and SHA256-verified before removal. Their archive is outside this project at `C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-legacy-2d-only-2026-09-08`. Its `manifest.json` records original project paths and hashes. Retained history is not active art authority.
