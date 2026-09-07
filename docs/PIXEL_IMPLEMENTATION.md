# Pixel implementation checkpoint

The previous art and model workshop is preserved at:
C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-legacy-2026-09-07

233 files, 80,666,374 bytes, each copied file verified by SHA256. Includes old project artwork, presentation geometry builders, themes, art tools and notes, original generated 3D sources, rejected equipment derivative, and available review stills/videos. A frozen archive, not another active implementation. Local shared storage only; not published to the public shared repository. Existing runtime dependencies remain until replaced. User suggests revisiting in roughly six months; no reminder created.

## New implementation

presentation/sprite_clip.gd defines ordered atlas regions, individual frame durations, equal-cell pivot, loop/one-shot timing and validation. presentation/pixel_actor.gd renders this Resource using nearest filtering, camera-facing Sprite3D and source-alpha scissoring. It never changes simulation state. Frame time comes from the caller, so simulation and presentation clocks need not diverge. Invalid clips are rejected without overwriting the current clip.

Eight headless checks and seventeen native clip/actor checks cover timing, looping, one-shot hold, malformed duration, atlas bounds and foot-pivot placement. Included in existing local verification and CI workflows. Native preview tool tools/review_pixel_hoplite.gd uses actual arena lighting/terrain and two static candidate views. Run with --capture=ABSOLUTE.png; optional --source=ABSOLUTE.png.

## Candidate status

One built-in image generation, user-authorized current generator. Direction sheet at docs/art-references/hoplite-directions-candidate.png is reference/review only. Original preserved in work/art-source/olympus/pixel-hoplite-directions/source.png and built-in generated-images folder. Output is RGBA, 1254x1254. It supplied alpha despite a flat-magenta request; no color-key extraction was performed. Render uses alpha threshold 0.5. This preserves supplied alpha and does not imply edges are fully approved on every background.

Top-left front and bottom-left back appear consistent enough for a static preview. Other two views reverse equipment sides and are rejected for automatic facing selection. No walk cycle is claimed; rejected earlier sheets remain rejected. The current playable arena uses pixel Hoplites with health-triggered guard reactions; other units remain legacy models. Terrain still uses legacy presentation while the sprite pipeline is established.

Next: correct additional facing views without mirroring equipment; produce opposite-foot contact keyframes; test a complete walk loop at gameplay scale. Then connect admitted clips to authoritative movement/attack state and migrate environment presentation in matching style. The current Hoplite slides while moving; this remains a known unfinished acceptance criterion.

## Locomotion experiments, 2026-09-07

The isolated two-contact generation again kept the same stride and returned a light background. Rejected without white-key extraction. A runtime cutout experiment on the existing transparent guard drawing also failed: rectangular leg regions captured the spear tip, and shin rotation did not create convincing footfalls. Neither experiment is admitted to gameplay. Local source and shader are preserved under work/rejected-cutout-walk; reviewed native frames are in the workspace outputs/Hoplite-Cutout-Walk-frames directory. Stop these recipes rather than repeating prompts or disguising the result as finished walking.

The native review tool now preloads its guard Resource at script scope before constructing the review scene. Loading it later in this tool reproduced an uninitialized script-backed Resource in Godot 4.3. The shipped-resource regression is included in test_sprite_clip.gd; keep its Resource preload before the direct Clip script preload. A fresh native guard capture completed all 90 frames. Validation: 8 headless and 17 native sprite checks, 64 native model checks, 773 arena-rule checks. This is pipeline repair, not new admitted locomotion.
