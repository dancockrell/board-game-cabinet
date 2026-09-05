# Olympus Arena board-art contract

This is the visual authority for the playable board. The target is a fine Mediterranean tabletop diorama photographed in warm afternoon light: weathered limestone, worn mortar, aged bronze, faded terracotta, deep coastal water, clipped cypress, and painted display miniatures. The scene can be stylized, but its materials, scale, light, and adult anatomy should behave plausibly.

The default review view is the native **1440 x 960** game window with its **900 x 698** arena viewport. Full-size closeups are diagnostic. They do not admit an asset that becomes noisy, toy-like, or illegible at the play camera.

## Surface language

| Surface | Read at play distance | Avoid |
| --- | --- | --- |
| Limestone | Warm gray-beige body, mineral variation, porous roughness, dark settled joints, softened edge highlights | Clean white blocks, identical cubes, black outlines |
| Paving | Offset masonry, restrained block variation, shallow worn bevel, occasional accumulated dirt | Perfect graph-paper grid, high-contrast procedural noise |
| Bronze | Dark aged body with a narrow metallic highlight; used for trim and objects | Flat yellow-gold architecture, chrome reflections |
| Terracotta | Desaturated fired-clay roof with subtle course rhythm | Saturated orange toy plastic |
| Water | Deep teal-green body, broad swell plus fine broken highlights, visible depth around the plinth | Bright cyan sheet, regular animated grid |
| Plants and rocks | Several related natural values, irregular scale and rotation, recognizable Mediterranean silhouette | Repeated cones and evenly spaced identical stones |

Procedural variation must be stable and presentation-only. It never moves deployment geometry, the ground picking plane, bridges, tower coordinates, or authoritative unit positions. Screen-space effects must not conceal health bars, placement feedback, team accents, or the river crossing.

## Architecture and lighting

The temples are limestone structures with columns, recessed dark entrances, shallow terracotta roofs, aged metal details, and narrow dyed-linen team standards. Blue and red identify ownership through flags, base rims, shield marks, and small trim. They do not recolor whole buildings or characters.

The sun is a warm directional key with visible contact shadows. A weak cool sky fill keeps faces, shields, and the shaded sides of buildings readable. Filmic tone mapping should retain detail in pale stone and prevent gold, water, or VFX from clipping. The camera remains a board-game camera: stable, orthographic, and high enough to understand both lanes at once. Camera shake is brief cosmetic feedback driven by observed events and never changes picking.

## Miniature construction

Procedural figures are the approved fallback until authored GLBs pass the production gates in [the art pipeline](OLYMPUS_ART_PIPELINE.md). Their target is a well-painted 32-40 mm display miniature enlarged for readability:

- adult head-to-body proportions and believable limb lengths;
- layered linen, leather, bronze, hair, skin, and creature surfaces rather than a single glossy team color;
- weapon, shield, wings, horns, and Hydra heads readable in silhouette;
- team color limited to base rim, shield mark, sash, plume edge, or similarly small accents;
- quiet idle motion, planted walk, one readable attack follow-through, and a stable authoritative root;
- no sexualized armor, oversized cartoon eyes, interchangeable MMO ornament, or anatomy that changes between portrait and model.

Transient event effects can sell a hit, charge, healing pulse, summon, or collapse. Persistent rules states must also remain visible while they are true: for example, a charged Minotaur keeps its amber base cue until the strike is consumed.

## Admission check

Every board-art change must pass all of these checks before it becomes release evidence:

1. Godot imports without shader, mesh, resource, or script errors in the Compatibility renderer.
2. Native board and app checks confirm that picking, legal deployment, snapshot reuse, effects, rematch cleanup, and the authoritative state contract still work.
3. An opening capture checks composition and highlight range; a populated mid-match capture checks silhouettes, team read, health bars, bridge traffic, effects, and crowding.
4. The board is inspected at the normal window size. Pale stone retains joint detail, water does not dominate, team ownership remains obvious, and every unit type is distinguishable without using its portrait.
5. A sequential native gameplay capture confirms that water, ambient life, attacks, status cues, and camera feedback move continuously without fabricated events or retiming.
6. Any new bitmap or authored model is recorded in the art manifest with its source, hash, tool/version, review status, transforms, and runtime consumers. Procedural code assets are recorded through source control and the release source commit.

The next authored-model gate remains one complete Hoplite. It should replace the fallback only after the isolated model viewer and the real match view both outperform the current miniature without losing the shield, spear, formation, or team read.

## Sanctuary iteration

`presentation/olympus_sculpt.gd` builds explicitly shaped Hoplite and Minotaur geometry using ring profiles and tapered curved tubes. This is an intermediate asset technique with editable source: no external model or texture dependencies. The Hoplite shield and spear, and Minotaur axe, belong to animated arm children. Preserve this attachment in any replacement. The old sphere assembly is no longer the visual standard for those two units.

The stage uses mixed rectangular courses and subtle joints so the paving supports the figures without competing with them. Team color belongs on a thin plinth rim; its top is neutral weathered stone. Health bars are unlit and cast no shadows. The next art priority is to bring the Hydra, Harpies, Atalanta and Medusa to the same degree of shape control, then review attack poses and crowd silhouettes in both teams.

The September 6 integration admits the Atalanta and creature builders alongside complete Doric temples. Temple admission includes solid pediment faces, correct roof cover/ridge orientation, recessed interior depth, and the same footprint/height limits as the gameplay structures. Feather meshes must be closed and have outward-facing normals on every face; a dark or hollow reverse side is an admission failure. The next model priorities are Medusa and Heracles. Fine authored texture work and skeletal animation remain future production work.
