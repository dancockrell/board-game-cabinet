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

All four cardinal facings now have idle and attack clips. No authored walk or character-specific hit/death clips yet. Breathing has deliberately large head motion and would benefit from intermediate frames. Attack has three mouths opening southward, but northward silhouette reads more as a neck lunge. Character conversion does not imply full-game visual acceptance.

## Lateral expansion — September 8, 2026

`hydra-lateral-v1.png` is an untouched built-in image-generation source, with its exact file hash and prompt in adjacent provenance. One generation used; no correction or external API. Four equal 384 by 512 cells per row, east above west, contain ready / inhale / bite / recoil. The palette, three heads, bronze crests and substantial four-legged body match the original package. These are three-quarter lateral silhouettes, with heads aiming east/west while the chest remains partially visible, rather than strict profiles.

Integrate `themes/hydra_east_idle.tres`, `hydra_west_idle.tres`, `hydra_east_attack.tres`, and `hydra_west_attack.tres` into the corresponding facing dictionaries. Preserve the existing .005 actor pixel size, scale 1 and .12 depth bias. Both foot pivots are anchored to the visible foot baseline. Idle is ready / inhale / ready / recoil (three unique images); attack uses all four cells. Both idle and attack share body scale and backing treatment. The existing runtime magenta shader removes saturated backing; no light-background mask or destructive cleanup was used.

`tests/test_hydra_lateral.gd` passed bounds, ordered timing, loop and attack-hold validation. `tools/review_pixel_hydra_lateral.gd` captured 90 native frames and exited successfully. Inhale and bite captures were inspected: three attached heads, clean cell separation and no visible magenta. `outputs/Hydra-Lateral-Study.mp4` is a three-second staged study outside the repo, not a legal-match test. Board integration and full-match validation remain coordinator-owned. The strong inhale still needs authored intermediate frames for greater smoothness; this package fills direction coverage without claiming that polish is finished.
