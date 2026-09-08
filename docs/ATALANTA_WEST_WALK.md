# Atalanta west walking production contract

The west walk uses eight independently generated images: contact, weight transfer, low passing, extension and their opposite-leg counterparts. It is not a horizontal reflection of the east clip. The near left arm carries the bow; the right hip quiver sits behind the body edge. The rear arm is largely occluded.

The first west drawing used the established west identity reference together with east scale/style reference. Subsequent isolated pose edits preserved equipment while changing leg support. A straight-kick candidate with a generated shadow and an excessively high-knee candidate were rejected. The selected low passing step keeps clearance modest; more knee flexion and additional transition poses remain useful refinements.

The existing west SpriteClip selects eight original source PNGs with explicit regions, stable measured ground pivots and 0.477 art scale. Each phase lasts 0.10 seconds. No image reflection, pixel repainting, destructive masking or resampling was used. The saturated backing is removed by the existing runtime shader.

Native Godot 4.3 validation: clean import; 22 focused west checks passed for source order, bounds, loop, attack recovery and stop; the existing lateral review captured 90 frames at 30 fps and all eight west phases were inspected. Full-game movement and combat validation remains separate from this isolated visual review.

Limitations: restrained arm/braid motion, low passing knee flexion, and a conspicuous rear quiver silhouette relative to the old rest pose. Far-leg shading is lighter than the early east sources. Eight useful phase drawings are progress toward smooth animation, not final motion polish.

Original ancestry, exact available edit prompts and shared local source archive are in the adjacent west sprite provenance files. East artwork and central gameplay code were not modified in this slice.
