# Pixel implementation checkpoint

The previous art and model workshop is preserved at:
C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-legacy-2026-09-07

233 files, 80,666,374 bytes, each copied file verified by SHA256. Includes old project artwork, presentation geometry builders, themes, art tools and notes, original generated 3D sources, rejected equipment derivative, and available review stills/videos. A frozen archive, not another active implementation. Local shared storage only; not published to the public shared repository. Existing runtime dependencies remain until replaced. User suggests revisiting in roughly six months; no reminder created.

## New implementation

presentation/sprite_clip.gd defines ordered atlas regions, individual frame durations, equal-cell pivot, loop/one-shot timing and validation. presentation/pixel_actor.gd renders this Resource using nearest filtering, camera-facing Sprite3D and source-alpha scissoring. It never changes simulation state. Frame time comes from the caller, so simulation and presentation clocks need not diverge. Invalid clips are rejected without overwriting the current clip.

Seven headless checks and three additional native rendering checks cover timing, looping, one-shot hold, malformed duration, atlas bounds and foot-pivot placement. Included in existing local verification and CI workflows. Native preview tool tools/review_pixel_hoplite.gd uses actual arena lighting/terrain and two static candidate views. Run with --capture=ABSOLUTE.png; optional --source=ABSOLUTE.png.

## Candidate status

One built-in image generation, user-authorized current generator. Direction sheet at docs/art-references/hoplite-directions-candidate.png is reference/review only. Original preserved in work/art-source/olympus/pixel-hoplite-directions/source.png and built-in generated-images folder. Output is RGBA, 1254x1254. It supplied alpha despite a flat-magenta request; no color-key extraction was performed. Render uses alpha threshold 0.5. This preserves supplied alpha and does not imply edges are fully approved on every background.

Top-left front and bottom-left back appear consistent enough for a static preview. Other two views reverse equipment sides and are rejected for automatic facing selection. No walk cycle is claimed; rejected earlier sheets remain rejected. The current playable arena roster has not yet switched to pixel sprites. Terrain still uses legacy presentation while the sprite pipeline is established.

Next: correct additional facing views without mirroring equipment; produce opposite-foot contact keyframes; test a complete walk loop at gameplay scale. Then connect admitted clips to authoritative movement/attack state and migrate environment presentation in matching style. Do not conceal absent animation with sliding static figures.
