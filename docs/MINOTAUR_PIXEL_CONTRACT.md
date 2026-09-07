# Minotaur pixel presentation

Provisional authored sprite replacement. Built-in image generation only; source image is preserved unchanged. No pale-background masking: the checkerboard draft was rejected and a separate solid-magenta correction is the admitted image.

## Integration

- `themes/minotaur_north_rest.tres` / `themes/minotaur_north_attack.tres`: rear counterpart, same timing, no mirroring. Native review accepts `--north`.
- `themes/minotaur_south_rest.tres`: single ready frame, looping.
- `themes/minotaur_south_attack.tres`: four frames, 0.59-second two-handed axe chop, nonlooping. Actual art faces southeast.
- Use `PixelActor`, integrated pixel_size 0.0027. Resources apply draw_scale 1.9 and depth_bias 0.20. Keep node at authoritative unit position; frame pivots anchor hooves.
- `play_attack(event_id, clip)` uses real source-ID events; recover through `reset_playback(rest)`/`set_rest_pose(rest)` contracts. Never infer damage from animation.
- Native staged review: `tools/review_minotaur.gd -- --capture-dir=ABSOLUTE_DIRECTORY`. Captures 60 frames and asserts resources/recovery.

## Validation and limits

Native import and staged resource/recovery checks passed. Contact frame inspected with clean empty background and intact axe; front and rear facings admitted. Four frames remain a coarse chop; no lateral animation or death sequence yet. Small purple contour remnants remain around isolated fur pixels at close zoom. This is a usable first roster conversion, not final art acceptance.

## Walking addition

`themes/minotaur_north_walk.tres` and `themes/minotaur_south_walk.tres` supply four distinct alternating-hoof phases, 0.64-second loops. Use existing `set_locomotion(walk)` while authoritative unit moves and `set_locomotion(null)` when it stops. North art faces away, south toward camera. No board integration is owned by this art slice.

Walking source bodies were larger than the ready source, so resource draw_scale is normalized to 1.36 north / 1.45 south, matching ready scale1.9 at unchanged .0027 actor pixel_size. Native 60-frame captures inspected opposite raised-hoof phases. The rear draft's duplicate axe blade was corrected with imagegen before admission. No source-image masking or resizing was performed.

`tests/test_minotaur_walk.gd`: 15 native assertions cover resource bounds, loop wrap, locomotion recovery after attack and stop/rest. Review accepts `--walk` and `--north --walk`. Four phases are still coarse; native match pacing and transitions should be inspected after integration.
