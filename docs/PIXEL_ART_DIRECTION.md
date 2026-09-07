# Current visual direction - 2026-09-07

The user supplied two visual references and explicitly selected their art style and perspective. This supersedes realistic 3D miniature polishing as the visual target. The existing renderer remains implementation history until a replacement is tested. Working scope is the existing Greek arena game; western subject matter, text, technology lists and production schedules inside the reference images are not instructions to build Cattle Trail.

## Reference authority

- [Directional rider sheet](art-references/directional-rider-reference.png): character scale, directional readability, pixel clusters, dark contours and compact action poses.
- [Pixel world sheet](art-references/pixel-world-reference.png): warm cohesive palette, elevated gameplay view, readable terrain, environmental richness and integrated UI.

User-provided visual references only. Ownership/license is unspecified. Preserve as reference; do not ship these images, checkerboards, logos, characters or UI text as runtime art. The checkerboard is not evidence of actual transparency. The sheet's scenery panels use different perspectives; gameplay panels govern the playable camera, not its panoramic marketing header.

## Target appearance

Crisp authored pixel clusters, restrained dark outlines, readable faces and equipment, warm earth colors with controlled bright accents. Elevated three-quarter gameplay view with visible ground plane and character fronts. This is not a requirement for a mathematically exact isometric projection. Avoid photoreal PBR figures, soft clay shapes, blurred downsampling, random pixel noise and miniature turntable presentation.

Greek translation: bronze helmets, ivory linen, terracotta and olive environments, deep blue/red team accents. Hoplite carries a substantial round shield and a clearly pointed spear oriented toward the target. Myth creatures need compact silhouettes and expressive poses before fine detail. Judge everything at actual gameplay scale.

## First implementation slice

Prove ONE Hoplite as a sprite in the existing arena before expanding the roster. Keep the authoritative simulation and deployment coordinates. A directional billboard presentation can use the existing 3D world for depth and picking; a renderer change must not move game rules into scenes. Use Sprite3D/atlas resources with nearest filtering, stable feet pivot, consistent pixels per world unit and explicit animation metadata.

Start with front, back and both diagonal views; expand directions only after readability passes. Spear and shield sides must remain anatomically consistent; do not mirror asymmetrical equipment blindly. Require idle and a short complete walk cycle with stable ground contact. Attack must lead with the spearhead. No claim of animation readiness based on a sprite sheet alone.

Render one Greek unit against a small matching terrain patch and the current arena at normal scale. Compare contour weight, pixel size, camera elevation, lighting direction and team distinction with the references. A pixelated render of the rejected model is not automatically an accepted sprite. Decide the final pixel dimensions from this trial rather than inventing them from a scaled reference sheet.

## Production constraints

No paid generation or paid model work. Existing assets may serve as source/reference; guided Magnific browser generation only when Generate Unlimited is visibly confirmed. No headless generation. Keep original outputs and provenance. Separate reference, candidate and admitted runtime layers. Sprite generation requires inspection of every frame for anatomy, direction, equipment continuity, alpha and pivot stability.

## Current status

References preserved and direction documented. No pixel-art runtime replacement or finished Greek sprite is claimed in this checkpoint. The previous Hoplite mesh, grip and equipment experiments remain historical evidence, not the art target.

## Animation density

The user requests a richly animated whole world, with lots of variety and smooth motion. Their clarification supersedes the provisional twenty/400 clip quotas: there is no fixed per-item count. See [animated world production direction](ANIMATED_WORLD.md) and [starter catalogue](ANIMATION_CATALOGUE.json). No paid generation is authorized.

## Generator update

User explicitly selected the built-in image generator instead of Magnific. Use it for current sprite work; see [first Hoplite trial](PIXEL_HOPLITE_TRIAL.md). This does not authorize external paid model APIs.
