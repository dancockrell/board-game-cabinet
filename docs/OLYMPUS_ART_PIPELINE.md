# Olympus Arena art production contract

This contract turns the current illustrated and procedural presentation into a repeatable character pipeline. It is the handoff authority for authored models. It does not change combat rules or authorize copying art, animation, audio, interface layouts, or branding from another game.

## Visual target

The game should read as a premium animated tabletop spectacle: warm Mediterranean light, painted limestone, deep turquoise water, bronze, dyed linen, and characters with the appeal of hand-sculpted display miniatures. Shapes should be broad, asymmetrical, and legible from the normal 900 x 698 arena viewport. Avoid glossy Korean-MMO armor, tiny realistic anatomy, crowded filigree, photoreal skin, sexualized combat costumes, and interchangeable fantasy silhouettes.

The eight portraits in `assets/olympus_arena/card-atlas-v1.png` are the current identity and palette anchors. They are approved for runtime use. They are not orthographic model sheets; artists should preserve the defining silhouette and equipment while solving unseen views deliberately.

## Runtime model contract

| Property | Contract |
| --- | --- |
| Format | glTF 2.0 binary (`.glb`), with embedded mesh, skeleton and animation; textures remain separate when iteration benefits from it |
| Scale | Godot meters; miniature base diameter 0.72 m; ordinary figure about 1.35 m from sole to crest; giant about 1.75 m |
| Origin | Center of the miniature base at ground level |
| Forward | Character faces local +Z before the renderer applies team direction |
| Silhouette budget | Spend geometry on face, hands, weapon, hair, wings, horns and creature heads; simplify hidden torso and base surfaces |
| Initial triangle range | 8,000-18,000 per ordinary hero, up to 28,000 for Hydra; revise only after an actual arena stress capture |
| Materials | 2-4 opaque materials per unit; one shared team-accent material slot; avoid transparency except feather or hair cards that pass gameplay-distance review |
| Texture set | 2048² source, 1024² engine target initially; base color, normal, ORM when useful; hand-painted gradients may replace unnecessary maps |
| Team read | Keep character identity colors. Put blue/red on base rim, banner, plume edge, sash or shield accent; never recolor skin, hair or an entire monster |
| Shadows | Opaque meshes cast shadows; small VFX and health bars do not |
| LOD | First pass may use one mesh. Add LOD only after measured crowd cost justifies it |

Required node and clip names:

```text
UnitRoot
  Skeleton3D
  Mesh...
  TeamAccent...

idle_loop      1.6-2.8 s, quiet asymmetrical breathing
walk_loop      0.65-1.0 s, planted feet and stable root
attack_primary readable anticipation, one clear contact marker, recovery
hit_light      0.25-0.45 s, silhouette remains recognizable
death          0.7-1.2 s, exits cleanly without changing authoritative lifetime
victory        optional, 1.2-2.0 s
```

Root motion stays disabled. Authoritative unit coordinates remain on the renderer's replica root; animation moves bones and child visuals only. Attack, hit, summon, death and tower-destruction effects are triggered by snapshot events. An animation can sell an event but cannot decide whether it connected.

## Character invariants

| Unit | Identity that must survive every pose and angle |
| --- | --- |
| Hoplites | Bronze Corinthian helmet, tall blue crest, round owl shield, long spear, disciplined compact stance; three remain readable as a formation |
| Atalanta | Adult athletic archer, copper-red tied hair, simple green chiton, leather bracer, recurve bow, direct mischievous expression |
| Minotaur | Huge dark bull head, broad ivory horns, bronze nose ring, stone-and-bronze axe, heavy forward weight |
| Medusa | Adult elegant gorgon, identifiable face within active snake hair, purple drape, coiled serpent lower body, controlled threatening posture |
| Heracles | Broad bearded hero, lion-head pelt, oversized wooden club, warm confident personality |
| Hydra | Exactly three readable emerald heads, long separated neck arcs, yellow eyes, low heavy body; heads must not merge at gameplay distance |
| Harpies | Adult avian women, large cream wings, dark windblown hair, taloned legs, angular aerial silhouette; two must remain separable |
| Thunderbolt | VFX asset rather than a unit model: branched white-gold bolt, blue-white secondary arc, circular ground shock and brief debris |

## Production flow and storage

```text
approved portrait crop
  -> single-character turnaround and expression sheet
  -> reviewed sculpt/blockout at gameplay camera
  -> retopology, UV and paint
  -> rig plus one animation clip at a time
  -> GLB export
  -> isolated Godot model viewer
  -> eight-unit crowd and combat capture
  -> approved engine asset plus manifest entry
```

Keep the three layers separate:

- `work/art-source/olympus/`: editable source, turnarounds, experiments and rejected variants; never loaded by the game.
- `assets/olympus_arena/models/`: approved engine-ready GLBs and textures only.
- `assets/olympus_arena/art-manifest.json`: source IDs, hashes, tool/version, author or generator, review status, transforms and runtime consumers.

Use stable names such as `hoplite-v001.glb`, `hoplite-basecolor-v001.png`, and `hoplite-animation-review-v001.mp4`. A revision increments when geometry, UVs, identity, rig or animation materially changes. Do not overwrite an approved source invisibly.

## Admission gates

Every character is reviewed at full size and inside an actual native 1440 x 960 match capture. Admission requires:

1. The portrait identity, age, anatomy, hair, outfit, equipment hand, palette, and creature traits remain recognizable from front, side, rear and attack views.
2. Feet do not slide during the walk loop; the origin and base remain stable; wings, weapon and hair do not clip through the body in the required clips.
3. The unit remains distinguishable from every other roster member at the normal arena camera, in both teams, beside three allies, and under combat effects.
4. Team accents pass without destroying identity colors. Health bars remain visible. Attack contact aligns with the corresponding hit effect closely enough to read as one action.
5. The eight-unit and 32-unit stress scenes maintain the target frame cadence on the development machine; the effect cap and audio voice cap remain intact.
6. The model imports without errors in Godot 4.3 Compatibility, survives rematch cleanup, and falls back to the procedural miniature if missing or invalid.
7. Provenance, source hashes, transformations, reviewer decision, rejection reasons, and the exact runtime path are recorded.

The first authored-model experiment should be the hoplite because it tests humanoid anatomy, hard-surface equipment, cloth, a weapon, a shield, team accents, formation spacing, and all core animation clips. Admit that model before commissioning the other seven as a batch.
