# Medusa pixel presentation

Current source: `assets/olympus_arena/sprites/medusa-v1.png`, generated with built-in image generation using the hoplite south sheet as style reference. Source pixels remain intact on saturated magenta; the existing runtime chroma shader handles transparency. See the adjacent provenance JSON for source path and SHA256.

## Identity and animation contract

Adult Greek gorgon, olive-green snake hair, bronze diadem and bracers, ivory chiton with emerald Greek-key trim, sandals and human legs. Her ranged attack is a gaze with a short gathering gesture; there is no bow or melee weapon. Four actual cardinal views are authored, without mirroring.

The source rows are south, north, east and west. Columns are ready, gather and release. Each attack plays ready/gather/release/gather for 0.48 seconds, then PixelActor recovers to its directional rest. The snake silhouette changes with the gesture. This is three unique action phases per facing, not a fully in-betweened sequence.

- Rest resources: `themes/medusa_{south,north,east,west}_rest.tres`.
- Attack resources: `themes/medusa_{south,north,east,west}_attack.tres`.
- PixelActor pixel_size: 0.0027. Resource draw_scale: 1.9.
- Source row boundaries: 0, 380, 725, 1065, 1448. Individual foot anchors keep contact stable.
- West row uses unequal column boundaries 0, 362, 700, 1086 to preserve the reaching hand.
- Parent board chooses facing from authoritative movement/attack direction and never moves game coordinates for animation.

## Native review

`tools/review_pixel_medusa.gd -- --capture-dir=ABSOLUTE_DIRECTORY` stages four views, plays two attacks each and captures 90 frames. Eight resource validations and four recovery checks passed. Capture at `outputs/Medusa-Study.mp4` is a staged review, not gameplay. Inspected release at frame 24: four clear facings, hands and sandals retained, no magenta boxes, readable snake silhouette.

## Remaining animation work

Walking was added in later sources below; authored hit reaction and death animation are still missing. Add these from the same identity rather than recoloring unrelated source art. Snake count and fabric folds vary slightly between generated phases. Add in-betweens and refine posture transitions after first roster integration. Gameplay gaze effects are separate from the sprite and must be driven by authoritative hit events.

## Provisional walking addition

`medusa-walk-v1.png` adds four directional locomotion resources, `themes/medusa_{direction}_walk.tres`. These use the same pixel_size 0.0027 with draw_scale 2.18 to match the differently sized source poses. North/south select two opposite-foot contacts from the generation; its requested passing poses repeated, so they were not counted as additional phases. East/west use four varied stride/flex poses. The result is readable but still has abrupt contacts and needs proper in-betweens for finished smoothness.

The native study now accepts `--walk`, starts all four locomotion clips, captures 90 frames and checks stopping returns each actor to its directional rest. `outputs/Medusa-Walk-Study.mp4` passed; frames 0 and 6 inspected for opposite feet and intact silhouettes. Board integration remains coordinator-owned. No further source iterations were made during this roster pass.

## North walk expansion — 2026-09-08

`medusa-north-walk-six.png` replaces north's two-contact flip with six selected independently drawn gait stages. The single built-in generation requested eight cells; cells 4 and 7 (zero based) were similar contact drawings and are deliberately excluded. Active order is 0, 1, 2, 3, 5, 6, with alternating long-leg contacts and raised heel/sole stages, a 0.64 second loop and resource scale 1.24. The complete original sheet remains untouched: no pixel painting, mask extraction or mirrored poses. The runtime shader removes saturated magenta backing.

Native review captured 90 frames at 30 fps with 12 frames of rest, 60 frames of walk and 18 frames returning to rest. All six stages were inspected individually, along with the loop and rest transitions. Final evidence: `outputs/Medusa-North-Six-Final/`, with `outputs/Medusa-North-Six-Walk.mp4` as a staged motion study. The previous exaggerated rest-to-walk size change was reduced by matching the new resource scale to the existing rest. This is source/native admission, not a claim about any exported release.

`tests/test_medusa_north_walk.gd` passes 90 native checks covering source regions, timing, actual board selection of all six drawings, authoritative movement, pause and stopped recovery. `tools/review_medusa_north_walk.gd -- --capture=ABSOLUTE_DIRECTORY` reproduces the capture. Sprite hashes only prove distinct pixels; pose usefulness was reviewed separately in the rendered sequence.

Remaining limits: arms and snake tips move subtly; fabric folds and individual snake positions still vary between drawings. This is a richer working cycle, not a final motion pass. The gaze attacks still need more authored inbetweens.

Original, reference, exact prompt and SHA256 manifest are also saved locally under the shared library's `assets/candidates_needing_review/olympus-medusa-north-walk-2026-09-08`. The shared copy is not publicly published.

## South walk expansion — 2026-09-08

`medusa-south-walk-six.png` now supplies six distinct front-facing stages: right-foot contact, bent-knee passing, left heel reach, left-foot contact, opposite bent-knee passing, right heel reach. The first generated sheet repeated straight-leg contacts in its requested passing cells. A second built-in edit corrected those two cells into actual folded-calf poses. Resource order is 1, 2, 7, 4, 6, 3 (zero-based sheet cells), a 0.64-second loop at scale 1.28. Unneeded contact variants 0 and 5 are excluded. Original generated pixels remain intact; source cells are selected through Resource regions and the runtime magenta shader.

Native review `outputs/Medusa-South-Six-Review/` contains 90 frames at 30 fps: standing, walking through three loops, then standing again. All six displayed stages and rest/loop transitions were inspected; foot alternation and folded-knee silhouettes are visible, and standing/walking head height is matched. `outputs/Medusa-South-Six-Walk.mp4` is a staged native motion study, not full-match footage. Run `tools/review_medusa_south_walk.gd -- --capture=ABSOLUTE_DIRECTORY` to reproduce it.

`tests/test_medusa_south_walk.gd` passes 90 native checks, including actual board playback of every source cell, authoritative southward positions, pause and stopped recovery; its headless subset passes 15. Remaining polish includes more down/up inbetweens, softer knee recovery, stronger counter-swing and less fabric-detail variation. This is a six-drawing cycle, not an eight-drawing claim.

Both original generation attempts, exact prompts, the identity reference and SHA256 hashes are archived locally in the shared library under `assets/candidates_needing_review/olympus-medusa-south-walk-2026-09-08`. The rejected first sheet is not a runtime asset, and no shared candidate was publicly pushed.
