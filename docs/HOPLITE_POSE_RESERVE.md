# Hoplite pose reserve

2026-09-07. Built-in generator, three calls: twelve combat/movement key poses, six transition/personality key poses, one rejected alpha/layout correction. 18 distinct pose candidates, zero newly admitted animation clips. Do not concatenate unlike actions into a purported smooth sequence.

Shared canonical source location:
C:/Users/Admin/Documents/Codex/2026-09-04/referenced-chatgpt-conversation-this-is-an/work/shared-catalog/procedural/sprites/candidates/olympus/hoplite-poses-01

That folder preserves original PNGs, source IDs, SHA256 hashes and candidate findings. This is the shared 2D candidate area used by the other game tasks. The separate legacy 3D archive remains where recorded in PIXEL_IMPLEMENTATION.md.

Combat reserve: upright/low guard, two advance poses, long thrust, overhand windup/strike, shield bash, frontal recoil, backstep, kneeling recovery and victory. Companion reserve: scan, equipment handling, pivot, exhausted rest, kneel/rise and rally.

## Actual checks

Combat source has real RGBA but some weapons extend into adjacent nominal cells. Companion source is RGB magenta, not alpha. Alpha correction produced RGB with a painted checkerboard: rejected and never used as a mask. No light-background keying.

Extended existing tools/review_pixel_hoplite.gd with --pose-sheet to inspect the six companion poses. Its canvas shader removes saturated magenta only; raw images remain unchanged. Reviewed native 1440x960 output on dark green: ivory and skin retained, full weapon extents visible with custom row boundary at 480. This is preview masking, not a finalized exported alpha atlas. Hard-key fringes and pivot/scale need further native-size QA. Source-specific review regions are not runtime clip definitions.

Known content issues: equipment-handling pose is not a convincing strap adjustment, kneel/rise is mainly kneeling, generated perspective and owl details drift, and combat sheet needs individual region curation. Those are candidates for correction, not completed animations. Direction invariants and the earlier selected character need comparison before admission.

Run:
`godot --path . --script tools/review_pixel_hoplite.gd -- --source=ABSOLUTE/docs/art-references/hoplite-personality-candidate.png --capture=ABSOLUTE/output.png --pose-sheet`

Next: preserve strong combat contacts and reactions, generate targeted intermediate poses for one complete action, validate transitions at game scale. Do not bulk-generate a roster before one sequence works.
