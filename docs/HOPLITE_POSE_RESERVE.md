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

## Thrust sequence candidate

2026-09-07 built-in generation exec-7934d9ba-8084-453c-a364-aac22fa903f5.png, preserved at docs/art-references/hoplite-thrust-candidate.png. Four distinct drawn-back/extend/thrust/retract poses with saturated magenta backing. This improves action contacts over the earlier generic reserve, but it is not admitted: output is 2172x724 instead of the requested four square cells; spear and foot extents cross nominal equal cell boundaries, and body scale differs from the live guard clip. Do not cut it automatically into quarters or count it as a finished attack. Needs source-specific regions/pivots or corrected layout, native playback review, and matching attack directions.
