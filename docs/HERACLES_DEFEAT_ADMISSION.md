# Heracles north and south defeat admission

2026-09-08. Two eight-frame nonlooping Resources admit the strongest north/south defeat rows from `art_batches/heracles_batch_01`. **Sixteen authored poses, no new generation.** The full generated PNGs are copied byte-for-byte to runtime sprites; individual Resources select measured rectangles. Other rows in those source images remain unadmitted. The coordinator owns wiring these clips into unit departures.

`themes/heracles_south_defeat.tres` and `themes/heracles_north_defeat.tres` play recoil, stagger, buckling, kneeling, lower crouch, side fall, ground contact and settled body over 0.78 seconds. They hold the final body rather than loop. The club stays with the correct arm and the lion pelt remains coherent through the selected rows.

Connected foreground bounds were measured on the unchanged sources, then each silhouette received a two-pixel gutter. This avoids the naive equal-grid neighboring fragments seen in the batch preview. Per-frame ground pivots account for changing posture. Constant draw scale 3.2 at actor pixel size 0.003 is compared against canonical standing heights: south source 291 pixels at scale 2.0, north source 420 pixels at scale 1.4. No raster crops, recolors, masks or procedural new artwork were generated.

## Verification

- Headless Godot import completed.
- Native `tests/test_heracles_defeat.gd`: **78 checks, zero failures**, covering both Resources, exact chronological regions, distinct source data, 0.78-second duration, final hold and unchanged authoritative actor position. Distinct data checks are technical checks, not a substitute for pose review.
- `tools/review_heracles_defeat.gd` captured 90 native frames against the battlefield, with canonical standing references on the outside and south/north collapse on the inside. Initial recoil, kneeling, falling and settled-body captures were inspected. Complete source review covers the eight poses in each chosen row. No neighboring silhouettes or clipped club ends appeared in inspected runtime captures.
- Study: workspace `outputs/Heracles-Defeat.mp4` (60 fps).

This is Resource-level visual admission. Full battle/departure integration, facing selection and Windows packaging remain coordinator work. Broad recoil and fall silhouettes are wider than the standing pose and will need crowded-combat review. The short sequence is richer than a fade but is not a claim of final animation polish.
