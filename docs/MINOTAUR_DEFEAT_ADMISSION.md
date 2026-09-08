# Minotaur north defeat admission

2026-09-08. `themes/minotaur_north_defeat.tres` admits eight chronological rear collapse poses from the final two rows of `art_batches/minotaur_batch_01/north.png`. No new generation. The complete PNG is copied unchanged into runtime sprites, with exact source/hash/prompt provenance beside it. Other rows remain unadmitted.

The 0.78-second nonlooping sequence progresses from stance through stagger, lowering, knees, forward fall, landing and settling, then holds the fallen body. Horns, blue/gold skirt, tail and axe remain present. The axe stays screen-left; one hand opens outward during the fall rather than the weapon disappearing.

Measured foreground bounds plus two-pixel gutters keep neighboring rows out. Ground pivots are independent of changing silhouette bounds. Constant scale 3.3 at actor pixel size 0.003 matches the canonical north standing source (293-pixel visible height at scale 1.9). Native side-by-side captures show compatible standing height before the body lowers.

**South is not admitted.** Its second and third defeat poses lose the visible axe; the fourth restores it. No runtime south defeat asset or Resource was created and no repair generation was attempted in this slice. Use existing fallback behavior for that direction until coherent art is available.

## Verification and boundary

- Headless import completed.
- Native `tests/test_minotaur_defeat.gd`: **39 checks, zero failures**, covering Resource validation, all eight exact regions, 0.78-second duration, final hold and unchanged actor root position.
- `tools/review_minotaur_defeat.gd` captured 90 native frames against the battlefield beside canonical north rest. Initial stance, kneeling, falling and settled body were inspected; no clipped axe/horns or neighboring fragments appeared in those captures.
- Video: workspace `outputs/Minotaur-North-Defeat.mp4` at 60 fps.

This is Resource-level admission. Coordinator owns departure mapping, full-match validation and packaging. The final three settling poses are restrained; eight source poses should not be described as eight radically different actions or final animation polish.
