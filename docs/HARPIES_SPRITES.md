# Harpies flight and talon strike

Built-in image generation, 2026-09-08. Ten authored poses: north and south flight with raised, horizontal, lowered and folded upstroke wings, and a forward talon lunge for each facing. Identity: adult Greek harpy, brown feathers, bronze bird legs, ivory tunic, green sash; wings replace arms.

`assets/olympus_arena/sprites/harpies-flight-v1.png` is the unchanged selected output. An initial brown-backed generation was corrected through a built-in edit to pure magenta, preserving poses while separating feather tips. No brown or light-background masking was attempted. Provenance is alongside the PNG.

Resources: `themes/harpies_{north,south}_{flight,attack}.tres`. Each uses explicit unequal crop rectangles and torso-aligned pivots. Flight has four distinct phases in a 0.44-second loop. Strike has anticipation, a held talon contact, then folded-wing recovery in 0.39 seconds. These are presentation timings, never damage authority.

## Integration

Use PixelActor at pixel_size 0.0027, resource draw_scale 1.25, and approximately 1 unit above the ground footprint. Set both rest and locomotion to flight, including while stationary: hovering must keep flapping. On exact-source attack events call `play_attack`; recovery restores flight. Current art supports north/south only. Do not mirror it as a claim of authored east/west animation.

## Validation

- Godot 4.3 import: clean.
- `tests/test_harpies_clips.gd`: 12 headless and 22 native checks passed, including wrap, one-shot interruption, duplicate rejection and recovery.
- `tools/review_pixel_harpies.gd -- --capture-dir=ABSOLUTE_DIRECTORY`: 90 native frames, 4 resource validations and 2 recovery checks passed.
- Native frames 4 (horizontal wings), 10 (folded upstroke), and 40 (talon strike) inspected over the actual arena. Feather tips are whole; magenta is removed; front/back silhouettes and talon strike read distinctly.
- Local review video: `outputs/Harpies-Flight-Review.mp4` at workspace level, outside source repository.

This is a usable provisional animation package, not a finished roster claim. It has only two facings and four flight phases, with small feather/tunic shape drift. Final in-match integration, timing and team-readability acceptance belong to the coordinator.
