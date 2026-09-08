# Atalanta south attack expansion — 2026-09-08

The active south attack remains the existing two-frame clip. Four built-in image-generation calls produced eight-cell studies, but none passed sequence-level admission. No extra frame is counted as a runtime improvement.

## What was attempted

1. A complete nock, raise, partial draw, full draw, release, follow-through, lower and reload sheet. Identity and costume largely held; the generator changed the south aim into an east-facing horizontal shot. Draw and recovery cells were near-duplicates.
2. A targeted correction to the lower-right south perspective. The direction improved, but the bows became tiny, unreadable objects. The arrow incorrectly remained after release.
3. A bow-only correction. Arrow removal worked, but the bow became oversized and acquired large grip knobs; the arrow/grip geometry also drifted.
4. A simpler, smaller bow correction. The drawn and released bow still changed scale substantially, and release/follow-through remained almost identical. This is a study, not eight accepted action poses.

All four unchanged generated PNGs, the unchanged reference sheet, exact prompts, and SHA-256 hashes are preserved locally in `shared-game-environment-library/assets/candidates_needing_review/olympus-atalanta-south-attack-2026-09-08/provenance.json`. These private candidate files have not been pushed to the public shared-art repository. No raster cleanup, repainting, masking, external API, or paid generation service was used.

## Next bounded production step

Do not ask for another complete eight-frame sheet as the next operation. Author one correct release drawing directly from the accepted south full-draw cell, preserving the bow's tip positions, grip center and character silhouette. Then author one lowering intermediate from that accepted release. Only after this pair is stable should preparation poses be added. A single visibly correct intermediate is useful; repeating a pose or admitting changing equipment is not.

Before replacing `themes/atalanta_south_attack.tres`, inspect all frames in order in Godot, normalize foot pivots without warping the artwork, keep total action duration below the one-second attack cooldown, and run the coordinator's `tests/test_olympus_attack_sequences.gd`. The clip must recover to idle or locomotion without touching authoritative unit positions. No native runtime validation is claimed for these rejected studies.
