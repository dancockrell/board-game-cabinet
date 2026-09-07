# Pixel gardens

Eight cypress and four olive troughs replace the sphere/cylinder garden meshes at exactly the previous ground anchors. Their source atlas was authored with built-in image generation, preserved unchanged and masked from saturated magenta in a foliage-specific shader. See the sibling asset provenance JSON for source identity and SHA256.

`olympus_stage.gd` creates 12 billboard props and supplies its existing visual clock. The foliage shader bends only foliage UVs; pots, troughs, scene geometry, ground positions and simulation state remain fixed. Each prop has a spatially seeded phase. No engine TIME uniform or autonomous process can continue the breeze through pause. Four-by-four keyed supersampling and edge despill avoid magenta fringes when the detailed leaves shrink to game scale.

Native validation: 176 stage geometry/material/foliage/budget checks pass, with 451 stage nodes (the existing under-1000 budget is preserved). Assertions include all 12 props, eight cypress, rim positions, clock propagation, stopped/negative time and unchanged anchors. `tools/review_pixel_gardens.gd --output=ABSOLUTE_DIRECTORY` captures 90 native close-up frames; the reviewed output is `outputs/Pixel-Gardens-Breeze.mp4` in the workspace. This is a three-second staged wind study, not match footage.

Remaining polish: olive leaves are very fine at game scale, the rim columns and bridge remain 3D, and the source is a static illustration animated by gentle deformation rather than individually authored wind frames. Neither final environment approval nor performance at maximum unit count is claimed.
