# Hydra pixel animation

First usable three-headed Hydra set, authored with built-in image generation. Original eight-pose sheet is preserved intact; solid magenta backing is removed by the existing shader, never by keying a pale background.

## Integration

- `themes/hydra_south_idle.tres` and `themes/hydra_north_idle.tres`: four timed breathing phases, relaxed / inhale / relaxed / lowered heads; three unique poses.
- `themes/hydra_south_attack.tres` and `themes/hydra_north_attack.tres`: four phases, ready / inhale / bite / recoil. Trigger on authoritative hit events, not as a source of damage.
- Suggested PixelActor pixel_size `.005` for a creature larger than the hoplite; draw scale 1. Review on live board and adjust presentation only.
- Idle loops need an advancing playback clock; review uses show_time directly. Current shared actor did not advance resting loops at authoring time; coordinator owns that integration.
- North pivot uses foot baseline above tail tip, bounded depth bias .12 keeps tail on the rendered ground. All three heads remain attached in every frame. North's center head faces away and hides its mouth.

## Validation

`tests/test_hydra_sprites.gd` validates all resource bounds, sequence timing and attack final-frame hold. `tools/review_pixel_hydra.gd -- --capture=ABSOLUTE.png` renders 90 native frames, first breathing then bite. Captured and inspected breathing and bite poses on the actual arena renderer; no neighboring cell fragments or magenta backing visible.

Review artifact: `outputs/Hydra-Study.mp4` outside repo. This is a staged visual study, not evidence of match integration.

## Remaining work

North/south only. No authored walk, hit, death or lateral directions yet. Breathing has deliberately large head motion and would benefit from intermediate frames. Attack has three mouths opening southward, but northward silhouette reads more as a neck lunge. Character conversion does not imply full-game visual acceptance.
