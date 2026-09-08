# Medusa drawn defeat sequences

The north and south defeat rows from Medusa batch 01 now have standalone runtime SpriteClip Resources. Each contains eight chronological drawings, lasts 0.78 seconds, does not loop, and holds its fallen final pose. Board event integration remains coordinator-owned.

## Runtime files

- `themes/medusa_south_defeat.tres`: uniform draw scale 3.0.
- `themes/medusa_north_defeat.tres`: uniform draw scale 3.08.
- `assets/olympus_arena/sprites/medusa-{south,north}-defeat-batch.png`: entire original batch sheets, copied byte-for-byte.
- Matching provenance JSON includes exact generation prompt, original source path and verified SHA256.
- Native actor pixel size: 0.003, consistent with the game's character presentation.

Only row four is selected. The remaining drawings in each untouched atlas are not new runtime clips. Regions are irregular measured bounds, not a blind eight-column grid. South's first region extends upward to y668 to preserve the top snake silhouette; later regions begin at y674. Pivots follow the foot/knee/waist support point through collapse rather than recentering the long fallen body. No pixel editing, masking, resampling or per-frame scale adjustment was used.

## Validation and visual limits

`tests/test_medusa_defeat.gd`: 42 headless checks and 78 native checks passed. These cover valid resources, eight distinct source-data regions, chronological timing, the 0.78-second total, final-pose hold and unchanged actor root coordinates. Different source hashes support separate drawings, not an independent proof of animation quality.

`tools/review_medusa_defeat.gd` captures 90 native frames at 60 fps, with canonical standing south and north figures beside the two collapse sequences. Reviewed initial hit, hands/knees contact and settled body screenshots; no neighbouring-body bleed or clipped extremities was observed. The snake/head silhouette is broader and the build stockier than the canonical standing sprite. Uniform scaling matches standing height, but this identity/proportion difference remains visible at enlarged review scale.

Native study: `outputs/Medusa-Defeat-Native.mp4` in the workspace above the repo. Screenshot order is south standing, south defeat, north defeat, north standing. It is a controlled actor study, not a claim that authoritative death events are integrated.

## Integration contract

Choose the Resource from the last facing, set playback once on departure, advance visual elapsed time while holding the removed unit's last world position, and retain the last body pose for the remainder of the departure effect. These Resources never decide whether a unit is dead or alter damage. East/west rows remain unadmitted candidates; do not mirror an admitted direction to claim independent lateral coverage.

