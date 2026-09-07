# Medusa pixel presentation

Current source: `assets/olympus_arena/sprites/medusa-v1.png`, generated with built-in image generation using the hoplite south sheet as style reference. Source pixels remain intact on saturated magenta; the existing runtime chroma shader handles transparency. See the adjacent provenance JSON for source path and SHA256.

## Identity and animation contract

Adult Greek gorgon, olive-green snake hair, bronze diadem and bracers, ivory chiton with emerald Greek-key trim, sandals and human legs. Her ranged attack is a gaze with a short gathering gesture; there is no bow or melee weapon. Four actual cardinal views are authored, without mirroring.

The source rows are south, north, east and west. Columns are ready, gather and release. Each attack plays ready/gather/release/gather for 0.48 seconds, then PixelActor recovers to its directional rest. The snake silhouette changes with the gesture. This is three unique action phases per facing, not a fully in-betweened sequence.

- Rest resources: `themes/medusa_{south,north,east,west}_rest.tres`.
- Attack resources: `themes/medusa_{south,north,east,west}_attack.tres`.
- PixelActor pixel_size: 0.0027. Resource draw_scale: 1.55.
- Source row boundaries: 0, 380, 725, 1065, 1448. Individual foot anchors keep contact stable.
- West row uses unequal column boundaries 0, 362, 700, 1086 to preserve the reaching hand.
- Parent board chooses facing from authoritative movement/attack direction and never moves game coordinates for animation.

## Native review

`tools/review_pixel_medusa.gd -- --capture-dir=ABSOLUTE_DIRECTORY` stages four views, plays two attacks each and captures 90 frames. Eight resource validations and four recovery checks passed. Capture at `outputs/Medusa-Study.mp4` is a staged review, not gameplay. Inspected release at frame 24: four clear facings, hands and sandals retained, no magenta boxes, readable snake silhouette.

## Remaining animation work

Walking, hit reaction and death animation are not included in v1. Add these from the same identity rather than recoloring unrelated source art. Snake count and fabric folds vary slightly between generated phases. Add in-betweens and refine posture transitions after first roster integration. Gameplay gaze effects are separate from the sprite and must be driven by authoritative hit events.
