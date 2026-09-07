# Heracles pixel character package

Authored with the built-in image generator. Adult bearded Greek hero with a tawny lion-pelt hood, red skirt and knotted wooden club. Source images are preserved; pure magenta is removed by the existing runtime shader.

## Integration

Use `themes/heracles_{east,west,north,south}_rest.tres` and corresponding `_attack.tres`. Set PixelActor pixel_size to 0.0027. Resource scales normalize the separate north sheet (1.40) against the other directions (2.0). Rest is one looping pose. Attack is wind-up 0.13s, strike 0.16s, recovery 0.12s. Authoritative attack event IDs should drive `play_attack`; animation does not apply damage or move roots.

Foot anchors are per-frame and source pixels are not cropped or repainted offline. The unused north column on heracles-v1 is rejected: it changes weapon hands. heracles-north-v1 supplies the admitted rear direction. Two unsuccessful intermediate editing outputs remain in the generation directory and are not runtime dependencies.

## Validation

`tests/test_heracles_clips.gd` checks eight resources, distinct wind-up/strike phases, sequence timing, event deduplication and matching-direction recovery. Run with native Godot because the dummy renderer reports Sprite3D mesh warnings even when assertions pass. `tools/review_pixel_heracles.gd -- --capture-dir=ABSOLUTE_DIRECTORY` captures 90 staged native frames, four directions and two attacks/recoveries. This is presentation review, not actual gameplay.

## Remaining work

East/west walking, hit/death reactions, more in-betweens, diagonal facing refinements and team palette variants remain. The north contact still reads as a forward high swing with a diagonal aim, rather than a deep overhead ground strike. Slight body/costume drift remains between sheets. Integration and full-match validation belong to the coordinator.

## North/south locomotion

`heracles_north_walk.tres` and `heracles_south_walk.tres` supply four alternating-foot phases at 0.16 seconds per frame. Scale 1.75 normalizes their taller sheet drawings to the rest silhouette. Use `set_locomotion` while authoritative movement is active; existing PixelActor yields to attacks and resumes or stops automatically. South deliberately uses the original sheet for frame 1 to preserve the opposite raised knee after the correction changed that pose. Both full source sheets remain intact; no offline pixel edits.

`tests/test_heracles_walk.gd`: 16 native checks cover loop timing, start, persistence, attack interruption, resume and stop. `tools/review_pixel_heracles.gd -- --walk --capture-dir=ABSOLUTE_DIRECTORY` records 90 native frames at camera size 14, walking then an attack and a stop. These are staged visuals, not match evidence. Locomotion is provisional: four clear foot phases, limited upper-body motion and slight scale drift against the ready pose.
