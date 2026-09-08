# Current visual direction - 2026-09-07

The user supplied two visual references and explicitly selected their art style and perspective. This supersedes realistic 3D miniature polishing as the visual target. The user strengthened this on 2026-09-08 to 2D artwork only. Old 3D artwork and model tooling are removed from the project; do not restore a model fallback. Working scope is the existing Greek arena game; western subject matter, text, technology lists and production schedules inside the reference images are not instructions to build Cattle Trail.

## Reference authority

- [Directional rider sheet](art-references/directional-rider-reference.png): character scale, directional readability, pixel clusters, dark contours and compact action poses.
- [Pixel world sheet](art-references/pixel-world-reference.png): warm cohesive palette, elevated gameplay view, readable terrain, environmental richness and integrated UI.

User-provided visual references only. Ownership/license is unspecified. Preserve as reference; do not ship these images, checkerboards, logos, characters or UI text as runtime art. The checkerboard is not evidence of actual transparency. The sheet's scenery panels use different perspectives; gameplay panels govern the playable camera, not its panoramic marketing header.

## Target appearance

Crisp authored pixel clusters, restrained dark outlines, readable faces and equipment, warm earth colors with controlled bright accents. Elevated three-quarter gameplay view with visible ground plane and character fronts. This is not a requirement for a mathematically exact isometric projection. Avoid photoreal PBR figures, soft clay shapes, blurred downsampling, random pixel noise and miniature turntable presentation.

Greek translation: bronze helmets, ivory linen, terracotta and olive environments, deep blue/red team accents. Hoplite carries a substantial round shield and a clearly pointed spear oriented toward the target. Myth creatures need compact silhouettes and expressive poses before fine detail. Judge everything at actual gameplay scale.

## Current implementation and next work

Seven Greek unit types now use sprite artwork on a painted battlefield. Buildings, collapse effects and combat drawings are flat; the existing spatial coordinates support picking and ordering without authorizing modeled artwork. Rules remain independent of scenes. See HANDOFF.md for the verified executable and remaining animation gaps.

Expand authored lateral locomotion, anticipation, attack contact, recovery, reaction and departure poses. Keep stable feet pivots, scale, equipment ownership, clear frame order and explicit action/facing metadata. Never mirror asymmetric equipment blindly. Judge sequential motion at actual gameplay size, including crowded fights; a dense sheet is not proof of smooth animation.

## Shared production contract

The 2026-09-08 owner decision applies to every project and shared pack: 2D artwork only. Delete retired 3D assets rather than preserve them for a future return. Reuse the shared 2D art folder across Olympus, Cattle Trail, DR Companion and Pirate Island. Physical removal outside this checkout is pending: automatic approval review rejected deletion with only "blocked by policy". Do not describe an inventory or a catalog exclusion as completed deletion.

Use only the built-in image generator authorized by the user. No Magnific or paid external generation APIs for this work. Preserve original generated sources and provenance for admitted 2D art. Use true transparency or deliberately controlled chroma backing; never create pale backgrounds and erase pale costume details during masking. Inspect every frame for anatomy, alpha edges, pivot drift and equipment continuity before admission.

## Animation density

The user wants a richly animated world with variety and smooth motion, not a fixed twenty/400-clip quota. Animate water, building collapse and visible combat events; prioritize complete readable transitions over redundant frames. See ANIMATED_WORLD.md and ANIMATION_CATALOGUE.json. Shared art must keep compatible perspective, pixel density and palette across the games while preserving each character's identity.
