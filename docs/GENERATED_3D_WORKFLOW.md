# Generated 3D asset workflow — current direction

Updated 2026-09-06. This supersedes further procedural figure-detail passes and the old handoff proposal to refine Medusa and Heracles with more profile/tube geometry.

## Purpose

The user rejected the current models as clay-like. The playable procedural figures and buildings remain placeholders. More primitive construction is not the production art strategy.

Use designed reference images, dedicated image-to-3D generation, mesh/UV/material inspection, deliberate cleanup in a modeling package, rigging and animation, then native engine review. Generated meshes are source candidates, not automatically professionally finished assets. A beautiful reference image does not validate a mesh.

## First bounded experiment

Two single-subject references were generated through Magnific on 2026-09-06: one adult bronze-armored Hoplite and one compact intact Doric temple. Both use neutral studio backgrounds and distinct bronze, linen, leather, limestone and terracotta materials. The target is finer historical realism, not toy or clay proportions. The Hoplite retains the blue crest and owl shield. Its diagonal spear and occluded arm require particular scrutiny; this is not yet an animation-ready pose.

| Candidate | Reference creation | 3D creation | Generator | Face limit | Texture setting | Reported credits |
| --- | --- | --- | --- | --- | --- | --- |
| Hoplite v001 | mEKSNLahJQ | DofKSycpcl | Tripo v3.1 via Magnific | 18000 | detailed | 75 reference + 775 mesh |
| Temple v001 | 5j73c9oKxe | WDIQxUScXe | Tripo v3.1 via Magnific | 30000 | detailed | 75 reference + 1160 mesh |

These are reported tool credits, not currency. No subscription or extra credit purchase was made.

Raw downloads belong in `work/art-source/olympus/authored-v001/`. Review artifacts and portable source package go in the workspace outputs folder. Runtime admission remains a separate decision. Do not place rejected or pending models in the shipped assets directory.

## Review sequence

1. Save original GLB and reference, exact generator metadata, hashes, and creation identifiers.
2. Inspect GLB structure: valid geometry, UVs, textures, material channels, triangle count, animations and skeleton presence. A static textured mesh must be explicitly labeled static.
3. Render front, side, rear and three-quarter images with `tools/review_authored_models.gd`. Normalize only a wrapper transform; retain untouched generator bytes.
4. Review anatomy, weapon separation, shield attachment, feet, back surfaces, column gaps, roof support, texture seams and baked lighting. Record specific defects and admit/reject/defer.
5. Clean geometry and UVs in an actual modeling package. Separate weapons and team accents, repair hidden surfaces, create deformation topology where required. Retain editable source.
6. Rig and author the required clips. No root motion; the session remains authoritative. Do not animate a rigid unrigged mesh as if a full character pipeline were complete.
7. Review at the real arena camera, both teams, a formation and combat stress scene. Only then update the runtime manifest and adapter.

## Handoff tasks

- Model cleanup owner: Hoplite anatomy, spear/hand separation, shield back/straps, deformation topology. Output editable source plus GLB; validate four views and shoulder/hip deformation.
- Architecture owner: temple straightness, open colonnade, coherent back, base footprint and roof geometry. Output editable source plus static GLB; validate all views and normal arena footprint.
- Rigging owner (after mesh cleanup): skeleton, idle/walk/attack/hit/death clips from the existing art contract. Validate foot contact and event timing.
- Integration owner (after visual admission): data-driven model Resource, wrapper scale/orientation, team accent and snapshot animation adapter. Validate lifecycle, fallback and unchanged authoritative state.

The initial experiment determines whether generated source meshes reduce the cleanup burden enough to use for the roster. If they fail, record that and use authored/licensed source assets or a dedicated artist rather than expanding a failing generation recipe.
