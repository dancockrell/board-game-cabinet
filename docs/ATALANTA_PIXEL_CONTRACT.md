# Atalanta pixel conversion

Target: replace the legacy arena archer with the same elevated, crisp outlined pixel treatment as the hoplite. Adult Greek huntress: athletic runner, auburn braid, ivory short hunting chiton with forest-green trim, leather belt/quiver, bronze bracers, strapped sandals. No helmet, shield, exaggerated armour or modern equipment. Bow stays in her left hand; right hand draws to cheek. Identity and equipment handedness are fixed across directions.

First source: two rows of four poses, columns east/west/north/south. Top row ready with bow held low; bottom row full draw aimed in that column's direction. Same camera, light, body scale and foot baseline per row. Flat saturated magenta source, source pixels preserved, runtime chroma filter. Resource crops and foot anchors must be individually inspected. Future clips need nock, draw, release, recovery, locomotion and hit reactions; two poses do not constitute a finished animation set.

Admission: inspect limbs, bowstring, arrow direction, equipment consistency and complete silhouettes; render at gameplay size before runtime replacement. Attacks consume exact authoritative source IDs and never cause damage or state changes. A rejected direction must not silently become a runtime fallback.

## Current implementation

The initial runtime set now has four directional ready poses and four two-frame draw/release clips. `atalanta-v2.png` supplies ready and full draw; `atalanta-release-v1.png` supplies the follow-through, with the arrow gone and bowstring relaxed. Both original generated sources remain untouched. The optional SpriteClip `frame_atlases` array selects the matching source for each frame. Each attack spends 0.09 seconds at draw and 0.15 seconds at release before PixelActor returns to the selected rest direction. These clocks are cosmetic and do not cause shots or damage.

The 384 by 512 source cells use individually selected foot anchors, with a shared 1.60 draw scale. Native four-direction review at the game's .0027 pixel size confirmed unclipped bows and stable foot placement through draw and release. Outputs `Atalanta-Study-05.png`, `-11.png`, `-16.png`, `-23.png`, and `-40.png` show rest, draw, release and recovery respectively; regenerate them with `tools/review_atalanta.gd -- --capture=<absolute-output-prefix>`.

Validation: `tests/test_atalanta_clips.gd` checks all four resources, one-shot recovery and duplicate-event handling (24 checks). `tests/test_sprite_clip.gd` also checks per-frame atlas bounds, missing sources and synchronized shader/texture switching (45 native checks). North/south attacks are angled in the image plane. Team distinction remains the board's rings and health bars.

## North/south walking

`atalanta_north_walk.tres` and `atalanta_south_walk.tres` provide four genuinely alternating contact/passing phases at 0.16 seconds per phase. Bow remains in the left hand, quiver remains on the opposite hip and upper-body identity remains consistent with ready/shooting. Draw scale remains 1.60 at the actor's .0027 pixel size. Individual head-centered X anchors remove sheet spacing drift; foot Y anchors align the ground plane.

The first generated sheet repeated leg phases. A single targeted image-generation correction supplied usable opposite-leg frames; the clips select phases individually across the two original sheets. Neither full sheet is treated as a valid animation in its printed order. `atalanta-walk-provenance.json` records precise frame choices and source digests. No source image was mechanically mirrored or painted over.

`tools/review_atalanta_walk.gd -- --capture=<absolute-output-folder>` captures 90 native frames including rest, several complete loops and stop/recovery. The four phase samples were inspected at frames 10, 15, 20 and 25. `tests/test_atalanta_walk.gd` passed 16 checks covering source validity, ordered phases, looping and recovery from shooting into motion and from motion into rest. Parent board integration must choose these Resources for Atalanta north/south movement; the clip never moves the authoritative unit root.

This remains a narrow four-phase walk. East/west locomotion, nocking, intermediate draws, hit reactions and additional animation in-betweens remain to be authored.
