# Atalanta north/south defeat resources

The existing full-sheet batch supplies eight chronological defeat drawings for each north/south facing: stagger, knee buckle, kneeling, hand brace, sideways fall, landing and two settling poses. No new generation was needed. Complete original PNGs are copied unchanged into runtime assets, with SHA-256 and source provenance beside them.

`themes/atalanta_south_defeat.tres` and `themes/atalanta_north_defeat.tres` are nonlooping and last 0.78 seconds. Their durations are 0.07, 0.07, 0.08, 0.09, 0.10, 0.10, 0.11 and 0.16 seconds. They hold the final drawing after completion. Board/departure integration remains coordinator-owned; this commit makes no changes to game state or the departure lifetime.

## Registration and native review

Whole-sheet connected-body measurement recovered full hair and bow bounds that the original provisional fixed-column regions clipped. Regions reference unchanged source pixels; no raster mask or repaint was used. Ground pivots follow the lower body/contact edge. In the last south-facing poses the bow lies below the body, so its lowest pixel is deliberately not used as the body's floor anchor.

Constant scale **2.5** was selected against canonical north/south rest at pixel size **0.003** in the native renderer. An initial 3.1 study was oversized and is not final evidence. Ground pivots need no flight-style vertical translation. Body proportions in the batch are somewhat stockier and pixel detail coarser than the canonical rest; the scale correction keeps the collapse from enlarging the character. The sequence is still a brief eight-pose animation, with near-similar final settling drawings.

`tools/review_atalanta_defeat.gd` captured 96 frames at 60 fps comparing both collapses beside their canonical rest. Final evidence is `outputs/Atalanta-Defeat-Grounded-Final/` and its adjacent MP4, outside the repository. Start, fall and final body contact were reviewed through the native studies. The final body contact correction was inspected in frame 056. This is controlled presentation evidence, not a full-match claim.

Godot 4.3 headless import completed. Native `tests/test_atalanta_defeat.gd` passed **92 checks, zero failures**, covering both resources, all eight source regions, chronological sampling, actor frames, stable repeated sampling, contact pivots, duration and final hold. Distinct crop hashes prove independent source data, not that every pose is equally useful.
