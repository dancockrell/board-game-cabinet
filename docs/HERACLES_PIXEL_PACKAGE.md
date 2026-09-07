# Heracles pixel character package

Authored with the built-in image generator. Adult bearded Greek hero with a tawny lion-pelt hood, red skirt and knotted wooden club. Source images are preserved; pure magenta is removed by the existing runtime shader.

## Integration

Use `themes/heracles_{east,west,north,south}_rest.tres` and corresponding `_attack.tres`. Set PixelActor pixel_size to 0.0027. Resource scales normalize the separate north sheet (1.40) against the other directions (2.0). Rest is one looping pose. Attack is wind-up 0.13s, strike 0.16s, recovery 0.12s. Authoritative attack event IDs should drive `play_attack`; animation does not apply damage or move roots.

Foot anchors are per-frame and source pixels are not cropped or repainted offline. The unused north column on heracles-v1 is rejected: it changes weapon hands. heracles-north-v1 supplies the admitted rear direction. Two unsuccessful intermediate editing outputs remain in the generation directory and are not runtime dependencies.

## Validation

`tests/test_heracles_clips.gd` checks eight resources, distinct wind-up/strike phases, sequence timing, event deduplication and matching-direction recovery. Run with native Godot because the dummy renderer reports Sprite3D mesh warnings even when assertions pass. `tools/review_pixel_heracles.gd -- --capture-dir=ABSOLUTE_DIRECTORY` captures 90 staged native frames, four directions and two attacks/recoveries. This is presentation review, not actual gameplay.

## Remaining work

Walking, hit/death reactions, more in-betweens, diagonal facing refinements and team palette variants remain. The north contact still reads as a forward high swing with a diagonal aim, rather than a deep overhead ground strike. Slight body/costume drift remains between sheets. Integration and full-match validation belong to the coordinator.
