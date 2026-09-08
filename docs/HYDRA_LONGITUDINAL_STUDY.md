# Hydra longitudinal locomotion study — rejected

Date: 2026-09-08. Built-in image generator, two calls; no external or paid API.

These sources are 2D artwork retained for future paintover and pose planning. Neither is an admitted runtime animation. Existing north/south breathing clips remain unchanged and must not be described as authored walking.

Shared folder: `C:/Users/Admin/Documents/Codex/shared-game-environment-library/assets/candidates_needing_review/olympus-hydra-longitudinal-2026-09-08`.

| Source | SHA256 | Finding |
| --- | --- | --- |
| hydra-longitudinal-candidate-a.png | 74D8846CAD9587DBD24C807AC60D5F939B782C97F6DBA6CF6F2AF90A9D7F42A1 | Paw variation exists, but the front tail flips sides in column 3 and support phases do not form the requested cycle. |
| hydra-longitudinal-candidate-b.png | 12049EB0FEFE07C6061B7B3A6E32C384E2E3C82A394DA77E6CA0F7AB4D33F489 | Front tail continuity improved, but rear columns 1–2 repeat left support; the front extension order remains inconsistent. |

Both unchanged 1536×1024 sources use four columns and two rows with magenta backing. They preserve three heads and the reference palette, but visual review of the complete ordered sheets rejects gait continuity. No native integration claim is made: rejected art was not added to runtime, Resources, or central board mappings.

## Generation specification

Reference: `assets/olympus_arena/sprites/hydra-actions-v1.png` (existing Hydra identity). First call requested a 4×2 sheet, front walking toward camera above/rear walking away below, alternating left contact, left support/right swing, right contact, right support/left swing; reciprocating rear legs; steady heads and small tail sway. Camera, body scale, three heads/four legs and green/gold pixel rendering were locked, with flat #ff00ff backing and no ground shadow. Second call used candidate A as edit target, specifically keeping the top tail on screen right and requiring screen-left extension/support then screen-right extension/support, with tiny rear tail motion. The generator did not consistently obey anatomical phase constraints.

## Next attempt

Use separately authored contact and passing references for each direction rather than a whole-sheet text correction. Inspect left/right weight transfer before spending work on atlas timing or pivots. Tail silhouette should remain on a consistent side in front view. Reuse the current admitted identity and shared pixel-art style.

## Eight-pose south follow-up

The owner requested richer action sheets. A new single-direction eight-frame sheet was generated, then corrected with a targeted lower-row limb-pose edit and a missing-tail restoration. This supplied opposite forepaw lifts without duplicating frames. Final source: `assets/olympus_arena/sprites/hydra-south-walk-eight-v1.png`; Resource: `themes/hydra_south_walk.tres`.

All eight source regions are distinct. Contact baselines are corrected with explicit per-frame pivots (upper row 450, lower row 410). The 0.92-second cycle uses authored lift/contact poses and keeps the tail on screen right. Native review captured 60 frames and inspected all eight phase representatives over the actual painted board. Native clip tests pass timing, looping, pause and reset. Central integration belongs to the coordinator and is not claimed by this study.

This is a useful first richer south locomotion loop, not final animation polish: rear feet are partly occluded, and body/neck transitions still benefit from additional drawn intermediates. North/rear locomotion remains unfinished. Source chain and exact hash are recorded beside the PNG; rejected intermediate 2D sheets and final source are preserved in the same shared study folder.
