# Active delivery goal

User explicitly requested this goal on 2026-09-07: make and deliver the Greek pixel-art arena game. Work must progress through playable implementation, not stop at art sheets.

Definition of done: complete local matches against the practice opponent; coherent directional animated roster with readable attacks/reactions; matching pixel battlefield and restrained UI; authoritative simulation owns all decisions; restart and outcomes reliable; native review and relevant regression checks pass; Windows executable launched, packaged and source pushed. Network multiplayer and new games are outside this slice.

Production order:
1. One unit end-to-end: idle, locomotion, attack, hit/recovery, facing; render actual match events.
2. Extend to the existing small roster with distinctive silhouettes, identity and coherent sequences.
3. Pixel battlefield and buildings with clear lanes, footprints and ambient motion.
4. Match feedback, pacing, full-match playtest, export and release.

Legacy art/model work is deferred in shared storage. Current art authority is PIXEL_ART_DIRECTION.md. Built-in generation is explicitly authorized; no external paid model APIs. Preserve rejected candidates, source and provenance. Do not count pose sheets as animations.

## Current implementation increment

A four-frame low-to-high shield sequence now has an authored seven-step raise/hold/lower timing in themes/hoplite_guard_clip.tres. Real RGBA source with no color-key extraction. Native 90-frame diagnostic at 30 fps captures one reaction returning to rest. This is not yet a match or an admitted final animation; four source drawings still need art refinement. No blocking game mechanic was added.

PixelActor now supports reset_playback, react_to_hit and advance_visual. Repeated/older event IDs do not restart a reaction; completed reaction returns to configured rest; reset permits new event numbering. Presentation never mutates game state. 7 headless clip checks and 16 native clip/actor checks pass. Native diagnostic reviewed. Live arena hookup remains next, followed by locomotion and attack. The active goal remains incomplete.

## Live integration

See PIXEL_LIVE_CHECKPOINT.md. Pixel Hoplites now exist in actual matches, with authoritative health-triggered reactions. Locomotion, facing, attack, other units and terrain remain incomplete. Goal is active.
