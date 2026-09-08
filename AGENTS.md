# Board Game Cabinet / Olympus

The active visual direction is **2D pixel artwork only**. Do not create, restore, or fall back to 3D character models, procedural miniatures, modeled buildings, or PBR scenery. Old 3D work is retired and designated for deletion everywhere; never restore it. Follow docs/OLYMPUS_BOARD_ART.md and docs/HANDOFF.md.

Rules and game state must extend RefCounted, never Node. Scenes render session state and submit requests; they never decide legality or patch state independently. Orthographic sprite placement is presentation infrastructure, not permission to introduce volumetric artwork.

Chess and Ninth Gate rules remain parked source foundations. Their retired 3D scenes must not be restored or exposed through the active game menu. Themes and sprite clips are Resources; rules cannot import presentation.

Work in independent parallel slices with explicit file ownership. Commit only owned files in small coherent increments. The coordinator owns project.godot, app/, core/session.gd, integration and publication. Never use git add . when another agent is working.

Verify headless imports and relevant rules tests, then native graphical integration. Inspect actual rendered gameplay and sequential motion before claiming visual quality. Document incomplete acceptance honestly. Use only built-in image generation authorized by the user; no paid external generation APIs.

## Global 2D production decision

The 2026-09-08 owner decision applies to every project and shared pack: 2D artwork only. Delete retired 3D assets rather than preserve them for a future return. Reuse the shared 2D art folder across Olympus, Cattle Trail, DR Companion and Pirate Island. Physical removal outside this checkout is pending: automatic approval review rejected deletion with only "blocked by policy". Do not describe an inventory or a catalog exclusion as completed deletion.
