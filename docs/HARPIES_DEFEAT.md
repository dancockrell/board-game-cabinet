# Harpy north/south defeat resources

Eight defeat drawings per direction are selected from the final two rows of the Harpies full-sheet batch. The complete original south_a and north_a PNGs are copied unchanged into runtime assets; provenance records source paths and SHA-256 hashes. There was no new generation, repainting, raster masking, mirrored facing or isolated pose work.

`themes/harpies_south_defeat.tres` and `themes/harpies_north_defeat.tres` are nonlooping, hold their final folded-body drawing, and run for exactly 0.78 seconds. Pose durations are 0.07, 0.07, 0.08, 0.09, 0.10, 0.10, 0.11 and 0.16 seconds. Each rectangle uses its original full-sheet coordinates; contact pivots sit two source pixels above the crop bottom. Constant draw scale 1.9 was chosen after native comparison; the first 2.3-scale study was visibly oversized and is not acceptance evidence.

## Landing integration contract

The existing Harpy PixelActor has a local vertical lift of 1.0 beneath Figure (normally scaled 0.86). Defeat Resources describe ground-contact poses and do not encode that world lift into pixel pivots. The coordinator must preserve the original starting transform, then lower the transformed local flight offset to zero:

- SOUTH: descent finishes at **0.22 seconds**, pose index 3, the first one-knee/talon contact.
- NORTH: descent finishes at **0.31 seconds**, pose index 4, the clear ground-bracing pose.

The native study uses smoothstep between the original lift and ground. Do not leave the fallen body at the flying height. The 0.78-second departure lifetime remains unchanged. This resource commit does not alter board/departure behavior; integration is owned by the coordinator.

## Validation

Godot 4.3 headless import completed. `tests/test_harpies_defeat.gd` passed **92 checks, zero failures** under native Compatibility rendering: resource validity, eight independently hashed source regions, chronological playback, all actor frames, stable sampling, ground pivots, duration and final hold. Hash distinction is a source uniqueness check, not an animation quality verdict.

`tools/review_harpies_defeat.gd` captures 96 native frames at 60 fps, comparing each defeat with its current flying rest at pixel size 0.003. Final evidence: `outputs/Harpies-Defeat-Ground-Final/` and adjacent MP4, outside the repository. Start/ground-contact/final-collapse frames were visually inspected. The wing/body identity holds and ground lowering prevents an airborne corpse; the authored sequence is brief and still has pose-to-pose changes. This is a controlled study, not a full-match claim.
