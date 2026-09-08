# Hydra drawn defeat sequences

North and south each use eight chronological drawings from rows seven and eight of the original Hydra batch 01 sheet. The sequences last 0.78 seconds, do not loop, and hold the last collapsed pose. No new generation was performed for this admission.

## Art and registration

Runtime Resources: `themes/hydra_north_defeat.tres` and `themes/hydra_south_defeat.tres`. Complete original PNG sheets were copied byte-for-byte into `assets/olympus_arena/sprites/hydra-{direction}-defeat-batch.png`; corresponding provenance contains verified hashes and exact generation prompts. Unselected rows are not new runtime animations.

Measured irregular horizontal bounds isolate each body. North's first four frames begin at y1340 rather than the nominal y1330 to exclude tails from the preceding action. Its last four begin at y1580 to exclude the preceding fall's tail. South uses y1340 and y1568. Two pixels of horizontal padding preserve outlines. No raster masking, cropping, repainting, or resampling was performed.

At pixel size 0.003, south uses uniform draw scale 1.8 and north 2.05. Their ground pivots follow feet/body support, not the bottommost tail tip. This matches the canonical north idle's tail extending below its foot anchor. No per-frame scaling disguises body changes. Depth bias 0.12 matches the canonical Hydra keyed clips.

## Native evidence and limits

`tests/test_hydra_defeat.gd` passed 42 headless and 78 native checks: valid resources, eight distinct source-data regions, chronological timing, total duration, final-body hold and invariant actor root position.

`tools/review_hydra_defeat.gd` captured 90 frames at 60 fps against canonical north/south idle drawings on the native board. Initial hit, midway neck/body collapse and final body screenshots were inspected. No neighbouring sprite fragment or clipped extremity was observed. Video: `outputs/Hydra-Defeat-Native.mp4` in the workspace above the repo.

South visibly settles all three heads. North's middle head/neck folds forward away from the rear camera and becomes occluded by the back in later frames; three heads are not separately visible in the final rear pose. The side heads remain visible and the central neck follows the rear spine. This is a direction-specific visibility limit, not an added head or dismemberment. Slight silhouette/neck-length changes remain between canonical idle and initial hit.

This controlled study proves actor rendering and timing, not board death-event integration. Coordinator owns that wiring. Keep removed units anchored to their last authoritative position and advance only presentation time. East/west remain unadmitted.

