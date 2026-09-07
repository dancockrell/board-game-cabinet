# Atalanta pixel conversion

Target: replace the legacy arena archer with the same elevated, crisp outlined pixel treatment as the hoplite. Adult Greek huntress: athletic runner, auburn braid, ivory short hunting chiton with forest-green trim, leather belt/quiver, bronze bracers, strapped sandals. No helmet, shield, exaggerated armour or modern equipment. Bow stays in her left hand; right hand draws to cheek. Identity and equipment handedness are fixed across directions.

First source: two rows of four poses, columns east/west/north/south. Top row ready with bow held low; bottom row full draw aimed in that column's direction. Same camera, light, body scale and foot baseline per row. Flat saturated magenta source, source pixels preserved, runtime chroma filter. Resource crops and foot anchors must be individually inspected. Future clips need nock, draw, release, recovery, locomotion and hit reactions; two poses do not constitute a finished animation set.

Admission: inspect limbs, bowstring, arrow direction, equipment consistency and complete silhouettes; render at gameplay size before runtime replacement. Attacks consume exact authoritative source IDs and never cause damage or state changes. A rejected direction must not silently become a runtime fallback.

## Current implementation

The initial runtime set now has four directional ready poses and four two-frame draw/release clips. `atalanta-v2.png` supplies ready and full draw; `atalanta-release-v1.png` supplies the follow-through, with the arrow gone and bowstring relaxed. Both original generated sources remain untouched. The optional SpriteClip `frame_atlases` array selects the matching source for each frame. Each attack spends 0.09 seconds at draw and 0.15 seconds at release before PixelActor returns to the selected rest direction. These clocks are cosmetic and do not cause shots or damage.

The 384 by 512 source cells use individually selected foot anchors, with a shared 1.60 draw scale. Native four-direction review at the game's .0027 pixel size confirmed unclipped bows and stable foot placement through draw and release. Outputs `Atalanta-Study-05.png`, `-11.png`, `-16.png`, `-23.png`, and `-40.png` show rest, draw, release and recovery respectively; regenerate them with `tools/review_atalanta.gd -- --capture=<absolute-output-prefix>`.

Validation: `tests/test_atalanta_clips.gd` checks all four resources, one-shot recovery and duplicate-event handling (24 checks). `tests/test_sprite_clip.gd` also checks per-frame atlas bounds, missing sources and synchronized shader/texture switching (45 native checks). This is a first animated character conversion, not the finished animation library: walking, nocking, intermediate draw, hit reactions and more facing angles remain to be authored. North/south attacks are angled in the image plane. Team distinction remains the board's rings and health bars.
