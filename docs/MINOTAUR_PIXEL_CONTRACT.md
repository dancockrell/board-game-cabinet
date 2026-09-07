# Minotaur pixel presentation

Provisional authored sprite replacement. Built-in image generation only; source image is preserved unchanged. No pale-background masking: the checkerboard draft was rejected and a separate solid-magenta correction is the admitted image.

## Integration

- `themes/minotaur_south_rest.tres`: single ready frame, looping.
- `themes/minotaur_south_attack.tres`: four frames, 0.59-second two-handed axe chop, nonlooping. Actual art faces southeast.
- Use `PixelActor`, suggested pixel_size 0.0034. Resources apply draw_scale 1.9 and depth_bias 0.20. Keep node at authoritative unit position; frame pivots anchor hooves.
- `play_attack(event_id, clip)` uses real source-ID events; recover through `reset_playback(rest)`/`set_rest_pose(rest)` contracts. Never infer damage from animation.
- Native staged review: `tools/review_minotaur.gd -- --capture-dir=ABSOLUTE_DIRECTORY`. Captures 60 frames and asserts resources/recovery.

## Validation and limits

Native import and staged resource/recovery checks passed. Contact frame inspected with clean empty background and intact axe; only one facing admitted so far. Four frames remain a coarse chop; no walking, rear animation or death sequence yet. Small purple contour remnants remain around isolated fur pixels at close zoom. This is a usable first roster conversion, not final art acceptance.
